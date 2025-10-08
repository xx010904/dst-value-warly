local assets = {}

local function OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    target:AddTag("shadow_hook_debuff")

    -- 判断 Boss 与否
    local is_boss = target:HasTag("epic") or target:HasTag("boss")

    -- 保存原始数据
    if target.components.combat then
        inst._original_damagemult = target.components.combat.damagemultiplier or 1
    end

    if target.components.locomotor then
        inst._locomotor = target.components.locomotor
        inst._locomotor:SetExternalSpeedMultiplier(target, "shadow_hook_slow", is_boss and 0.15 or 0.10)
    end

    if target.components.combat then
        target.components.combat.damagemultiplier = inst._original_damagemult * (is_boss and 0.15 or 0.10)
    end

    -- 计时自动移除
    inst.components.timer:StartTimer("expire", is_boss and 12 or 24)
end

local function OnDetached(inst, target)
    if target and target:IsValid() then
        if target.components.locomotor then
            target.components.locomotor:RemoveExternalSpeedMultiplier(target, "shadow_hook_slow")
        end
        if target.components.combat and inst._original_damagemult then
            target.components.combat.damagemultiplier = inst._original_damagemult
        end
        target:RemoveTag("shadow_hook_debuff")
    end
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

    inst.persists = false

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

return Prefab("shadow_hook_debuff", fn, assets)
