local assets = {}

local function StartDecayTask(inst, target)
    -- 开始原来的缓慢衰减（每8秒掉1点）
    if inst._warly_pie_task then
        inst._warly_pie_task:Cancel()
        inst._warly_pie_task = nil
    end

    inst._warly_pie_task = inst:DoPeriodicTask(8, function()
        -- local remaining = inst.components.timer:GetTimeLeft("explode") or 0
        -- print("画大饼debuff剩余时间", remaining)
        if target and target:IsValid() then
            if target.components.hunger then
                target.components.hunger:DoDelta(-1)
            end
            if target.components.sanity then
                target.components.sanity:DoDelta(-1)
            end
        else
            inst:Remove()
        end
    end)
end

local function OnAttached(inst, target)
    inst.target = target

    -- 如果目标无效直接移除
    if not (target and target:IsValid()) then
        inst:Remove()
        return
    end

    -- 1.1 秒后强制开始衰减
    inst:DoTaskInTime(1.1, function()
        if not inst._warly_pie_task then
            StartDecayTask(inst, target)
        end
    end)
end

local function OnDetached(inst)
    if inst._warly_pie_task then
        inst._warly_pie_task:Cancel()
        inst._warly_pie_task = nil
    end

    inst:Remove()
end

local function OnTimerDone(inst, data)
    if data.name == "explode" then
        inst.components.debuff:Stop()
    end
end

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

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("explode", 400)
    inst:ListenForEvent("timerdone", OnTimerDone)

    return inst
end

return Prefab("warly_sky_pie_buff", fn, assets)
