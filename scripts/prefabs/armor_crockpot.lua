local SCAN_RADIUS = 10
local SANITY_RATIO = 0.15
local HUNGER_RATIO = 0.15
local GOAT_CHANCE = 0.05

local function OnBlocked(owner)
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_metal")
end

-- 生成替罪羊电羊
local function SpawnScapegoat(owner, attacker)
    if not owner or not owner:IsValid() then return nil end
    local x, y, z = owner.Transform:GetWorldPosition()

    -- 随机安全偏移位置
    local offset = FindWalkableOffset(Vector3(x, y, z), math.random() * 2 * PI, 3 + math.random() * 2, 8, true, true)
    local goatpos = offset and Vector3(x + offset.x, y, z + offset.z) or Vector3(x, y, z)

    local goat = SpawnPrefab("lightninggoat")
    if goat then
        -- 移除 herd 组件
        if goat.components.herdmember then
            goat:RemoveComponent("herdmember")
        end
        goat:RemoveTag("herdmember")
        -- 添加替罪羊标签
        goat:AddTag("scapegoat")
        goat.Transform:SetPosition(goatpos.x, goatpos.y, goatpos.z)

        if attacker then
            goat.components.combat:SuggestTarget(attacker)
        end

        -- 替罪羊带电
        if goat.sg then
            goat.sg:GoToState("shocked")
        end
        if goat.setcharged then
            goat:setcharged()
        end

        -- 随机生命比例
        -- if goat.components.health then
        --     goat.components.health:SetPercent(math.random())
        -- end

        return goat
    end
    return nil
end

-- 护甲自身承伤扣精神饥饿
local function OnTakeDamage(inst, damage_amount)
    local owner = inst.components.inventoryitem.owner
    if not owner then return end

    -- 自身受伤低概率触发替罪羊
    local activeGoat = true -- 技能树控制
    if activeGoat and (math.random() < (GOAT_CHANCE + (damage or 0) / 1500)) then
        local goat = SpawnScapegoat(owner)
        if goat and goat.components.health then
            goat.components.health:DoDelta(-damage_amount)
            return
        end
    end

    -- 计算需要扣除的饥饿和精神
    local hunger_needed = damage_amount * HUNGER_RATIO
    local sanity_needed = damage_amount * SANITY_RATIO

    -- 扣饥饿
    local hunger_deficit = 0
    if owner.components.hunger then
        local current_hunger = owner.components.hunger.current
        if current_hunger >= hunger_needed then
            owner.components.hunger:DoDelta(-hunger_needed)
        else
            owner.components.hunger:DoDelta(-current_hunger)
            hunger_deficit = hunger_needed - current_hunger
        end
    else
        hunger_deficit = hunger_needed
    end

    -- 扣精神
    local sanity_deficit = 0
    if owner.components.sanity then
        local current_sanity = owner.components.sanity.current
        if current_sanity >= sanity_needed then
            owner.components.sanity:DoDelta(-sanity_needed)
        else
            owner.components.sanity:DoDelta(-current_sanity)
            sanity_deficit = sanity_needed - current_sanity
        end
    else
        sanity_deficit = sanity_needed
    end

    -- 如果有剩余不足部分，用血补
    local total_deficit = hunger_deficit + sanity_deficit
    if total_deficit > 0 and owner.components.health then
        owner.components.health:DoDelta(-total_deficit)
        -- print(string.format("[BackArmor] 补充扣血 %.2f，因为饥饿或精神不足", total_deficit))
    end
end

-- 绑定队友 redirectdamagefn
local function ApplyDamageRedirect(inst, teammate)
    if not teammate._backarmor_redirect then
        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem:GetGrandOwner() or nil
        if not owner or not owner:IsValid() then return end

        teammate._backarmor_redirect = function(_, attacker, damage, weapon, stimuli, spdamage)
            if not owner:IsValid() or not owner.components.health or owner.components.health:IsDead() then
                return nil
            end
            if attacker.prefab == "lightninggoat" then
                return owner -- 电羊伤害不甩锅
            end

            local activeGoat = true -- 技能树控制
            if activeGoat and (math.random() < (GOAT_CHANCE + (damage or 0) / 750)) then
                local goat = SpawnScapegoat(owner, attacker)
                if goat then
                    return goat
                end
            end
            return owner
        end

        if teammate.components.combat then
            teammate.components.combat.redirectdamagefn = teammate._backarmor_redirect
        end
    end
end

-- 移除离开范围的队友 redirectfn
local function RemoveDamageRedirect(teammate)
    if teammate._backarmor_redirect and teammate.components.combat then
        if teammate.components.combat.redirectdamagefn == teammate._backarmor_redirect then
            teammate.components.combat.redirectdamagefn = nil
        end
        teammate._backarmor_redirect = nil
    end
end

-- 扫描附近的玩家
local function ScanNearbyPlayers(inst)
    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem:GetGrandOwner() or nil
    if not owner or not owner:IsValid() then return end

    local x, y, z = owner.Transform:GetWorldPosition()
    local players = TheSim:FindEntities(x, y, z, SCAN_RADIUS, {"player"}, {"playerghost"})

    if inst._teammates == nil then inst._teammates = {} end

    -- 移除离开范围的玩家
    for p, _ in pairs(inst._teammates) do
        local still_near = false
        for _, pl in ipairs(players) do
            if pl == p then still_near = true break end
        end
        if not still_near then
            RemoveDamageRedirect(p)
            inst._teammates[p] = nil
            -- print("[BackArmor] Removed damage modifier and redirect from:", tostring(p))
        end
    end

    -- 给新进入范围的玩家加 redirectfn
    for _, p in ipairs(players) do
        if p ~= owner and not inst._teammates[p] then
            ApplyDamageRedirect(inst, p)
            inst._teammates[p] = true
            -- print("[BackArmor] Applied damage modifier and redirect to:", tostring(p))
        end
    end
end

-- 破碎逻辑：向6个方向甩锅，可控制是否二段甩，方向带随机旋转偏移，锅有概率敲坏掉落材料
local function OnArmorBroke(owner, data)
    local inst = data.armor
    if not (inst and inst:IsValid()) then return end

    local x, y, z = owner.Transform:GetWorldPosition()
    local radius = 6 -- 投掷距离，可根据需求修改

    -- 播放爆炸效果
    local efx = SpawnPrefab("balloon_pop_body")
    local ex, ey, ez = inst.Transform:GetWorldPosition()
    if efx then efx.Transform:SetPosition(ex, ey, ez) end

    -- 🔹 随机旋转起始角度
    local offset_angle = math.random() * 6 * math.pi
    local angles = {}
    for i = 0, 5 do
        table.insert(angles, offset_angle + i * math.pi / 3)
    end

    -- 是否整组触发二段甩（可由技能树控制）
    local will_second = true -- 改成 false 就只炸一段

    -- 🔹 函数：生成锅实体并有概率敲坏掉落材料
    local function TrySpawnPotWithSmash(bomb, bx, by, bz, owner)
        -- 处理敲坏概率
        if not bomb:IsValid() then return end

        local do_smash = false -- 是否触发坏锅（可由技能树控制）
        local loot_list = {}

        if do_smash then
            -- 坏锅：掉落固定原材料
            loot_list = {
                {name="goldnugget", count=1},
                {name="charcoal", count=3},
                {name="twigs", count=3},
            }
        else
            -- 没坏锅：掉落锅本身
            loot_list = {
                {name="portablecookpot_item", count=1},
            }
        end

        -- 投掷掉落物
        for _, loot in ipairs(loot_list) do
            for i = 1, loot.count do
                local item = SpawnPrefab(loot.name)
                if item then
                    LaunchAt(item, bomb, owner, -1, 0.5, 0, 0)
                end
            end
        end
    end

    -- 🔹 通用甩炸弹逻辑
    local function ThrowBomb(dirx, dirz)
        local bomb = SpawnPrefab("bomb_crockpot")
        if not bomb then
            print("[BackArmor] Spawn bomb failed")
            return
        end

        bomb._throw_dir = Vector3(dirx, 0, dirz)
        bomb._is_second = false
        bomb.should_spawn_pot = not will_second -- ❗️如果不会触发二段，就在一段生成锅

        local old_onhit = bomb.components.complexprojectile and bomb.components.complexprojectile.onhitfn or nil

        -- 第一段 OnHit
        local function FirstOnHit(bomb_inst, attacker, target)
            if old_onhit then
                pcall(old_onhit, bomb_inst, attacker, target)
            end

            local bx, by, bz = bomb_inst.Transform:GetWorldPosition()

            -- 没有触发二段：直接生成锅
            if bomb_inst.should_spawn_pot then
                TrySpawnPotWithSmash(bomb, bx, by, bz, owner)
                return
            end

            -- 有触发二段：生成第二段炸弹
            local second = SpawnPrefab("bomb_crockpot")
            if not second then
                print("[BackArmor] Spawn second bomb failed")
                return
            end

            second._is_second = true
            second._throw_dir = bomb_inst._throw_dir
            second.should_spawn_pot = true -- 第二段一定生成锅

            local second_old_onhit = second.components.complexprojectile and second.components.complexprojectile.onhitfn or nil

            -- 第二段 OnHit
            local function SecondOnHit(sec_inst, att2, tgt2)
                if second_old_onhit then
                    pcall(second_old_onhit, sec_inst, att2, tgt2)
                end
                if sec_inst.should_spawn_pot then
                    local sx, sy, sz = sec_inst.Transform:GetWorldPosition()
                    TrySpawnPotWithSmash(sec_inst, sx, sy, sz, owner)
                end
            end

            if second.components.complexprojectile then
                second.components.complexprojectile:SetOnHit(SecondOnHit)
            end

            -- 发射第二段炸弹
            second.Transform:SetPosition(bx, by + 1, bz)
            if second.components.complexprojectile then
                local tx = bx + dirx * radius
                local tz = bz + dirz * radius
                local targetPos = Vector3(tx, by, tz)
                second.components.complexprojectile:Launch(targetPos, owner, nil)
            end
        end

        -- 设置第一段 OnHit
        if bomb.components.complexprojectile then
            bomb.components.complexprojectile:SetOnHit(FirstOnHit)
        end

        -- 发射第一段炸弹
        bomb.Transform:SetPosition(x, y + 1, z)
        if bomb.components.complexprojectile then
            local tx = x + radius * dirx
            local tz = z + radius * dirz
            local targetPos = Vector3(tx, y, tz)
            bomb.components.complexprojectile:Launch(targetPos, owner, nil)
        end
    end

    -- 🔹 向6个方向投掷
    for _, a in ipairs(angles) do
        local dirx, dirz = math.cos(a), math.sin(a)
        ThrowBomb(dirx, dirz)
    end
end

-- 装备
local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body_tall", "armor_crockpot", "swap_body_tall")
    inst:ListenForEvent("blocked", OnBlocked, owner)

    -- 监听破碎
    if true then -- 技能树控制是否开启
        owner:ListenForEvent("armorbroke", OnArmorBroke)
    end

    -- 定期扫描队友
    if true then -- 技能树控制是否开启
        inst._scantask = inst:DoPeriodicTask(1, ScanNearbyPlayers)
    end
end

-- 卸下
local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body_tall")
    inst:RemoveEventCallback("blocked", OnBlocked, owner)

    -- 监听破碎
    if true then -- 技能树控制是否开启
        owner:RemoveEventCallback("armorbroke", OnArmorBroke)
    end

    -- 定期扫描队友
    if true then -- 技能树控制是否开启
        if inst._scantask then
            inst._scantask:Cancel()
            inst._scantask = nil
        end

        -- 移除所有挡伤害的玩家
        if inst._teammates then
            for p, _ in pairs(inst._teammates) do
                RemoveDamageRedirect(p)
                inst._teammates[p] = nil
                -- print("[BackArmor] Removed damage modifier and redirect from:", tostring(p))
            end
        end
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    -- inst.AnimState:SetBank("onemanband")
    -- inst.AnimState:SetBuild("armor_onemanband")
    inst.AnimState:SetBank("armor_crockpot")
    inst.AnimState:SetBuild("armor_crockpot")
    inst.AnimState:PlayAnimation("anim")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "armor_crockpot"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/armor_crockpot.xml"

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(648, 0.99999)
    inst.components.armor.ontakedamage = OnTakeDamage

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("armor_crockpot", fn)
