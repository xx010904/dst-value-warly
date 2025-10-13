-- 厨艺
-- 拥有精湛厨艺的厨师并不依赖炊具，甚至不依赖食材，随时随地即兴发挥做出一桌好菜
-- Section 1：下饭操作 Meal-worthy Play
-- 1 “沃利看到别人做出垃圾料理时，被激发厨师灵魂，做出下饭菜”，展示厨艺，当场跟陪一份下饭菜：就地自动烹饪一份随机下饭菜
--   胡乱烹饪：潮湿黏糊，粉末蛋糕，怪物千层饼，怪物鞑靼，曼德拉草汤
--   胡乱烤：曼德拉草 夜莓 高脚鸟蛋 孵化中的高脚鸟蛋 红蘑菇 月亮蘑菇 象鼻、冬象鼻 龙虾 4种季节鱼 鼹鼠
--   胡乱吃（通用）：独眼巨鹿眼球 守护者之角 蜂王浆 曼德拉草 高脚鸟蛋 孵化中的高脚鸟蛋 格罗姆的黏液 海带补丁 象鼻、冬象鼻
--   胡乱吃（玩家）：泻根糖浆
--   胡乱吃（动物）：伏特羊肉冻 彩虹糖豆 鲜果可丽饼 龙虾正餐 华夫饼 黄油 夜莓
-- 2 随机下饭菜概率含调味料
-- 3 自私回复加强：直接回饥饿精神和血量（避免食物记忆）+ 3.1 排除记忆的料理
-- 4 团队回复加强：队友死了烹饪四菜一汤 （开席） + 4.1 复活队友

-- Section 2 画大饼
-- 1 锅检测到附近有三维不满的队友，右键点击锅直接补，然后慢慢消耗
-- 2 沃利可以对自己画饼，真的做一个大饼，大饼吃了也全部回满，同锅补效果，大饼还可以烤
-- 3 画饼buff期间，可以吃食物来抵消buff，
-- 4 现烤大饼释放香味（调味料）


-- =========================================================
-- SECTION1 胡乱料理全表（含恢复与抛锅概率）
-- =========================================================
local spicedfoods = require("spicedfoods")

local FOOD_RECOVERY_TABLE = {

    -- 胡乱烹饪（锅收获触发）
    harvest_pot = {
        wetgoop        = { hunger = 15, sanity = 15, health = 15, throw_chance = 0.7 },
        powdercake     = { hunger = 10, sanity = 10, health = 10, throw_chance = 0.7 },
        monsterlasagna = { hunger = 30, sanity = 20, health = 15, throw_chance = 1.0 },
        monstertartare = { hunger = 25, sanity = 15, health = 10, throw_chance = 0.8 },
        mandrakesoup   = { hunger = 60, sanity = 60, health = 60, throw_chance = 1.0 },
    },

    -- 胡乱烤（火堆）
    cook_fire = {
        mandrake                 = { hunger = 150, sanity = 150, health = 150, throw_chance = 1.0 },
        ancientfruit_nightvision = { hunger = 20, sanity = 25, health = 10, throw_chance = 1.0 },
        tallbirdegg              = { hunger = 25, sanity = 10, health = 20, throw_chance = 1.0 },
        tallbirdegg_cracked      = { hunger = 20, sanity = 10, health = 20, throw_chance = 1.0 },
        red_cap                  = { hunger = 5, sanity = 5, health = 5, throw_chance = 0.2 },
        moon_cap                 = { hunger = 5, sanity = 5, health = 5, throw_chance = 0.2 },
        trunk_summer             = { hunger = 5, sanity = 5, health = 5, throw_chance = 0.8 },
        trunk_winter             = { hunger = 10, sanity = 10, health = 10, throw_chance = 1.0 },
        wobster_sheller_land     = { hunger = 75, sanity = 50, health = 20, throw_chance = 1.0 },
        oceanfish_small_8_inv    = { hunger = 75, sanity = 50, health = 20, throw_chance = 1.0 },
        oceanfish_small_7_inv    = { hunger = 75, sanity = 50, health = 20, throw_chance = 1.0 },
        oceanfish_small_6_inv    = { hunger = 75, sanity = 50, health = 20, throw_chance = 1.0 },
        oceanfish_medium_8_inv   = { hunger = 75, sanity = 50, health = 20, throw_chance = 1.0 },
        mole                     = { hunger = 15, sanity = 10, health = 10, throw_chance = 1.0 },
    },

    -- 胡乱吃（通用）
    eat_common = {
        deerclops_eyeball   = { hunger = 150, sanity = 150, health = 150, throw_chance = 1.0 },
        minotaurhorn        = { hunger = 150, sanity = 150, health = 150, throw_chance = 1.0 },
        royal_jelly         = { hunger = 20, sanity = 20, health = 15, throw_chance = 0.8 },
        mandrake            = { hunger = 150, sanity = 150, health = 150, throw_chance = 1.0 },
        tallbirdegg         = { hunger = 15, sanity = 15, health = 15, throw_chance = 0.7 },
        tallbirdegg_cracked = { hunger = 20, sanity = 25, health = 15, throw_chance = 0.9 },
        glommerfuel         = { hunger = 10, sanity = 15, health = 5, throw_chance = 0.7 },
        boatpatch_kelp      = { hunger = 5, sanity = 10, health = 5, throw_chance = 0.4 },
        trunk_summer        = { hunger = 20, sanity = 10, health = 10, throw_chance = 0.8 },
        trunk_winter        = { hunger = 25, sanity = 10, health = 15, throw_chance = 1.0 },
    },

    -- 胡乱吃（玩家）
    eat_player = {
        ipecacsyrup = { hunger = 15, sanity = 75, health = 10, throw_chance = 1.0 },
    },

    -- 胡乱吃（动物）
    eat_animal = {
        voltgoatjelly            = { hunger = 75, sanity = 75, health = 15, throw_chance = 1.0 },
        jellybean                = { hunger = 15, sanity = 15, health = 25, throw_chance = 0.4 },
        freshfruitcrepes         = { hunger = 75, sanity = 10, health = 15, throw_chance = 1.0 },
        lobsterdinner            = { hunger = 75, sanity = 15, health = 15, throw_chance = 1.0 },
        waffles                  = { hunger = 75, sanity = 10, health = 15, throw_chance = 1.0 },
        butter                   = { hunger = 75, sanity = 25, health = 20, throw_chance = 1.0 },
        ancientfruit_nightvision = { hunger = 10, sanity = 50, health = 10, throw_chance = 1.0 },
    },
}

-- 获取基础食物名（去掉调味前缀）
local function GetBaseFood(prefab)
    return spicedfoods[prefab] ~= nil and spicedfoods[prefab].basename or prefab
end

-- =========================================================
-- 抛锅函数
-- =========================================================
local function SpawnCookPotFX(chef, idiot, meal)
    if not chef then return end

    chef:DoTaskInTime(0.1, function()
        chef.AnimState:PlayAnimation("pyrocast")
    end)

    local x, y, z = chef.Transform:GetWorldPosition()
    local spawn_x, spawn_y, spawn_z = idiot.Transform:GetWorldPosition()

    local fx = SpawnPrefab("lucy_transform_fx")
    fx.entity:SetParent(chef.entity)
    fx.entity:AddFollower()
    fx.Follower:FollowSymbol(chef.GUID, "hair", 0, 0, 0)

    local proj = SpawnPrefab("improv_cookpot_projectile_fx")
    proj.doer = chef
    proj.meal = meal
    proj.Transform:SetPosition(x, y, z)
    proj.components.complexprojectile:Launch(Vector3(spawn_x, spawn_y, spawn_z), chef)
end

local function ApplyTalking(inst, op)
    if op == "eat_common" then
        inst.components.talker:Say(GetString(inst, "ANNOUNCE_BAD_EAT_COMMOM"))
    elseif op == "eat_player" then
        inst.components.talker:Say(GetString(inst, "ANNOUNCE_BAD_EAT_BY_PLAYER"))
    elseif op == "eat_animal" then
        inst.components.talker:Say(GetString(inst, "ANNOUNCE_BAD_EAT_BY_ANIMAL"))
    elseif op == "cook_fire" then
        inst.components.talker:Say(GetString(inst, "ANNOUNCE_BAD_COOKS_FOOD"))
    elseif op == "harvest_pot" then
        inst.components.talker:Say(GetString(inst, "ANNOUNCE_BAD_HARVESTS_POT"))
    end
end

-- =========================================================
-- 恢复处理函数
-- =========================================================
local function ApplyRecovery(inst, doer, food_name, operation)
    if not inst or not inst.components or not food_name or not operation then return end

    local rec_table = FOOD_RECOVERY_TABLE[operation]
    if not rec_table or not rec_table[food_name] then return end

    local values = rec_table[food_name]

    -- 随机浮动回复
    local hunger_base = values.hunger or 0
    local sanity_base = values.sanity or 0
    local health_base = values.health or 0

    local hunger_variation = hunger_base * 0.2
    local sanity_variation = sanity_base * 0.2
    local health_variation = health_base * 0.2

    local hunger_delta = hunger_base + (math.random() * 2 - 1) * hunger_variation
    local sanity_delta = sanity_base + (math.random() * 2 - 1) * sanity_variation
    local health_delta = health_base + (math.random() * 2 - 1) * health_variation

    inst.components.hunger:DoDelta(hunger_delta)
    inst.components.sanity:DoDelta(sanity_delta)
    inst.components.health:DoDelta(health_delta)
end

-- =========================================================
-- 沃利执行动作
-- =========================================================
local function doFunnyCook(inst, doer, food_name, op)
    if inst.prefab ~= "warly" then return end --技能树控制

    local rec_table = FOOD_RECOVERY_TABLE[op]
    local values = rec_table and rec_table[food_name]
    if not values then return end

    -- ping个问号❓
    local playerMark = SpawnPrefab("improv_question_mark_fx")
    playerMark.entity:SetParent(inst.entity)
    playerMark.Transform:SetPosition(0, 3, 0)
    local doerMark = SpawnPrefab("improv_question_mark_fx")
    doerMark.entity:SetParent(doer.entity)
    doerMark.Transform:SetPosition(0, 3, 0)

    -- 抛锅特效概率控制
    local chance = values.throw_chance or 1
    if math.random() < chance then
        inst:DoTaskInTime(0.5, function(inst)
            if inst then
                SpawnCookPotFX(inst, doer)
                -- puff 特效
                local puff = SpawnPrefab("small_puff")
                if puff then
                    local x, y, z = inst.Transform:GetWorldPosition()
                    puff.Transform:SetPosition(x, y, z)
                end
            end
        end)
    end

    -- 说话逻辑
    ApplyTalking(inst, op)

    -- 恢复逻辑
    ApplyRecovery(inst, doer, food_name, op) --技能树控制
end

-- =========================================================
-- 胡乱烹饪（锅收获触发）
-- =========================================================
AddComponentPostInit("stewer", function(stewer)
    local old_Harvest = stewer.Harvest
    stewer.Harvest = function(self, harvester)
        local product = self.product
        local result = old_Harvest and old_Harvest(self, harvester)
        if product and FOOD_RECOVERY_TABLE.harvest_pot[product] then
            for _, player in ipairs(AllPlayers) do
                if player.prefab == "warly" and harvester and player:IsNear(harvester, 12) then
                    doFunnyCook(player, harvester, product, "harvest_pot")
                end
            end
        end
        return result
    end
end)

-- =========================================================
-- 胡乱烤监听
-- =========================================================
AddComponentPostInit("cookable", function(cookable)
    local old_Cook = cookable.Cook
    cookable.Cook = function(self, cooker, chef)
        local food_name = self.inst and self.inst.prefab or nil
        local product = old_Cook and old_Cook(self, cooker, chef)
        if food_name and FOOD_RECOVERY_TABLE.cook_fire[food_name] then
            for _, player in ipairs(AllPlayers) do
                if player.prefab == "warly" and chef and player:IsNear(chef, 12) then
                    doFunnyCook(player, chef, food_name, "cook_fire")
                end
            end
        end
        return product
    end
end)

-- =========================================================
-- 胡乱吃监听
-- =========================================================
AddComponentPostInit("edible", function(edible)
    local old_OnEaten = edible.OnEaten
    edible.OnEaten = function(self, eater)
        if old_OnEaten then old_OnEaten(self, eater) end

        local food_name = self.inst.prefab
        food_name = GetBaseFood(food_name)
        for _, player in ipairs(AllPlayers) do
            if player.prefab == "warly" and eater and player:IsNear(eater, 12) then
                local operation = nil

                if FOOD_RECOVERY_TABLE.eat_common[food_name] then
                    operation = "eat_common"
                elseif eater:HasTag("player") and FOOD_RECOVERY_TABLE.eat_player[food_name] then
                    operation = "eat_player"
                elseif not eater:HasTag("player") and FOOD_RECOVERY_TABLE.eat_animal[food_name] then
                    operation = "eat_animal"
                end

                if operation then
                    doFunnyCook(player, eater, food_name, operation)
                end
            end
        end
    end
end)

-- =========================================================
-- 死亡监听开席
-- =========================================================
AddPlayerPostInit(function(dead)
    if not TheWorld.ismastersim then
        return
    end
    -- 监听玩家死亡事件
    dead:ListenForEvent("death", function(inst, data)
        local hasSkillTree = true -- 技能树控制
        if not hasSkillTree then
            return
        end
        -- 遍历所有玩家，找附近的沃利
        for _, player in ipairs(AllPlayers) do
            if player.prefab == "warly" and player:IsNear(dead, 12) then
                -- 沃利发现队友去世，哀悼 + 献上“四菜一汤”
                -- 打出问号特效
                local dead_fx = SpawnPrefab("improv_question_mark_fx")
                if dead_fx then
                    dead_fx.entity:SetParent(dead.entity)
                    dead_fx.Transform:SetPosition(0, 3, 0)
                end

                local warly_fx = SpawnPrefab("improv_question_mark_fx")
                if warly_fx then
                    warly_fx.entity:SetParent(player.entity)
                    warly_fx.Transform:SetPosition(0, 3, 0)
                end

                -- 菜谱顺序
                local dishes = { "ratatouille", "ratatouille", "ratatouille", "ratatouille", "bonesoup", }

                -- 逐个生成特效（每0.25秒）
                for i, prefab in ipairs(dishes) do
                    player:DoTaskInTime((i - 1) * 0.25, function()
                        if player:IsValid() and dead:IsValid() then
                            SpawnCookPotFX(player, dead, prefab)
                        end
                    end)
                end
            end
        end
    end, dead)
end)


-- =========================================================
-- SECTION2 可以右键点击动作“画饼”的锅
-- =========================================================
-- 1) Hook portablecookpot_item prefab，本体逻辑：扫描、激活标志、提示
AddPrefabPostInit("portablecookpot_item", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("skypieinspiretool")

    -- 内部函数：启动 / 停止 检测任务
    local function StartDetection(inst)
        if inst._detect_task == nil then
            inst._detect_task = inst:DoPeriodicTask(1, function()
                local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
                if not (owner and owner:IsValid()) then
                    inst:RemoveTag("active_pot_pie")
                    inst.pie_target = nil
                    if inst.components.inventoryitem then
                        inst.components.inventoryitem.imagename = "portablecookpot_item"
                        inst.components.inventoryitem.atlasname = "images/inventoryimages2.xml"
                    end
                    return
                end

                -- 以持有者为中心检测附近玩家
                local x, y, z = owner.Transform:GetWorldPosition()
                local players = TheSim:FindEntities(x, y, z, 10, { "player" }, { "playerghost" })

                local should_activate = false
                for _, p in ipairs(players) do
                    if p and p:IsValid() and p.prefab ~= "warly" and not p:HasDebuff("warly_sky_pie_inspire_buff") then
                        if (p.components.hunger and p.components.hunger:GetPercent() < 0.5)
                            or (p.components.sanity and p.components.sanity:GetPercent() < 0.5)
                            or (p.components.health and p.components.health:GetPercent() < 0.5) then
                            should_activate = true
                            inst.pie_target = p
                            break
                        end
                    end
                end

                if should_activate then
                    if not inst:HasTag("active_pot_pie") then
                        inst:AddTag("active_pot_pie")
                        if inst.components.inventoryitem then
                            inst.components.inventoryitem.imagename = "portablecookpot_item_actived"
                            inst.components.inventoryitem.atlasname =
                            "images/inventoryimages/portablecookpot_item_actived.xml"
                        end
                        if owner.components.talker then
                            owner.components.talker:Say(GetString(owner, "ANNOUNCE_NEED_PIE"))
                        end
                    end
                else
                    if inst:HasTag("active_pot_pie") then
                        inst:RemoveTag("active_pot_pie")
                        inst.pie_target = nil
                        if inst.components.inventoryitem then
                            inst.components.inventoryitem.imagename = "portablecookpot_item"
                            inst.components.inventoryitem.atlasname = "images/inventoryimages2.xml"
                        end
                    end
                end
            end)
        end
    end

    local function StopDetection(inst)
        if inst._detect_task ~= nil then
            inst._detect_task:Cancel()
            inst._detect_task = nil
        end
        inst:RemoveTag("active_pot_pie")
        inst.pie_target = nil
        if inst.components.inventoryitem then
            inst.components.inventoryitem.imagename = "portablecookpot_item"
            inst.components.inventoryitem.atlasname = "images/inventoryimages2.xml"
        end
    end

    -- 监听物品拾取 / 丢弃
    inst:ListenForEvent("onputininventory", function(inst, owner)
        if owner and owner:HasTag("player") then
            StartDetection(inst)
        else
            StopDetection(inst)
        end
    end)

    inst:ListenForEvent("ondropped", function(inst)
        StopDetection(inst)
    end)

    -- 如果生成时就在玩家身上，直接启动检测
    inst:DoTaskInTime(0, function()
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if owner and owner:HasTag("player") then
            StartDetection(inst)
        end
    end)
end)

-- 2) 定义自定义 Action
local ACTIVATE_POT_PIE = AddAction("ACTIVATE_POT_PIE", STRINGS.ACTIONS.ACTIVATE_POT_PIE, function(act)
    if not act or not act.doer then
        return
    end

    local inst = act.invobject -- 背包里的物品
    local doer = act.doer

    if not inst or not inst:IsValid() or not doer or not doer:IsValid() then
        return
    end

    -- 检查激活与冷却标志（以防万一）
    local target = inst.pie_target
    if not inst:HasTag("active_pot_pie") or target == nil then
        if doer.components.talker then
            doer.components.talker:Say("It's a bug.")
        end
        return
    end

    -- 给持有者添加 debuff（buff）
    if target:HasDebuff("warly_sky_pie_inspire_buff") then
        return
    else
        target:AddDebuff("warly_sky_pie_inspire_buff", "warly_sky_pie_inspire_buff")
    end

    -- 效果：动画
    if target.components.inventory:IsHeavyLifting() and not target.components.rider:IsRiding() then
        target.AnimState:PlayAnimation("heavy_eat")
    else
        target.AnimState:PlayAnimation("eat_pre")
        target.AnimState:PushAnimation("eat", false)
    end

    -- 效果：音效/特效/台词
    if target.SoundEmitter then
        target.SoundEmitter:PlaySound("dontstarve/common/cookingpot_finish")
    end
    local fx = SpawnPrefab("small_puff")
    fx.Transform:SetPosition(target.Transform:GetWorldPosition())

    if target.components.talker then
        target.components.talker:Say(GetString(target, "ANNOUNCE_EAT_PIE_REPEATLY"))
    end

    -- 物品不能使用
    inst:RemoveTag("active_pot_pie")
    inst.pie_target = nil
    inst.components.inventoryitem.imagename = "portablecookpot_item"
    inst.components.inventoryitem.atlasname = "images/inventoryimages2.xml"

    return true
end)

ACTIONS.ACTIVATE_POT_PIE.mount_valid = true

-- 3) 在 inventory 中为目标 prefab 动态添加这个 Action（右键菜单）
-- 当玩家右键背包物品时，客户端会调用这个 hook 去决定是否显示动作
AddComponentAction("INVENTORY", "skypieinspiretool", function(inst, doer, actions, right)
    -- inst：物品实体；doer：玩家实体
    -- 我们只为 portablecookpot_item 添加动作，且需要 inst._is_activated 为 true 且不在冷却
    if inst and inst.prefab == "portablecookpot_item" and inst:HasTag("active_pot_pie") then
        if doer:HasTag("masterchef") then -- 技能树控制
            table.insert(actions, ACTIONS.ACTIVATE_POT_PIE)
        end
    end
end)

-- 4) 给常见的 StateGraph 注册 ActionHandler
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.ACTIVATE_POT_PIE, "spawn_warly_sky_pie"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.ACTIVATE_POT_PIE, "spawn_warly_sky_pie"))

-- 5) 画饼的sg
AddStategraphState("wilson",
    State {
        name = "spawn_warly_sky_pie",
        tags = { "doing", "busy", "nocraftinginterrupt", "nomorph", "keep_pocket_rummage" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wormwood_cast_spawn_pre")
            inst.AnimState:PushAnimation("wormwood_cast_spawn", false)
            inst.sg.statemem.action = inst.bufferedaction
        end,

        timeline =
        {
            FrameEvent(0, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
            end),
            FrameEvent(24, function(inst)
                inst:PerformBufferedAction()
            end),
            FrameEvent(38, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            -- FrameEvent(42, TryResumePocketRummage),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action and
                (not inst.components.playercontroller or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
            -- CheckPocketRummageMem(inst)
        end,
    }
)

AddStategraphState("wilson_client",
    State {
        name = "spawn_warly_sky_pie",
        tags = { "doing", "busy" },
        server_states = { "spawn_warly_sky_pie" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wormwood_cast_spawn_pre")
            inst.AnimState:PlayAnimation("wormwood_cast_spawn_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(1)
        end,

        onupdate = function(inst)
            if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("wormwood_cast_spawn")
                inst.AnimState:SetFrame(37)
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("wormwood_cast_spawn")
            inst.AnimState:SetFrame(37)
            inst.sg:GoToState("idle", true)
        end,
    }
)

-- 6) 过量吃东西抵消画饼buff
AddComponentPostInit("eater", function(Eater)
    local old_Eater_Eat_delta_buff = Eater.Eat

    function Eater:Eat(food, feeder)
        if not food then
            return old_Eater_Eat_delta_buff(self, food, feeder)
        end

        local stack_mult = self.eatwholestack and food.components.stackable ~= nil and
            food.components.stackable:StackSize() or 1

        -- 记录当前属性值
        local hunger_comp = self.inst.components.hunger
        local sanity_comp = self.inst.components.sanity
        local health_comp = self.inst.components.health

        local cur_hunger = hunger_comp and hunger_comp.current or 0
        local cur_sanity = sanity_comp and sanity_comp.current or 0
        local cur_health = health_comp and health_comp.currenthealth or 0

        local max_hunger = hunger_comp and hunger_comp.max or 0
        local max_sanity = sanity_comp and sanity_comp.max or 0
        local max_health = health_comp and health_comp.maxhealth or 0

        -- 自行计算食物提供量
        local health_delta = food.components.edible and food.components.edible:GetHealth(self.inst) * stack_mult or 0
        local hunger_delta = food.components.edible and food.components.edible:GetHunger(self.inst) * stack_mult or 0
        local sanity_delta = food.components.edible and food.components.edible:GetSanity(self.inst) * stack_mult or 0

        -- 计算溢出量（不计算沃利的食物记忆，给沃利一点空子）
        local overflow_health = math.max((cur_health + health_delta) - max_health, 0)
        local overflow_hunger = math.max((cur_hunger + hunger_delta) - max_hunger, 0)
        local overflow_sanity = math.max((cur_sanity + sanity_delta) - max_sanity, 0)

        -- 调用原始Eat逻辑
        old_Eater_Eat_delta_buff(self, food, feeder)

        -- 扣除buff待扣量
        if self.inst:HasDebuff("warly_sky_pie_inspire_buff") then
            local buff = self.inst:GetDebuff("warly_sky_pie_inspire_buff")
            if buff then
                if overflow_hunger > 0 then
                    buff._restore_hunger = math.max(0, (buff._restore_hunger or 0) - overflow_hunger)
                    -- print("[SkyPieBuff] 饥饿抵消:", overflow_hunger, "剩余待扣", buff._restore_hunger)
                end
                if overflow_sanity > 0 then
                    buff._restore_sanity = math.max(0, (buff._restore_sanity or 0) - overflow_sanity)
                    -- print("[SkyPieBuff] 理智抵消:", overflow_sanity, "剩余待扣", buff._restore_sanity)
                end
                if overflow_health > 0 then
                    buff._restore_health = math.max(0, (buff._restore_health or 0) - overflow_health)
                    -- print("[SkyPieBuff] 生命抵消:", overflow_health, "剩余待扣", buff._restore_health)
                end
            end
        end
    end
end)
