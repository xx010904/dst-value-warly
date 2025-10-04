local SCAN_RADIUS = 10
local SANITY_RATIO = 0.25
local HUNGER_RATIO = 0.25
local GOAT_CHANCE = 0.10

local function OnBlocked(owner)
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour")
end

-- 护甲自身承伤扣精神饥饿
local function OnTakeDamage(inst, damage_amount)
    local owner = inst.components.inventoryitem.owner
    if not owner then return end

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

local function ApplyDamageRedirect(inst, teammate)
    if not teammate._backarmor_redirect then
        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem:GetGrandOwner() or nil
        if not owner or not owner:IsValid() then return end

        teammate._backarmor_redirect = function(_, attacker, damage, weapon, stimuli, spdamage)
            if owner == nil or not owner:IsValid() or owner.components.health == nil or owner.components.health:IsDead() then
                return nil -- 背锅侠无效就不甩锅
            end
            if attacker.prefab == "lightninggoat" then
                return owner -- 电羊伤害不甩锅
            end

            -- 判断是否触发闪避替罪羊逻辑
            if math.random() < GOAT_CHANCE + (damage or 0) / 1000 then
                local x, y, z = owner.Transform:GetWorldPosition()

                -- 随机安全偏移位置 (避免传送进墙)
                local offset = FindWalkableOffset(Vector3(x, y, z), math.random() * 2 * PI, 3 + math.random() * 2, 8, true, true)
                if offset then
                    local newpos = Vector3(x + offset.x, y, z + offset.z)
                    owner.Transform:SetPosition(newpos.x, newpos.y, newpos.z)
                    print(string.format("[BackArmor] 玩家闪避到新位置 (%.2f, %.2f, %.2f)", newpos.x, newpos.y, newpos.z))
                else
                    print("[BackArmor] 未找到安全位置，玩家未移动")
                end

                -- 在原位置生成电羊替罪羊
                local goat = SpawnPrefab("lightninggoat")
                if goat then
                    -- 移除 herd 组件
                    if goat.components.herdmember then
                        goat:RemoveComponent("herdmember")
                    end
                    goat:RemoveTag("herdmember")
                    -- 添加替罪羊标签
                    goat:AddTag("scapegoat")
                    goat.Transform:SetPosition(x, y, z)
                    goat.components.combat:SuggestTarget(attacker)
                    goat.sg:GoToState("shocked")
                    if goat.setcharged then
                        goat:setcharged()
                    end
                    if goat.components.health then
                        goat.components.health:SetPercent(math.random()) -- 随机生命比例 0~1
                    end
                    print(string.format("[BackArmor] ⚡ 替罪羊电羊生成成功！位置(%.2f, %.2f, %.2f) 目标=%s (GUID=%d)",
                        x, y, z, attacker.prefab or "nil", attacker.GUID or 0))
                    return goat -- 电羊承伤
                else
                    print("[BackArmor] 替罪羊生成失败！")
                end
            end

            -- 未触发闪避或生成失败，玩家自己承伤
            return owner
        end

        if teammate.components.combat then
            teammate.components.combat.redirectdamagefn = teammate._backarmor_redirect
            print(string.format("[BackArmor] 已为 %s 绑定 redirectdamagefn", teammate.prefab or "unknown"))
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
            print("[BackArmor] Removed damage modifier and redirect from:", tostring(p))
        end
    end

    -- 给新进入范围的玩家加 redirectfn
    for _, p in ipairs(players) do
        if p ~= owner and not inst._teammates[p] then
            ApplyDamageRedirect(inst, p)
            inst._teammates[p] = true
            print("[BackArmor] Applied damage modifier and redirect to:", tostring(p))
        end
    end
end

-- 破碎逻辑：向6个方向投掷亮茄炸弹
local function OnArmorBroke(owner, data)
    local inst = data.armor
    if inst and inst:IsValid() then
        local x, y, z = owner.Transform:GetWorldPosition()
        local angles = {0, math.pi/3, 2*math.pi/3, math.pi, 4*math.pi/3, 5*math.pi/3}
        local radius = 6 -- 投掷距离

        for _, a in ipairs(angles) do
            local bomb = SpawnPrefab("bomb_lunarplant")
            if bomb then
                -- 保存原始 OnHit
                local old_OnHit = bomb.components.complexprojectile and bomb.components.complexprojectile.onhitfn or nil

                -- 重写 OnHit
                local function NewOnHit(bomb, attacker, target)
                    -- 调用原始逻辑
                    if old_OnHit then
                        old_OnHit(bomb, attacker, target)
                    end
                    -- 获取当前位置
                    local bx, by, bz = bomb.Transform:GetWorldPosition()
                    -- 在爆炸位置生成锅
                    local pot = SpawnPrefab("portablecookpot_item")
                    if pot then
                        pot.Transform:SetPosition(bx, by, bz)
                    end
                end

                -- 设置新的 OnHit
                if bomb.components.complexprojectile then
                    bomb.components.complexprojectile:SetOnHit(NewOnHit)
                end

                -- 从玩家位置生成炸弹
                bomb.Transform:SetPosition(x, y + 1, z)
                if bomb.components.complexprojectile then
                    local tx = x + radius * math.cos(a)
                    local tz = z + radius * math.sin(a)
                    local ty = y
                    local targetPos = Vector3(tx, ty, tz)
                    bomb.components.complexprojectile:Launch(targetPos, owner, nil)
                end
            end
        end
    end
end

-- 装备
local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "armor_wood", "swap_body")
    inst:ListenForEvent("blocked", OnBlocked, owner)

    -- 监听破碎
    owner:ListenForEvent("armorbroke", OnArmorBroke)

    -- 定期扫描队友
    inst._scantask = inst:DoPeriodicTask(1, ScanNearbyPlayers)
end

-- 卸下
local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner:RemoveEventCallback("armorbroke", OnArmorBroke)
    inst:RemoveEventCallback("blocked", OnBlocked, owner)

    if inst._scantask then
        inst._scantask:Cancel()
        inst._scantask = nil
    end

    if inst._teammates then
        for p, _ in pairs(inst._teammates) do
            if p.components.combat then
                p.components.combat.externaldamagetakenmultipliers:SetModifier(inst, 1)
            end
        end
        inst._teammates = nil
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    inst.AnimState:SetBank("armor_wood")
    inst.AnimState:SetBuild("armor_wood")
    inst.AnimState:PlayAnimation("anim")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
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
