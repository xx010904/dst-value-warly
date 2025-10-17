local BUFF_DURATION = 300        -- 5分钟
local TARGET_SAN_PERCENT = 0.9   -- san目标百分比

-- 每分钟恢复量设定
local SANITY_RECOVER_COMBAT = 9
local SANITY_RECOVER_IDLE = 45

-- 每秒更新一次（包括冷却递减与理智恢复）
local UPDATE_PERIOD = 1
local COMBAT_COOLDOWN_SECONDS = 10

local function _OnCombatEvent(inst, target)
    -- 任何一次攻击或被攻击都会触发冷却（重置为10）
    inst._crepes_combat_cooldown = COMBAT_COOLDOWN_SECONDS
end

local function StartSanityControl(inst, target)
    if not (target and target.components.sanity) then
        return
    end

    -- 清除之前的 periodic 任务（如果有）
    if inst._crepes_sanity_control_task then
        inst._crepes_sanity_control_task:Cancel()
        inst._crepes_sanity_control_task = nil
    end

    -- 清除并重置任何旧的监听
    if inst._crepes_listeners then
        for _, v in pairs(inst._crepes_listeners) do
            if v.event and v.fn and target then
                target:RemoveEventCallback(v.event, v.fn, v.source or target)
            end
        end
    end
    inst._crepes_listeners = {}

    -- 初始化冷却（0 表示非冷却状态）
    inst._crepes_combat_cooldown = 0

    -- 一开始 san 清零（和你原逻辑一致）
    target.components.sanity:SetPercent(0)

    -- 监听被攻击与攻击事件：被攻击一般发 "attacked"，主动攻击常用 "onattack"
    local attacked_fn = function() _OnCombatEvent(inst, target) end
    local onattack_fn = function() _OnCombatEvent(inst, target) end

    target:ListenForEvent("attacked", attacked_fn, target)   -- 被攻击
    target:ListenForEvent("onattackother", onattack_fn, target)   -- 主动攻击（通用事件）
    -- 记录以便移除
    table.insert(inst._crepes_listeners, { event = "attacked", fn = attacked_fn, source = target })
    table.insert(inst._crepes_listeners, { event = "onattackother", fn = onattack_fn, source = target })

    -- 每秒任务：递减冷却并按状态恢复理智（但不超过目标百分比上限）
    inst._crepes_sanity_control_task = target:DoPeriodicTask(UPDATE_PERIOD, function()
        if not (target and target.components.sanity) then
            return
        end

        -- 冷却递减（若>0）
        if inst._crepes_combat_cooldown and inst._crepes_combat_cooldown > 0 then
            inst._crepes_combat_cooldown = inst._crepes_combat_cooldown - UPDATE_PERIOD
            if inst._crepes_combat_cooldown < 0 then
                inst._crepes_combat_cooldown = 0
            end
        end

        local max_san = target.components.sanity.max * TARGET_SAN_PERCENT
        local cur_san = target.components.sanity.current or 0

        if cur_san < max_san then
            -- 冷却期间恢复较慢，非冷却恢复快
            local per_min = (inst._crepes_combat_cooldown and inst._crepes_combat_cooldown > 0) and SANITY_RECOVER_COMBAT or SANITY_RECOVER_IDLE
            local rate_per_sec = per_min / 60
            target.components.sanity.current = math.min(cur_san + rate_per_sec * UPDATE_PERIOD, max_san)
        end
    end, UPDATE_PERIOD)
end

local function StopSanityControl(inst, target)
    -- 取消 periodic 任务
    if inst._crepes_sanity_control_task then
        inst._crepes_sanity_control_task:Cancel()
        inst._crepes_sanity_control_task = nil
    end

    -- 移除监听
    if inst._crepes_listeners and target then
        for _, v in pairs(inst._crepes_listeners) do
            if v.event and v.fn and v.source then
                v.source:RemoveEventCallback(v.event, v.fn, v.source)
            end
        end
    end
    inst._crepes_listeners = nil
    inst._crepes_combat_cooldown = nil
end

local function OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    target:AddTag("warly_crepes_buff")

    StartSanityControl(inst, target)
    if target.components.talker then
        target.components.talker:Say(GetString(target, "ANNOUNCE_CREPES_BUFF_ATTACHED"))
    end

    -- Buff持续5分钟
    inst.components.timer:StartTimer("expire", BUFF_DURATION)
end

local function OnDetached(inst, target)
    StopSanityControl(inst, target)
    if target and target.components.talker then
        target.components.talker:Say(GetString(target, "ANNOUNCE_CREPES_BUFF_DETACHED"))
    end
    if target then
        target:RemoveTag("warly_crepes_buff")
    end
    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddFollower()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("debuff")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(OnDetached)
    inst.components.debuff.keepondespawn = true

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", function(inst, data)
        if data.name == "expire" then
            inst.components.debuff:Stop()
        end
    end)

    return inst
end

return Prefab("warly_crepes_buff", fn)
