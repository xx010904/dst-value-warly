-- 炊具改装 (解决回血困难)
-- Section 1：背锅侠 Crockpot Carrier
-- 1 制作黑锅：100%承受伤害，666耐久，额外受到10%精神损失10%饥饿损失，分锅摆6个锅
-- 2 100%附近队友伤害转移
-- 3.1 概率产生替罪羊 3.2 解羊：屠杀额外掉落
-- 4.1 6个方向甩锅 4.2 二段跳炸锅（摔坏了就没有二段炸了啊）

-- Section 2：改造厨师包
-- 1 料理升级厨师袋，咸加保鲜度，甜加移速，辣加保暖，蒜香加防水防沙
-- 2 舒适的厨师袋，料理越多越多回san


--========================================================
-- Section 1：背锅锅制作配方
--========================================================
AddRecipe2("armor_crockpot",
    {
        Ingredient("portablecookpot_item", 0),
        Ingredient("charcoal", 20),
    },
    TECH.NONE,
    {
        product = "armor_crockpot", -- 唯一id
        atlas = "images/inventoryimages/armor_crockpot.xml",
        image = "armor_crockpot.tex",
        builder_tag = "masterchef",
        builder_skill = "warly_crockpot_make", -- 指定技能树才能做
        description = "armor_crockpot",        -- 描述的id，而非本身
        numtogive = 1,
        no_deconstruction = true,
        canbuild = function(recipe, builder)
            if not builder then return nil end

            local required_count = 6 -- 需要的锅数量
            local x, y, z = builder.Transform:GetWorldPosition()
            local collected = {}
            local total = 0
            local candidates = {}

            -- 1️⃣ 收集地面上的锅
            local ground_pots = TheSim:FindEntities(x, y, z, 20, nil, nil, nil)
            for _, pot in ipairs(ground_pots) do
                if pot.prefab == "portablecookpot_item" then
                    local px, py, pz = pot.Transform:GetWorldPosition()
                    local dist = math.sqrt((px - x)^2 + (py - y)^2 + (pz - z)^2)
                    local count = 1
                    if pot.components.stackable then
                        count = pot.components.stackable:StackSize()
                    end
                    table.insert(candidates, { pot = pot, count = count, dist = dist })
                end
            end

            -- 2. 不够就收几个摆好的锅
            if #candidates < 6 then
                local missing = 6 - #candidates
                local recovered = 0

                local placed_pots = TheSim:FindEntities(x, y, z, 4, nil, nil, nil)

                for _, pot in ipairs(placed_pots) do
                    if pot.prefab == "portablecookpot"
                        and pot.components
                        and pot.components.stewer
                        and not pot.components.stewer:IsCooking()
                        and pot.components.portablestructure then

                        pot.components.portablestructure:Dismantle(builder)
                        recovered = recovered + 1

                        if recovered >= missing then
                            break
                        end
                    end
                end
            end

            -- 3️⃣ 按距离从远到近排序
            table.sort(candidates, function(a, b)
                return a.dist > b.dist
            end)

            -- 4️⃣ 消耗锅
            for _, entry in ipairs(candidates) do
                if total >= required_count then break end

                local take = math.min(entry.count, required_count - total)
                table.insert(collected, { pot = entry.pot, amount = take })
                total = total + take
            end

            if total < required_count then
                -- print("建造失败，锅不足，总共找到", total)
                return false, "NO_COOKPOT_NEARBY"
            end

            -- 5️⃣ 真正扣除锅
            for _, entry in ipairs(collected) do
                local pot = entry.pot
                local amount = entry.amount
                SpawnPrefab("lucy_transform_fx").Transform:SetPosition(pot.Transform:GetWorldPosition())
                if pot.components.stackable then
                    pot.components.stackable:Get(amount):Remove()
                else
                    pot:Remove()
                end
            end

            -- print("建造成功，总共消耗锅:", total)
            return true
        end
    }
)
AddRecipeToFilter("armor_crockpot", "CHARACTER")

--========================================================
-- 统一给所有电羊添加替罪羊逻辑
--========================================================
AddPrefabPostInit("lightninggoat", function(goat)
    if not TheWorld.ismastersim then return end

    goat:DoTaskInTime(0, function()
        if goat:HasTag("scapegoat") then
            -- 移除 herd 组件和 herd 标签
            if goat.components.herdmember then
                goat:RemoveComponent("herdmember")
            end
            goat:RemoveTag("herdmember")

            goat:AddComponent("named")
            goat.components.named:SetName(STRINGS.NAMES.SCAPEGOAT)

            -- 玩家攻击加倍伤害 + 死亡额外掉落羊角
            goat:ListenForEvent("attacked", function(goat, data)
                if data and data.attacker and data.attacker:HasTag("player") then
                    if goat.components.health and not goat.components.health:IsDead() then
                        local dmg = data.damage or 0
                        goat.components.health:DoDelta(-dmg * 3) -- 额外扣除3倍
                    end
                end
            end)

            -- 替罪羊被击杀后可能掉落羊角
            goat:ListenForEvent("death", function(goat, data)
                if math.random() > 0.25 then
                    return
                end
                -- 查找附近玩家
                local x, y, z = goat.Transform:GetWorldPosition()
                local players = TheSim:FindEntities(x, y, z, 16, { "player" })
                for _, player in ipairs(players) do
                    -- 检查是否为沃利并且有技能树
                    local hasSkill = player.components.skilltreeupdater and
                        player.components.skilltreeupdater:IsActivated("warly_crockpot_scapegoat")
                    if hasSkill then
                        -- 掉落一个羊角
                        local horn = SpawnPrefab("lightninggoathorn")
                        if horn then
                            horn.Transform:SetPosition(x, y, z)
                        end
                        break
                    end
                end
            end)

            -- 替罪羊每秒掉血
            goat.components.health:StartRegen(-6, 1)
        end
    end)

    -- 保存替罪羊状态
    local old_OnSave = goat.OnSave
    goat.OnSave = function(goat, data)
        if old_OnSave then old_OnSave(goat, data) end
        if goat:HasTag("scapegoat") then
            data.is_scapegoat = true
        end
    end

    -- 加载替罪羊状态
    local old_OnLoad = goat.OnLoad
    goat.OnLoad = function(goat, data)
        if old_OnLoad then old_OnLoad(goat, data) end
        if data and data.is_scapegoat then
            goat:AddTag("scapegoat")
            if goat.components.herdmember then
                goat:RemoveComponent("herdmember")
            end
            goat:RemoveTag("herdmember")
        end
    end
end)

--========================================================
-- 分锅技能
--========================================================
local CHARCOAL_MAX = 20
local SPAWN_RADIUS = 2
local NUM_COOKPOTS = 6

local function PassCookpots(inst, doer)
    if not (inst and doer and doer:HasTag("player") and doer.prefab == "warly") then
        return false
    end

    -- 技能树控制分锅
    local hasSkill = doer.components.skilltreeupdater and
                    doer.components.skilltreeupdater:IsActivated("warly_crockpot_make")
    if not hasSkill then
        return false, "NO_SKILL"
    end

    -- 计算可返还木炭数量（向下取整）
    local durability_percent = inst.components.armor and inst.components.armor:GetPercent() or 0
    local num_charcoal = math.floor(durability_percent * CHARCOAL_MAX)
    -- print(string.format("[ArmorCrockpot] 耐久度 %.2f -> 木炭返还 %d", durability_percent, num_charcoal))

    local x, y, z = inst.Transform:GetWorldPosition()
    local theta_step = 2 * PI / NUM_COOKPOTS

    for i = 1, NUM_COOKPOTS do
        local angle = i * theta_step
        local offset = Vector3(math.cos(angle) * SPAWN_RADIUS, 0, math.sin(angle) * SPAWN_RADIUS)
        local pos = Vector3(x + offset.x, 0, z + offset.z)

        -- local can_deploy = TheWorld.Map and TheWorld.Map:IsPassableAtPoint(pos:Get()) and TheWorld.Map:IsDeployPointClear2(pos, nil, 2) and not TheWorld.Map:IsOceanAtPoint(pos.x, 0, pos.z)
        -- local prefab = can_deploy and "portablecookpot" or "portablecookpot_item"
        local prefab = "portablecookpot"

        local pot = SpawnPrefab(prefab)
        if pot then
            pot.AnimState:PlayAnimation("place")
            pot.SoundEmitter:PlaySound("dontstarve/common/together/portable/cookpot/place")
            pot.Transform:SetPosition(pos:Get())
            -- print(string.format("[ArmorCrockpot] 生成 %s 于 (%.2f, %.2f, %.2f)", prefab, pos.x, pos.y, pos.z))
        end
    end

    -- 返还木炭
    if num_charcoal > 0 and doer and doer.components and doer.components.inventory then
        local charcoal = SpawnPrefab("charcoal")
        if charcoal ~= nil then
            charcoal.components.stackable:SetStackSize(math.floor(num_charcoal)) -- 向下取整确保安全
            doer.components.inventory:GiveItem(charcoal)
            -- print(string.format("[分锅] 给 %s %d 个木炭", doer:GetDisplayName(), num_charcoal))
        end
    else
        -- print("[分锅] 没有需要返还的木炭或动作人无效")
    end

    -- 使用完后移除装备
    inst:Remove()

    return true
end

-- 自定义动作
local PassCookpotsAction = Action({ priority = 10 })
PassCookpotsAction.id = "PASS_THE_POT"
PassCookpotsAction.str = STRINGS.ACTIONS.PASS_THE_POT
PassCookpotsAction.fn = function(act)
    local inst = act.target or act.invobject
    local doer = act.doer
    if inst and doer then
        return PassCookpots(inst, doer)
    end
end

AddAction(PassCookpotsAction)

-- 绑定右键动作
AddComponentAction("SCENE", "passpottool", function(inst, doer, actions, right)
    if right and inst.prefab == "armor_crockpot" and doer.prefab == "warly" then
        table.insert(actions, ACTIONS.PASS_THE_POT)
    end
end)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.PASS_THE_POT, "dolongaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.PASS_THE_POT, "dolongaction"))


--========================================================
-- SECTION2: 改造厨师包
--========================================================
-- === 保存与加载 调味状态 ===
local function OnSave(inst, data)
    data.spice_upgrade = inst._spice_upgrade

    -- 保存 perishable 剩余时间
    if inst.components.perishable then
        data.perish_remaining = inst.components.perishable:GetPercent()
    end

    -- 保存技能树相关倍率或buff
    if inst._spice_upgrade then
        if inst._spice_upgrade == "spice_chili" and inst.components.insulator then
            data.insulation = inst.components.insulator:GetInsulation()
        elseif inst._spice_upgrade == "spice_garlic" and inst.components.waterproofer then
            data.has_waterproofer = true
            if inst:HasTag("goggles") then
                data.has_goggles_tag = true
            end
        elseif inst._spice_upgrade == "spice_sugar" and inst.components.equippable then
            data.walkspeedmult = inst.components.equippable.walkspeedmult
        elseif inst._spice_upgrade == "spice_salt" and inst.components.preserver then
            data.preserver_mult = inst.components.preserver.perish_rate_mult
        end
    end
end

local function OnLoad(inst, data)
    if not data then return end

    inst._spice_upgrade = data.spice_upgrade

    if inst._spice_upgrade then
        -- 恢复辣椒保暖
        if inst._spice_upgrade == "spice_chili" then
            if inst.components.insulator == nil then
                inst:AddComponent("insulator")
            end
            inst.components.insulator:SetWinter()
            inst.components.insulator:SetInsulation(data.insulation or TUNING.INSULATION_LARGE)

        -- 恢复蒜粉防水防沙
        elseif inst._spice_upgrade == "spice_garlic" then
            inst:AddTag("goggles")
            if data.has_waterproofer and inst.components.waterproofer == nil then
                inst:AddComponent("waterproofer")
            end

        -- 恢复盐保鲜倍率
        elseif inst._spice_upgrade == "spice_salt" then
            if inst.components.preserver == nil then
                inst:AddComponent("preserver")
            end
            inst.components.preserver:SetPerishRateMultiplier(data.preserver_mult or TUNING.PERISH_SALTBOX_MULT)

        -- 恢复甜加移速
        elseif inst._spice_upgrade == "spice_sugar" then
            if inst.components.equippable == nil then
                inst:AddComponent("equippable")
            end
            inst.components.equippable.walkspeedmult = data.walkspeedmult or 1.2
        end

        -- 恢复 perishable
        if inst.components.perishable == nil then
            inst:AddComponent("perishable")
            inst:AddTag("show_spoilage")
        end
        inst.components.perishable:SetPerishTime(TUNING.TOTAL_DAY_TIME * 10)
        inst.components.perishable:StartPerishing()
        if data.perish_remaining then
            inst.components.perishable:SetPercent(data.perish_remaining)
        end
    end
end

----------------------------------------------------
-- 舒适厨师包：定期检测owner状态和里面装有多少东西
----------------------------------------------------
AddPrefabPostInit("spicepack", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    -- 这里是厨师包保存调味状态
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    -- 这里是厨师包定期检测owner和容器内容的代码
    inst:DoPeriodicTask(1, function(inst)
        local container = inst.components.container
        local equippable = inst.components.equippable
        if not container or not equippable then
            return
        end

        local owner = inst.components.inventoryitem and inst.components.inventoryitem:GetGrandOwner()
        if not (owner and owner:HasTag("player")) then
            equippable.dapperness = 0
            return
        end

        local hasSkill = owner.components.skilltreeupdater and
                         owner.components.skilltreeupdater:IsActivated("warly_spickpack_cozy")

        if not hasSkill then
            equippable.dapperness = 0
            return
        end

        local food_count = {}
        for k = 1, container.numslots do
            local item = container:GetItemInSlot(k)
            if item and item:HasTag("spicedfood") and string.find(item.prefab, "spice_") then
                local prefab = item.prefab
                local count = item.components.stackable and item.components.stackable:StackSize() or 1
                food_count[prefab] = (food_count[prefab] or 0) + count
                -- print(string.format("[SpicePack] Slot %d 检测到调料食物: %s (数量 %d)", k, prefab, count))
            end
        end

        local total = 0
        for prefab, count in pairs(food_count) do
            -- 计算递增加成，最多算40个
            local capped = math.min(count, 40)
            local extra = (capped - 1) * 0.05
            total = total + 1 + extra

            -- print(string.format(
            --     "[SpicePack] 食物种类: %s ×%d → capped=%d → 计入 %.2f",
            --     prefab, count, capped, 1 + extra
            -- ))
        end

        local dapper = TUNING.DAPPERNESS_MED * total
        equippable.dapperness = dapper
        -- print(string.format("[SpicePack] 总加成种类数: %.2f，对应理智恢复: %.2f", total, dapper))
    end)
end)

-- 公共方法：快速扔地再捡起来，用于刷新UI或重新绑定组件
local function DropAndPickup(inst, doer)
    if not (inst and inst:IsValid() and doer and doer:IsValid()) then
        return
    end

    local inv = doer.components.inventory
    if not inv then
        return
    end

    -- 检查物品是否在玩家身上（容器、背包、装备都算）
    local is_held = false
    if inst.components.inventoryitem then
        local owner = inst.components.inventoryitem.owner
        if owner == doer or (owner and owner.components.inventoryitem and owner.components.inventoryitem.owner == doer) then
            is_held = true
        end
    end

    -- 如果确实在玩家身上，就执行“扔出再拾回”
    if is_held then
        inv:DropItem(inst, true, true)
        inst:DoTaskInTime(0, function(d)
            if d and d:IsValid() and doer and doer:IsValid() and doer.components.inventory then
                -- 确认物品可拾取
                if d.components.inventoryitem and not d.components.inventoryitem:IsHeld() and d.components.equippable then
                    doer.components.inventory:Equip(d)
                    -- d.components.equippable:Equip(doer, true)
                    -- 可选日志：
                    -- print("[SpicePack] Dropped and picked up:", d.prefab)
                end
            end
        end)
    end
end

----------------------------------------------------
-- 香料厨师袋：调味料给厨师包使用
----------------------------------------------------
local function ClearSpiceBuff(inst)
    -- print("过期回调：恢复原状", inst._spice_upgrade)
    if inst._spice_upgrade == "spice_chili" and inst.components.insulator then
        inst:RemoveComponent("insulator")
    elseif inst._spice_upgrade == "spice_garlic" then
        inst:RemoveTag("goggles")
        if inst.components.waterproofer then
            inst:RemoveComponent("waterproofer")
            inst:RemoveTag("waterproofer")
        end
    elseif inst._spice_upgrade == "spice_salt" then
        if inst.components.preserver then
            inst:RemoveComponent("preserver")
        end
    elseif inst._spice_upgrade == "spice_sugar" and inst.components.equippable then
        inst.components.equippable.walkspeedmult = 1
    end
    inst._spice_upgrade = nil
end

local function UpgradeSpicePack(inst, doer, spice_type)
    if doer == nil or doer.prefab ~= "warly" then
        return false
    end

    ----------------------------------------------------
    -- 💀 清理已有料理状态
    ----------------------------------------------------
    if inst._spice_upgrade ~= nil then
        -- 移除旧buff
        ClearSpiceBuff(inst)
    end

    -- 移除旧的perishable事件
    if inst._on_spice_expire ~= nil then
        inst:RemoveEventCallback("perished", inst._on_spice_expire)
        inst._on_spice_expire = nil
    end

    ----------------------------------------------------
    -- ✅ 确保 perishable 存在（持续10天）
    ----------------------------------------------------
    if inst.components.perishable == nil then
        inst:AddComponent("perishable")
        inst:AddTag("show_spoilage")
    end
    inst.components.perishable:SetPerishTime(TUNING.TOTAL_DAY_TIME * 10)
    inst.components.perishable:StartPerishing()

    ----------------------------------------------------
    -- 🌶️ 根据调料添加新的buff
    ----------------------------------------------------
    -- 🌶️ 辣椒：添加保暖
    if spice_type == "spice_chili" then
        if inst.components.insulator == nil then
            inst:AddComponent("insulator")
        end
        inst.components.insulator:SetWinter()
        inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE * 2)
        inst._spice_upgrade = "spice_chili"
        -- 🧄 蒜粉：添加防水 + 防沙
    elseif spice_type == "spice_garlic" then
        if inst.components.waterproofer == nil then
            inst:AddComponent("waterproofer")
            inst:AddTag("waterproofer")
        end
        inst:AddTag("goggles")
        inst._spice_upgrade = "spice_garlic"
        -- 🧂 盐：提升保鲜率
    elseif spice_type == "spice_salt" then
        if inst.components.preserver == nil then
            inst:AddComponent("preserver")
        end
        inst.components.preserver:SetPerishRateMultiplier(TUNING.BEARGERFUR_SACK_PRESERVER_RATE)
        inst._spice_upgrade = "spice_salt"
        -- 🍯 甜：增加移动速度
    elseif spice_type == "spice_sugar" then
        if inst.components.equippable == nil then
            inst:AddComponent("equippable")
        end
        inst.components.equippable.walkspeedmult = 1.2
        inst._spice_upgrade = "spice_sugar"
    end

    DropAndPickup(inst, doer)

    ----------------------------------------------------
    -- 💀 绑定过期回调：恢复原状
    ----------------------------------------------------
    inst._on_spice_expire = function(inst)
        if inst and doer then
            ClearSpiceBuff(inst)
            inst:RemoveComponent("perishable")
            inst:RemoveTag("show_spoilage")
            DropAndPickup(inst, doer)
        end
    end
    inst:ListenForEvent("perished", inst._on_spice_expire)

    if doer.components.talker then
        doer.components.talker:Say(GetString(doer, "ANNOUNCE_SPICEPACK_UPGRADE"))
    end

    return true
end

-- 注册动作
local SPICEPACK_UPGRADE = Action({ priority = 1, rmb = true, distance = 1, mount_valid = true })
SPICEPACK_UPGRADE.id = "SPICEPACK_UPGRADE"
SPICEPACK_UPGRADE.str = STRINGS.ACTIONS.SPICEPACK_UPGRADE
SPICEPACK_UPGRADE.fn = function(act)
    if act.invobject and act.target and act.doer then
        local doer = act.doer
        local hasSkill = doer:HasTag("warly_spickpack_upgrade")
        if hasSkill and act.invobject:HasTag("spice") and string.find(act.invobject.prefab, "spice_") then
            act.invobject.components.stackable:Get():Remove()
            UpgradeSpicePack(act.target, act.doer, act.invobject.prefab)
            return true
        end
    end
end
AddAction(SPICEPACK_UPGRADE)

-- 添加使用动作：右键用香料升级 技能树控制
AddComponentAction("USEITEM", "spicesacktool", function(inst, doer, target, actions, right)
    if right and string.find(inst.prefab, "spice_") and target and target.prefab == "spicepack" and doer.prefab == "warly" then
        local hasSkill = doer:HasTag("warly_spickpack_upgrade")
        if hasSkill then
            table.insert(actions, ACTIONS.SPICEPACK_UPGRADE)
        end
    end
end)

-- 动作动画（修理动作）
AddStategraphActionHandler("wilson", ActionHandler(SPICEPACK_UPGRADE, "dolongaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(SPICEPACK_UPGRADE, "dolongaction"))

-- 添加组件
AddPrefabPostInit("spice_chili", function(inst)
    if not TheWorld.ismastersim then
        return
    end
    inst:AddComponent("spicesacktool")
end)
AddPrefabPostInit("spice_sugar", function(inst)
    if not TheWorld.ismastersim then
        return
    end
    inst:AddComponent("spicesacktool")
end)
AddPrefabPostInit("spice_garlic", function(inst)
    if not TheWorld.ismastersim then
        return
    end
    inst:AddComponent("spicesacktool")
end)
AddPrefabPostInit("spice_salt", function(inst)
    if not TheWorld.ismastersim then
        return
    end
    inst:AddComponent("spicesacktool")
end)



--========================================================
-- SECTION3: 改造便携研磨器
--========================================================
--------------------------------------------------------------------------
-- 冷却时间
--------------------------------------------------------------------------
local FLAVOR_COOLDOWN = 10 -- 1天冷却

-- 启动冷却
local function StartFlavorCooldown(player)
    if not player then return end

    -- 添加标记
    player:AddTag("portableblender_cd")

    -- 记录结束时间戳
    player._next_flavor_time = GetTime() + FLAVOR_COOLDOWN

    -- 每秒检查是否结束
    if player._flavor_cd_task then
        player._flavor_cd_task:Cancel()
        player._flavor_cd_task = nil
    end
    player._flavor_cd_task = player:DoPeriodicTask(1, function(inst)
        if inst._next_flavor_time and GetTime() >= inst._next_flavor_time then
            inst:RemoveTag("portableblender_cd")
            if inst.components.talker then
                inst.components.talker:Say("我闻到了香料！")
            end
            inst._next_flavor_time = nil
            if inst._flavor_cd_task then
                inst._flavor_cd_task:Cancel()
                inst._flavor_cd_task = nil
            end
        end
    end)
end

--------------------------------------------------------------------------
-- 动作定义
--------------------------------------------------------------------------
local SACRIFICE_FLAVOR = AddAction("SACRIFICE_FLAVOR", "探味", function(act)
    local inst = act.invobject
    local doer = act.doer
    if not (inst and doer) then
        return false
    end

    if doer:HasTag("portableblender_cd") then
        if doer.components.talker then
            doer.components.talker:Say("有虫子！")
        end
        return true
    end

    StartFlavorCooldown(doer)

    local x, y, z = doer.Transform:GetWorldPosition()

    -- 移除物品
    inst:Remove()

    -- 生成动画FX
    local fx = SpawnPrefab("portableblender_sacrifice_fx")
    fx.Transform:SetPosition(x, y, z)

    return true
end)
SACRIFICE_FLAVOR.priority = 10

--------------------------------------------------------------------------
-- 注册动作入口
--------------------------------------------------------------------------
AddComponentAction("INVENTORY", "inventoryitem", function(inst, doer, actions)
    if inst.prefab == "portableblender_item" and doer:HasTag("masterchef") and not doer:HasTag("portableblender_cd") then
        table.insert(actions, ACTIONS.SACRIFICE_FLAVOR)
    end
end)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.SACRIFICE_FLAVOR, "dolongaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.SACRIFICE_FLAVOR, "dolongaction"))

--------------------------------------------------------------------------
-- prefab 扩展
--------------------------------------------------------------------------
AddPrefabPostInit("portableblender_item", function(inst)
    if not TheWorld.ismastersim then
        return
    end
    inst._cooling = false
end)

-- 保存 / 读取
AddPrefabPostInit("warly", function(inst)
    if not TheWorld.ismastersim then return end

    local oldsave = inst.OnSave
    inst.OnSave = function(inst, data)
        if oldsave then oldsave(inst, data) end
        if inst._next_flavor_time then
            local remaining = math.max(0, inst._next_flavor_time - GetTime())
            if remaining > 0 then
                data.next_flavor_cd = remaining
            end
        end
    end

    local oldload = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if oldload then oldload(inst, data) end
        if data and data.next_flavor_cd then
            StartFlavorCooldown(inst) -- 会自动设置 tag 并启动倒计时
            inst._next_flavor_time = GetTime() + data.next_flavor_cd
        end
    end
end)