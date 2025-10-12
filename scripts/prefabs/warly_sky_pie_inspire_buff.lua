local assets = {}

local DECAY_INTERVAL = 8 -- 每8秒衰减一次

------------------------------------------------------------
-- 启动逐步衰减任务
------------------------------------------------------------
local function StartDecayTask(inst, target)
    if inst._decay_task then
        return
    end

    inst._decay_task = inst:DoPeriodicTask(DECAY_INTERVAL, function()
        if not (target and target:IsValid()) then
            inst.components.debuff:Stop()
            return
        end

        local done = true

        -- 饥饿
        if inst._restore_hunger and inst._restore_hunger > 0 and target.components.hunger then
            target.components.hunger:DoDelta(-1)
            inst._restore_hunger = inst._restore_hunger - 1
            done = false
        end

        -- 理智
        if inst._restore_sanity and inst._restore_sanity > 0 and target.components.sanity then
            target.components.sanity:DoDelta(-1)
            inst._restore_sanity = inst._restore_sanity - 1
            done = false
        end

        -- 生命
        if inst._restore_health and inst._restore_health > 0 and target.components.health then
            target.components.health:DoDelta(-1, true, "warly_sky_pie_buff")
            inst._restore_health = inst._restore_health - 1
            done = false
        end

        if done then
            inst.components.debuff:Stop()
        end
    end)
end

------------------------------------------------------------
-- Buff 附着时
------------------------------------------------------------
local function OnAttached(inst, target)
    inst.target = target
    if not (target and target:IsValid()) then
        inst:Remove()
        return
    end

    -- 计算补满值并记录
    local hunger_added, sanity_added, health_added = 0, 0, 0

    if target.components.hunger then
        local hunger = target.components.hunger
        local delta = hunger.max - hunger.current
        hunger:DoDelta(delta)
        hunger_added = math.floor(delta)
    end

    if target.components.sanity then
        local sanity = target.components.sanity
        local delta = sanity.max - sanity.current
        sanity:DoDelta(delta)
        sanity_added = math.floor(delta)
    end

    if target.components.health then
        local health = target.components.health
        local delta = health.maxhealth - health.currenthealth
        health:DoDelta(delta, true, "warly_sky_pie_buff")
        health_added = math.floor(delta)
    end

    inst._restore_hunger = hunger_added
    inst._restore_sanity = sanity_added
    inst._restore_health = health_added

    inst:DoTaskInTime(1, function()
        if inst:IsValid() then
            StartDecayTask(inst, target)
        end
    end)
end

------------------------------------------------------------
-- Buff 移除
------------------------------------------------------------
local function OnDetached(inst)
    if inst._decay_task then
        inst._decay_task:Cancel()
        inst._decay_task = nil
    end
    inst:Remove()
end

------------------------------------------------------------
-- 实体定义
------------------------------------------------------------
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddFollower()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(OnDetached)
    inst.components.debuff.keepondespawn = true

    return inst
end

return Prefab("warly_sky_pie_inspire_buff", fn, assets)
