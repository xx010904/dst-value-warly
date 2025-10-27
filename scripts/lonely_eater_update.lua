-- 美食鉴赏 (解决做菜下线，解决联机料理太少)
-- 沃利是一个高端寂寞的美食家，只有他可以尝出来某些料理中的深层底蕴；沃利对每道菜都有自己独到的深层次的见解，也能将感受分享给伙伴
-- Section 1：吃独食 Eat Alone
-- 1 骨头汤：获得5分钟概率骨甲效果
-- 2 鲜果可丽饼：获得5分钟锁定85%san
-- 3 海鲜杂烩：获得5分钟敌人越多移速越快
-- 4 蓬松土豆蛋奶酥：获得5分钟攻击力加成（200以上两倍，50-200线性变化，50以下1倍）

-- Section 2：分享食物 Share Food
-- 5.1 怪物鞑靼：额外的，同时雇佣5个猪人，满时间2.5天，也能吃到怪物鞑靼的调味料
-- 5.2 沃利吃东西时，分享料理和调味料的buff给所有雇佣的猪人，以及附近的玩家

--========================================================
-- Warly 专属食物 Buff 系统，4个原版无buff的食物
--========================================================

local FOOD_BUFF_MAP = {
    bonesoup = {
        buffname = "warly_bonesoup_buff",
        required_skill = "warly_bonesoup_buff",
    },
    freshfruitcrepes = {
        buffname = "warly_crepes_buff",
        required_skill = "warly_crepes_buff",
    },
    moqueca = {
        buffname = "warly_seafood_buff",
        required_skill = "warly_seafood_buff",
    },
    potatosouffle = {
        buffname = "warly_potato_buff",
        required_skill = "warly_potato_buff",
    },
}


--========================================================
-- 吃食物时触发新的4个buff
--========================================================
AddPlayerPostInit(function(inst)
    if inst.prefab ~= "warly" then
        return
    end

    inst:ListenForEvent("oneat", function(inst, data)
        local food = data.food
        if inst.prefab ~= "warly" or not (food and food.prefab) then
            return
        end

        local buffdata
        for name, data2 in pairs(FOOD_BUFF_MAP) do
            if string.find(food.prefab, name) then
                buffdata = data2
                break
            end
        end

        if not buffdata then
            return
        end

        local required_skill = buffdata.required_skill
        local hasSkill = required_skill and inst.components.skilltreeupdater and
            inst.components.skilltreeupdater:IsActivated(required_skill)
        if not hasSkill then --技能树控制
            -- if not true then
            -- print("[Warly Buff] Missing skill:", required_skill, "- Buff not applied.")
            return
        end

        local buffname = buffdata.buffname

        if not inst:HasDebuff(buffname) then
            inst:AddDebuff(buffname, buffname)
            -- print("[Warly Buff] Added:", buffname)
        else
            inst:RemoveDebuff(buffname)
            inst:AddDebuff(buffname, buffname)
            -- print("[Warly Buff] Refreshed:", buffname)
        end
    end)
end)


--========================================================
-- 怪物鞑靼：额外同时雇佣5个猪人，满时间2.5天
--========================================================
-- 给🐷哥会挖矿
AddStategraphState("pig",
    State {
        name = "mine",
        tags = { "mining" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                if inst.bufferedaction ~= nil then
                    PlayMiningFX(inst, inst.bufferedaction.target)
                end
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    })
AddStategraphActionHandler("pig", ActionHandler(ACTIONS.MINE, "mine"))

local warlypigbrain = require "brains/warlypigbrain"

local function changeWere(pig)
    pig:AddTag("werepig_warly")

    if pig.components.trader then
        pig.components.trader:Disable()
    end
    if pig.components.sleeper then
        pig.components.sleeper:SetResistance(30)
    end
    if pig.AnimState ~= nil then
        pig.AnimState:SetBuild("werepig_build")
        pig.AnimState:OverrideSymbol("pig_belt", "pig_token", "pig_belt")
    end
    if pig.components.combat ~= nil then
        pig.components.combat:SetDefaultDamage(TUNING.WEREPIG_DAMAGE)
        pig.components.combat:SetAttackPeriod(TUNING.WEREPIG_ATTACK_PERIOD)
    end
    if pig.components.locomotor ~= nil then
        pig.components.locomotor.runspeed = TUNING.WEREPIG_RUN_SPEED
        pig.components.locomotor.walkspeed = TUNING.WEREPIG_WALK_SPEED
    end
    if pig.components.lootdropper ~= nil then
        pig.components.lootdropper:SetLoot({ "meat", "meat", "pigskin" })
        pig.components.lootdropper.numrandomloot = 0
    end
    if pig.components.health ~= nil then
        pig.components.health:SetMaxHealth(TUNING.WEREPIG_HEALTH)
        pig.components.health:StartRegen(-1, 2)
        -- pig.components.health:SetAbsorptionAmount(0.8)
    end
    if pig.components.werebeast then
        pig.components.werebeast:SetOnWereFn(nil)
        pig.components.werebeast:SetOnNormalFn(nil)
        pig.components.werebeast.SetNormal = function () end
        -- pig.components.werebeast:WatchWorldState("isfullmoon", function(self, isfullmoon)
        --     if not isfullmoon then
        --         self.inst.components.health:Kill()
        --     end
        -- end)
    end
    pig:SetBrain(warlypigbrain)
end

local function HireNearbyPigmen(inst, giver, item)
    local x, y, z = inst.Transform:GetWorldPosition()
    -- 搜索25格范围内的猪人（排除守卫和疯猪）
    local ents = TheSim:FindEntities(x, y, z, 25, { "pig" }, { "guard", "werepig", "werepig_warly" })

    -- 先排序：按忠诚度从低到高排列（没有follower组件的排在最前）
    table.sort(ents, function(a, b)
        local fa = (a.components.follower and a.components.follower:GetLoyaltyPercent()) or 0
        local fb = (b.components.follower and b.components.follower:GetLoyaltyPercent()) or 0
        return fa < fb
    end)

    local count = 0
    for _, pig in ipairs(ents) do
        if pig ~= inst and pig:IsValid() and pig.components.follower ~= nil and pig.components.combat ~= nil then
            -- 避免重复雇佣同一个领导者
            if giver.components.leader ~= nil and pig.components.follower.leader ~= giver then
                giver:PushEvent("makefriend")
                giver.components.leader:AddFollower(pig)
                pig.components.follower:AddLoyaltyTime(TUNING.PIG_LOYALTY_MAXTIME)
                pig.components.combat:SetTarget(nil)

                -- 拍手欢呼动画
                if pig.sg ~= nil and pig.sg:HasState("dropitem") then
                    pig.sg:GoToState("dropitem")
                end

                -- 发出猪叫声
                pig.SoundEmitter:PlaySound("dontstarve/pig/oink")

                -- 为了增加怪物鞑靼的调味料buff
                if pig.components.eater ~= nil then
                    local dummy = SpawnPrefab(item.prefab)
                    if dummy then
                        -- 属性归零，不增加血量/饥饿/精神
                        if dummy.components.edible ~= nil then
                            dummy.components.edible.healthvalue = 0
                            dummy.components.edible.hungervalue = 0
                            dummy.components.edible.sanityvalue = 0
                            dummy.components.edible.foodtype = FOODTYPE.GENERIC
                            dummy:AddTag("dummyfood")
                            local success = pig.components.eater:Eat(dummy)
                            if not success then
                                dummy:Remove()
                            end
                        end
                    end
                end

                -- ======= 变成疯猪逻辑 =======
                if pig.components.health ~= nil then
                    pig.components.health:SetPercent(1)
                end
                changeWere(pig)
                -- ==========================
                count = count + 1
                if count >= 5 then
                    break
                end
            end
        end
    end

    -- 中心猪人（被喂食者）播放强化特效
    inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
    if inst.sg ~= nil and inst.sg:HasState("funnyidle") then
        inst.sg:GoToState("funnyidle")
    end

    if item then
        item:Remove()
    end
end

-- 挂钩猪人的交易逻辑
AddPrefabPostInit("pigman", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    local _old_OnGetItemFromPlayer = inst.components.trader.onaccept

    local function NewOnGetItemFromPlayer(inst, giver, item)
        -- 调用原逻辑
        if _old_OnGetItemFromPlayer ~= nil then
            _old_OnGetItemFromPlayer(inst, giver, item)
        end

        -- 触发怪物鞑靼效果，技能树控制
        local hasSkill = giver and giver.components.skilltreeupdater and
            giver.components.skilltreeupdater:IsActivated("warly_monstertartare_buff")
        if hasSkill and item and string.find(item.prefab, "monstertartare") then
            HireNearbyPigmen(inst, giver, item)
            if inst.components.health ~= nil then
                inst.components.health:SetPercent(1)
            end
            changeWere(inst)
            if item then
                item:Remove()
            end
        end
    end

    inst.components.trader.onaccept = NewOnGetItemFromPlayer

    -- 禁止回血
    inst:ListenForEvent("healthdelta", function(inst, data)
        -- 如果新血量比旧血量高，说明是回血事件
        if data.newpercent > data.oldpercent then
            -- 设置健康值回到原来的状态
            inst.components.health:SetPercent(data.oldpercent)
        end
    end)

    -- 保存与加载
    local old_OnSave = inst.OnSave
    inst.OnSave = function(inst, data)
        if old_OnSave then
            old_OnSave(inst, data)
        end
        if inst:HasTag("werepig_warly") then
            data.werepig_warly = true
            data.current_health = inst.components.health and inst.components.health.currenthealth or nil
        end
    end
    local old_OnLoad = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if old_OnLoad then
            old_OnLoad(inst, data)
        end
        if data.werepig_warly then
            inst:DoTaskInTime(0, function()
                changeWere(inst)
                if data.current_health and inst.components.health then
                    inst.components.health.currenthealth = data.current_health
                end
            end)
        end
    end
end)



--========================================================
-- 终极技能：沃利吃东西分享效果给周围友方（dummy 食物方案）
--========================================================
local SHARE_RADIUS = 12 -- 分享半径

local function ShareFoodEffects(eater, food)
    if eater == nil or not eater:IsValid() then return end
    if food == nil or not food:IsValid() then return end

    local x, y, z = eater.Transform:GetWorldPosition()

    -- 分享给附近玩家
    local players = TheSim:FindEntities(x, y, z, SHARE_RADIUS, { "player" }, { "playerghost", "INLIMBO" })
    for _, ally in ipairs(players) do
        if ally ~= eater
            and ally.prefab ~= "warly"
            and ally:IsValid()
            and ally.components.health ~= nil
            and not ally.components.health:IsDead()
        then
            local dummy = SpawnPrefab(food.prefab)
            if dummy ~= nil then
                if dummy.components.edible ~= nil then
                    dummy.components.edible.healthvalue = 0
                    dummy.components.edible.hungervalue = 0
                    dummy.components.edible.sanityvalue = 0
                    dummy.components.edible.foodtype = FOODTYPE.GOODIES
                    dummy:AddTag("dummyfood")
                end

                if ally.components.eater ~= nil then
                    local success = ally.components.eater:Eat(dummy)
                    if success then
                        SpawnPrefab("winters_feast_depletefood").Transform:SetPosition(ally.Transform:GetWorldPosition())
                    else
                        dummy:Remove()
                        print("[Warly Buff] Failed to share food effect to", ally:GetDisplayName() or ally.prefab)
                    end
                end
            end
        end
    end

    -- 分享给沃利的随从（所有的）
    if eater.components.leader ~= nil then
        -- 获取所有跟随者
        for follower, _ in pairs(eater.components.leader.followers) do
            if follower ~= nil
                and follower:IsValid()
                and follower.components.health ~= nil
                and not follower.components.health:IsDead()
            then
                local dummy = SpawnPrefab(food.prefab)
                if dummy ~= nil then
                    if dummy.components.edible ~= nil then
                        dummy.components.edible.healthvalue = 0
                        dummy.components.edible.hungervalue = 0
                        dummy.components.edible.sanityvalue = 0
                        dummy.components.edible.foodtype = FOODTYPE.GENERIC
                        dummy:AddTag("dummyfood")
                    end

                    if follower.components.eater ~= nil then
                        local success = follower.components.eater:Eat(dummy)
                        if success then
                            SpawnPrefab("winters_feast_depletefood").Transform:SetPosition(follower.Transform
                                :GetWorldPosition())
                        else
                            dummy:Remove()
                            print("[Warly Buff] Failed to share food effect to follower", follower.prefab)
                        end
                    end
                end
            end
        end
    end
end


-- 监听吃事件 只针对沃利
AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return
    end

    -- 只针对沃利，技能树控制
    if inst.prefab == "warly" then
        inst:ListenForEvent("oneat", function(inst, data)
            local hasSkill = inst and inst.components.skilltreeupdater and
                inst.components.skilltreeupdater:IsActivated("warly_share_buff")
            if data and data.food ~= nil and hasSkill then
                local food = data.food
                -- local feeder = data.feeder
                -- print("沃利吃食物分享buff", food.prefab)
                ShareFoodEffects(inst, food)
            end
        end)
    end
end)
