local assets = {}

local function AddEnemyDebuffFx(fx_prefab, target, duration)
    if not (target and target:IsValid()) then
        return
    end

    -- 每隔 1 秒生成一次
    local task = target:DoPeriodicTask(1, function()
        if target:IsValid() then
            local x, y, z = target.Transform:GetWorldPosition()
            local fx = SpawnPrefab(fx_prefab)
            if fx ~= nil then
                fx.Transform:SetPosition(x, y, z)
            end
        end
    end)

    -- 持续 duration 秒后停止生成
    target:DoTaskInTime(duration, function()
        if task ~= nil then
            task:Cancel()
        end
    end)
end


local function OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    target:AddTag("shadow_hook_debuff")

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
    local slow_mult, damage_mult, duration

    if is_boss then
        -- Boss：轻微减速、轻微削弱
        slow_mult = 0.55
        damage_mult = 0.25
        duration = 12
    elseif is_animal then
        -- Animal：更强debuff（例如几乎动不了、攻击力更低）
        slow_mult = 0.15      -- 速度削
        damage_mult = 0.25    -- 攻击力削
        duration = 36         -- 多持续一点
    else
        -- 其他生物
        slow_mult = 0.35
        damage_mult = 0.25
        duration = 24
    end

    -- 🐢 应用减速
    if target.components.locomotor then
        inst._locomotor = target.components.locomotor
        inst._locomotor:SetExternalSpeedMultiplier(target, "shadow_hook_slow", slow_mult)
    end

    -- ⚔️ 应用攻击削弱
    if target.components.combat then
        target.components.combat.damagemultiplier = inst._original_damagemult * damage_mult
    end

    -- ⏱️ 定时自动解除
    inst.components.timer:StartTimer("expire", duration)

    -- 动物的话额外恐惧
    if is_animal and target.components.hauntable ~= nil and target.components.hauntable.panicable then
        target.components.hauntable:Panic(duration)
        AddEnemyDebuffFx("battlesong_instant_panic_fx", target, duration)
    end
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
