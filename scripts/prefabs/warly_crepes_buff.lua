local BUFF_DURATION = 300        -- 5分钟
local TARGET_SAN_PERCENT = 0.855 -- san目标百分比

local function StartSanityControl(inst, target)
    if target.components.sanity then
        -- 先取消之前的任务
        if inst._crepes_sanity_control_task then
            inst._crepes_sanity_control_task:Cancel()
            inst._crepes_sanity_control_task = nil
        end

        -- 一开始 san 清零
        target.components.sanity:SetPercent(0)

        -- 每帧检测
        inst._crepes_sanity_control_task = target:DoPeriodicTask(1*FRAMES, function()
            local max_san = target.components.sanity.max * TARGET_SAN_PERCENT
            if target.components.sanity.current < max_san then
                -- 快速恢复 san 到 85.5%
                target.components.sanity.current = math.min(target.components.sanity.current + 1, max_san)
            end
        end, 1*FRAMES)
    end
end

local function StopSanityControl(inst, target)
    if target then
        if inst._crepes_sanity_control_task then
            inst._crepes_sanity_control_task:Cancel()
            inst._crepes_sanity_control_task = nil
        end
    end
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
    if target.components.talker then
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
