-- 吃独食 Eat Alone
-- 1 骨头汤：获得5分钟概率骨甲效果
-- 2 鲜果可丽饼：获得5分钟锁定85%san
-- 3 海鲜杂烩：获得5分钟敌人越多移速越快
-- 4 蓬松土豆蛋奶酥：获得5分钟攻击力加成（200以上两倍，50-200线性变化，50以下1倍）
-- 5 怪物鞑靼：同时雇佣5个猪人，满时间2.5天
-- 6.1 分享效果 6.2 分享效果
-- 7.1 独食效果 7.2 独食效果

--========================================================
-- Warly 专属食物 Buff 系统，4个原版无buff的食物
--========================================================

-- Buff 持续时间（单位：秒）
local BONESOUP_BUFF_TIME    = 300
local CROISSANT_BUFF_TIME   = 300
local SEAFOOD_BUFF_TIME     = 300
local POTATO_BUFF_TIME      = 300

--========================================================
-- 食物 → Buff 映射表
--========================================================
local FOOD_BUFF_MAP = {
    bonesoup          = { buffname = "warly_bonesoup_buff",    time = BONESOUP_BUFF_TIME },
    freshfruitcrepes  = { buffname = "warly_crepes_buff",      time = CROISSANT_BUFF_TIME },
    moqueca           = { buffname = "warly_seafood_buff",     time = SEAFOOD_BUFF_TIME },
    potatosouffle     = { buffname = "warly_potato_buff",      time = POTATO_BUFF_TIME },
}

--========================================================
-- 吃食物时触发
--========================================================
local function OnEat(inst, food)
    if inst.prefab ~= "warly" or not (food and food.prefab) then
        return
    end

    local buffdata
    for name, data in pairs(FOOD_BUFF_MAP) do
        if string.find(food.prefab, name) then
            buffdata = data
            break
        end
    end

    if not buffdata then
        return
    end

    local buffname = buffdata.buffname
    local bufftime = buffdata.time

    if not inst:HasDebuff(buffname) then
        inst:AddDebuff(buffname, buffname)
        print("[Warly Buff] Added:", buffname, "for", bufftime, "seconds")
    else
        -- 先删除已有的 buff
        inst:RemoveDebuff(buffname)
        print("[Warly Buff] Removed existing buff:", buffname)

        -- 添加新的 buff
        inst:AddDebuff(buffname, buffname)
        print("[Warly Buff] Added new buff:", buffname, "for", bufftime, "seconds")
    end

end

--========================================================
-- 添加监听
--========================================================
local function AddListener(inst)
    if inst.prefab ~= "warly" then
        return
    end

    if not inst._warly_food_listener then
        inst._warly_food_listener = function(inst, data)
            OnEat(inst, data.food)
        end
        inst:ListenForEvent("oneat", inst._warly_food_listener)
        -- print("[Warly Buff] 食物监听已启用")
    end
end

AddPlayerPostInit(AddListener)



--========================================================
-- 怪物鞑靼：同时雇佣5个猪人，满时间2.5天
--========================================================
local function HireNearbyPigmen(inst, giver)
    local x, y, z = inst.Transform:GetWorldPosition()
    -- 搜索25格范围内的猪人（排除守卫和狼人）
    local ents = TheSim:FindEntities(x, y, z, 25, { "pig" }, { "guard", "werepig" })

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
                pig.components.follower.maxfollowtime = TUNING.PIG_LOYALTY_MAXTIME
                pig.components.combat:SetTarget(nil)

                -- 拍手欢呼动画
                if pig.sg ~= nil and pig.sg:HasState("dropitem") then
                    pig.sg:GoToState("dropitem")
                end

                -- 发出猪叫声
                pig.SoundEmitter:PlaySound("dontstarve/pig/oink")

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

        -- 触发怪物鞑靼效果
        if item ~= nil and item.prefab == "monstertartare" and giver ~= nil then
            HireNearbyPigmen(inst, giver)
        end
    end

    inst.components.trader.onaccept = NewOnGetItemFromPlayer
end)



--========================================================
-- 终极技能：沃利吃东西分享效果给周围友方（dummy 食物方案）
--========================================================
local SHARE_RADIUS = 6 -- 分享半径

local function ShareFoodEffects(eater, food)
    if eater == nil or not eater:IsValid() then return end
    if food == nil or not food:IsValid() then return end

    local x, y, z = eater.Transform:GetWorldPosition()
    -- 只搜索玩家
    local players = TheSim:FindEntities(x, y, z, SHARE_RADIUS, { "player" }, { "playerghost", "INLIMBO" })

    for _, ally in ipairs(players) do
        if ally ~= eater and ally.prefab ~= "warly" and ally:IsValid() and ally.components.health ~= nil and not ally.components.health:IsDead() then
            -- 创建 dummy 食物
            local dummy = SpawnPrefab(food.prefab)
            if dummy ~= nil then
                -- 属性归零，不增加血量/饥饿/精神
                if dummy.components.edible ~= nil then
                    dummy.components.edible.healthvalue = 0
                    dummy.components.edible.hungervalue = 0
                    dummy.components.edible.sanityvalue = 0
                end

                -- 玩家“吃” dummy
                if ally.components.eater ~= nil then
                    local success = ally.components.eater:Eat(dummy)
                    -- 提示获得 buff，显示友好名称
                    if success and ally.components.talker ~= nil then
                        -- local food_name = food:GetDisplayName() or food.prefab
                        -- local text = string.format("I received a buff from %s!", food_name)
                        -- ally.components.talker:Say(text)
                    else
                        dummy:Remove()
                        -- print("[Warly Buff] Failed to share food effect to", ally:GetDisplayName() or ally.prefab)
                    end
                end
            end
        end
    end
end

-- Hook Eater:Eat 只针对沃利
AddComponentPostInit("eater", function(self)
    local _OldEat = self.Eat
    function self:Eat(food, ...)
        local result = _OldEat(self, food, ...) -- 原逻辑先执行

        -- 只对沃利生效
        if self.inst.prefab == "warly" then
            ShareFoodEffects(self.inst, food)
        end

        return result
    end
end)


