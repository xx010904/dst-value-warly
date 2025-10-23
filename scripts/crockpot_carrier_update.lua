-- 炊具改装 (解决回血困难)
-- Section 1：背锅侠 Crockpot Carrier
-- 1 制作黑锅：100%承受伤害，666耐久，额外受到10%精神损失10%饥饿损失，
-- 2 100%附近队友伤害转移
-- 3.1 概率产生替罪羊 3.2 解羊：屠杀额外掉落
-- 4.1 6个方向甩锅 4.2 二段跳炸锅（摔坏了就没有二段炸了啊）

-- Section 2：改造厨师包
-- 1 舒适的厨师袋，料理越多越多回san
-- 2 料理升级厨师袋


--========================================================
-- 背锅锅制作配方
--========================================================
AddRecipe2("armor_crockpot",
    {
        Ingredient("portablecookpot_item", 6),
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
        no_deconstruction = true,              -- 可选：防止分解还原
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
                local players = TheSim:FindEntities(x, y, z, 10, { "player" })
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
            goat.components.health:StartRegen(-3, 1)
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
-- SECTION2: 改造厨师包
--========================================================

----------------------------------------------------
-- === 保存与加载 ===
----------------------------------------------------
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

            -- 恢复蒜粉标签
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

            -- 恢复甜调料速度
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
-- prefab 里要注册保存钩子
----------------------------------------------------
AddPrefabPostInit("spicepack", function(inst)
    inst:AddTag("spicepack")

    if not TheWorld.ismastersim then
        return
    end

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    -- 缓存监听任务
    inst._spice_dapper_task = nil

    --==================================================
    -- 更新背包中调料数量并设置回精神
    --==================================================
    local function UpdateDapperness(inst)
        if inst.components.container == nil or inst.components.equippable == nil then
            return
        end

        local owner = inst.components.inventoryitem:GetGrandOwner()
        local hasSkill = owner.components.skilltreeupdater and
        owner.components.skilltreeupdater:IsActivated("warly_spickpack_cozy")
        if owner == nil or not hasSkill then
            -- 没有技能树，清零
            inst.components.equippable.dapperness = 0
            return
        end

        local total = 0
        for k = 1, inst.components.container.numslots do
            local item = inst.components.container:GetItemInSlot(k)
            if item and item:HasTag("spicedfood") and string.find(item.prefab, "spice_") then
                total = total + 1
            end
        end

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED * total
    end

    ----------------------------------------------------
    -- 开始监听容器物品变化
    ----------------------------------------------------
    local function StartDappernessListener(inst)
        if inst._spice_dapper_task then
            return
        end

        if inst.components.container then
            inst._spice_dapper_task = function(inst)
                UpdateDapperness(inst)
            end

            inst:ListenForEvent("itemget", inst._spice_dapper_task)
            inst:ListenForEvent("itemlose", inst._spice_dapper_task)

            -- 初始化一次
            UpdateDapperness(inst)
        end
    end

    ----------------------------------------------------
    -- 停止监听并清理回精神
    ----------------------------------------------------
    local function StopDappernessListener(inst)
        if inst._spice_dapper_task then
            inst:RemoveEventCallback("itemget", inst._spice_dapper_task)
            inst:RemoveEventCallback("itemlose", inst._spice_dapper_task)
            inst._spice_dapper_task = nil
        end

        if inst.components.equippable then
            inst.components.equippable.dapperness = 0
        end
    end

    ----------------------------------------------------
    -- onequip / onunequip 绑定
    ----------------------------------------------------
    if inst.components.equippable then
        -- 监听装备事件
        inst:ListenForEvent("equipped", function(inst, data)
            local owner = data.owner
            if owner and owner.prefab == "warly" then -- 只有沃利才监听 技能树控制
                local hasSkill = owner.components.skilltreeupdater and
                owner.components.skilltreeupdater:IsActivated("warly_spickpack_cozy")
                if hasSkill then
                    StartDappernessListener(inst)
                end
            end
        end)

        inst:ListenForEvent("unequipped", function(inst, data)
            local owner = data.owner
            StopDappernessListener(inst)
        end)
    end

    -- inst.StartDappernessListener = StartDappernessListener
    -- inst.StopDappernessListener = StopDappernessListener

    -- 如果生成时就在玩家身上，直接启动检测
    -- inst:DoTaskInTime(60, function()
    --     local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    --     local hasSkill = owner and owner:HasTag("warly_spickpack_cozy")

    --     -- 打印是否找到了拥有技能的玩家
    --     -- print("[Debug] owner:", owner and owner.prefab or "No Owner", "has warly_spickpack_cozy skill:", hasSkill)

    --     if hasSkill and owner:HasTag("player") then
    --         -- print("[Debug] Player has the skill, updating dapperness.")
    --         DropAndPickup(inst, owner)
    --     else
    --         -- print("[Debug] Player does not have the skill or is not a valid player.")
    --     end
    -- end)
end)

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

-- 7) 补充逻辑，激活技能点的时候激活舒适厨师袋的更新
-- function UpdatePiePotSpells(inst)
--     local skilltreeupdater = inst.components.skilltreeupdater
--     local hasSkill = (skilltreeupdater ~= nil and skilltreeupdater:IsActivated("warly_spickpack_cozy"))

--     if hasSkill then
--         local inventory = inst.components.inventory
--         if inventory then
--             local items = inventory:GetItemsWithTag("spicepack")
--             if items then
--                 for _, item in ipairs(items) do
--                     DropAndPickup(item, inst)
--                 end
--             end
--         end
--     else
--         local inventory = inst.components.inventory
--         if inventory then
--             local items = inventory:GetItemsWithTag("spicepack")
--             if items then
--                 for _, item in ipairs(items) do
--                     if item.StopDappernessListener then
--                         DropAndPickup(item, inst)
--                     end
--                 end
--             end
--         end
--     end
-- end

-- AddPrefabPostInit("warly", function(inst)
--     -- 监听技能激活和取消
--     local onskillrefresh_client = function(inst) UpdatePiePotSpells(inst) end
--     local onskillrefresh_server = function(inst) UpdatePiePotSpells(inst) end
--     inst:ListenForEvent("onactivateskill_server", onskillrefresh_server)
--     inst:ListenForEvent("ondeactivateskill_server", onskillrefresh_server)
--     inst:ListenForEvent("onactivateskill_client", onskillrefresh_client)
--     inst:ListenForEvent("ondeactivateskill_client", onskillrefresh_client)
-- end)
