local EXPLODETARGET_MUST_TAGS = { "_health", "_combat" }
local EXPLODETARGET_CANT_TAGS = { "INLIMBO", "notarget", "noattack", "flight", "invisible", "wall", "player", "companion", "structure" }

local function AlignToTarget(inst, target)
    inst.Transform:SetRotation(target.Transform:GetRotation())
end

local function OnChangeFollowSymbol(inst, target, followsymbol, followoffset)
    inst.Follower:FollowSymbol(target.GUID, followsymbol, followoffset.x, followoffset.y, followoffset.z)
end

local function damage_nearby(inst, target)
    if not target or not target:IsValid() then return end
    local x, y, z = target.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 4.88, EXPLODETARGET_MUST_TAGS, EXPLODETARGET_CANT_TAGS)
    for _, ent in ipairs(ents) do
        if ent.components.health and not ent:HasTag("player") then
            ent.components.health:DoDelta(-5.0) -- 每 tick 造成伤害
            ent.components.combat:GetAttacked(target, 0.1)
        end
    end
    local time_left = inst.components.timer:GetTimeLeft("lifetime")
    if time_left and time_left > 2 then
        for i = 1, 6 do
            local fx = SpawnPrefab("spoiled_cloud_fx")
            if fx ~= nil then
                fx.entity:SetParent(inst.entity)
                fx.Transform:SetRotation(i * 60)
            end
        end
    end
end

local function OnAttached(inst, target, followsymbol, followoffset)
    inst._target = target
    inst.entity:SetParent(target.entity)
    OnChangeFollowSymbol(inst, target, followsymbol, Vector3(followoffset.x, 100, followoffset.z)) --y越小，位置越高

    if inst._followtask ~= nil then
        inst._followtask:Cancel()
    end
    inst._followtask = inst:DoPeriodicTask(0, AlignToTarget, nil, target)
    AlignToTarget(inst, target)

    -- 定期造成伤害
    inst._damagetask = inst:DoPeriodicTask(10*FRAMES, function() damage_nearby(inst, target) end)

    -- 持续时间
    inst.components.timer:StartTimer("lifetime", 1)
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
        inst.AnimState:PlayAnimation("sporecloud_pst")
        inst:ListenForEvent("animover", function (inst)
            inst.components.debuff:Stop()
        end)
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
    inst.AnimState:PushAnimation("sporecloud_loop", true)
    inst.AnimState:SetLightOverride(.3)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.Transform:SetFourFaced()

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
