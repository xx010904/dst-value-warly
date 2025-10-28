local MIN_DURATION = 400
local MAX_DURATION = 800
local TICK_RATE = 10 -- 每多少秒 tick 一次
local TICK_AMOUNT = 0.5 -- 每次 tick 恢复多少

-- 根据当前饥饿度计算buff持续时间
local function CalcBuffDuration(target)
    if not target or not target.components.hunger then
        return MIN_DURATION
    end
    local hunger = target.components.hunger.current
    local max_hunger = target.components.hunger.max
    -- 饥饿越低，持续时间越长
    local factor = 1 - math.clamp(hunger / max_hunger, 0, 1)
    return MIN_DURATION + factor * (MAX_DURATION - MIN_DURATION)
end

local function ClearFoodMemory(target, foodPrefab, firstTime)
    if target.components.skilltreeupdater and target.components.skilltreeupdater:IsActivated("warly_true_delicious_memory") then
        if target.components.foodmemory and target.components.foodmemory.foods then
            local foods = target.components.foodmemory.foods
            if foods[foodPrefab] then
                if target.components.talker and not firstTime then
                    local str = subfmt(GetString(target, "ANNOUNCE_FORGET_FOOD"),
                        { food = STRINGS.NAMES[string.upper(foodPrefab)] })
                    target.components.talker:Say(str)
                end
                foods[foodPrefab] = nil
            end
        end
    end
end

local function OnTick(inst, target)
    if not (target and target.components.health and not target.components.health:IsDead() and not target:HasTag("playerghost")) then
        inst.components.debuff:Stop()
        return
    end
    local fx = SpawnPrefab("abigail_rising_twinkles_fx")
    target:AddChild(fx)

    if target.components.health then
        target.components.health:DoDelta(TICK_AMOUNT, nil, "warly_truedelicious_buff")
    end
    if target.components.hunger then
        target.components.hunger:DoDelta(TICK_AMOUNT)
    end
    if target.components.sanity then
        target.components.sanity:DoDelta(TICK_AMOUNT)
    end

    ClearFoodMemory(target, inst.foodPrefab, false)
end

local function OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0)

    inst:DoTaskInTime(1 * FRAMES, function(inst)
        if not target then
            return
        end
        local duration = CalcBuffDuration(target)
        inst.components.timer:StartTimer(inst.foodPrefab .. "warly_buff_duration", duration)
        inst.task = inst:DoPeriodicTask(TICK_RATE, OnTick, nil, target)
    end)

    -- 清除一次该食物的记忆
    inst:DoTaskInTime(1, function(inst)
        ClearFoodMemory(target, inst.foodPrefab, true)
    end)

    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)
end

local function OnTimerDone(inst, data)
    if data.name == inst.foodPrefab .. "warly_buff_duration" then
        inst.components.debuff:Stop()
    end
end

local function OnExtended(inst, target)
    if target and target.components.hunger and inst.components.timer then
        inst:DoTaskInTime(1 * FRAMES, function(inst)
            if not target then
                return
            end
            local duration = CalcBuffDuration(target)
            local left = inst.components.timer:GetTimeLeft(inst.foodPrefab .. "warly_buff_duration") or 0
            inst.components.timer:SetTimeLeft(inst.foodPrefab .. "warly_buff_duration", left + duration)
            print(string.format("续真香buff，目前剩余时间: %.2f, 食物: %s",
                inst.components.timer:GetTimeLeft(inst.foodPrefab .. "warly_buff_duration") or 0,
                inst.foodPrefab))
        end)
    end

    if inst.task then
        inst.task:Cancel()
    end
    inst.task = inst:DoPeriodicTask(TICK_RATE, OnTick, nil, target)

    -- 清除一次该食物的记忆
    inst:DoTaskInTime(1, function(inst)
        ClearFoodMemory(target, inst.foodPrefab, true)
    end)
end

local function OnSave(inst, data)
    if inst.foodPrefab then
        data.foodPrefab = inst.foodPrefab
    end
end

local function OnLoad(inst, data)
    if data and data.foodPrefab then
        inst.foodPrefab = data.foodPrefab
    end
end

local function fn()
    local inst = CreateEntity()

    if not TheWorld.ismastersim then
        inst:DoTaskInTime(0, inst.Remove)
        return inst
    end

    inst.entity:AddTransform()
    inst.entity:Hide()
    inst.persists = false
    inst.foodPrefab = "meatballs"

    inst:AddTag("CLASSIFIED")

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(inst.Remove)
    inst.components.debuff:SetExtendedFn(OnExtended)
    inst.components.debuff.keepondespawn = true

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", OnTimerDone)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("warly_truedelicious_buff", fn)
