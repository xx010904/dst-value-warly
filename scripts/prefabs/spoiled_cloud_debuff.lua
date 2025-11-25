local assets = {}

local function OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    target:AddTag("spoiled_cloud_debuff")

    if not target:IsValid() then
        inst:Remove()
        return
    end

    -- 🧱 判断类别
    local is_boss = target:HasTag("epic") or target:HasTag("boss")
    local is_animal = (not is_boss) and target:HasTag("animal")

    -- 🧩 保存原始数据
    if target.components.combat then
        inst._original_damagemult = target.components.combat.damagemultiplier or 1
    end

    -- 🦶 根据类型决定倍率
    local slow_mult, duration

    if is_boss then
        -- Boss：轻微减速
        slow_mult = 0.66
        duration = 1.0
    elseif is_animal then
        -- Animal：更强debuff（几乎动不了、承受更大伤害）
        slow_mult = 0.22
        duration = 2.0
    else
        -- 其他生物
        slow_mult = 0.44
        duration = 1.5
    end

    -- 🐢 应用减速
    if target.components.locomotor then
        inst._locomotor = target.components.locomotor
        inst._locomotor:SetExternalSpeedMultiplier(target, "spoiled_cloud_slow", slow_mult)
    end

    -- ⏱️ 定时自动解除
    inst.components.timer:StartTimer("expire", duration)
end

local function OnDetached(inst, target)
    if target and target:IsValid() then
        if target.components.locomotor then
            target.components.locomotor:RemoveExternalSpeedMultiplier(target, "spoiled_cloud_slow")
        end
        target:RemoveTag("spoiled_cloud_debuff")
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

return Prefab("spoiled_cloud_debuff", fn, assets)
