local function damage_nearby(inst, target)
    if not target or not target:IsValid() then return end
    local x, y, z = target.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 3, {"_combat"}, {"player"})
    for _, ent in ipairs(ents) do
        if ent.components.health and not ent:HasTag("player") then
            ent.components.health:DoDelta(-5) -- 每 tick 造成 5 点伤害
        end
    end
end

local function OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    inst._target = target

    -- 定期造成伤害
    inst._damagetask = inst:DoPeriodicTask(1, function() damage_nearby(inst, target) end)

    -- 持续时间
    inst.components.timer:StartTimer("lifetime", inst._duration or 5)
end

local function OnDetached(inst)
    if inst._damagetask then
        inst._damagetask:Cancel()
        inst._damagetask = nil
    end
    inst._target = nil
    inst:Remove()
end

local function ontimerdone(inst, data)
    if data.name == "lifetime" then
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

    inst.AnimState:SetBank("sporecloud")
    inst.AnimState:SetBuild("sporecloud")
    inst.AnimState:PlayAnimation("sporecloud_pre")
    inst.AnimState:SetLightOverride(.3)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(OnDetached)
    inst.components.debuff.keepondespawn = true

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)

    return inst
end

return Prefab("spoiled_cloud_buff", fn)
