local function ontimerdone(inst, data)
    if data.name == "lifetime" then
        inst.AnimState:PlayAnimation("sporecloud_base_pst")
        inst:ListenForEvent("animover", function (inst)
            inst:Remove()
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

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("sporecloud_base")
    inst.AnimState:SetBuild("sporecloud_base")
    inst.AnimState:PlayAnimation("sporecloud_base_pre")
    inst.AnimState:PushAnimation("sporecloud_base_idle", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetFinalOffset(-1)
	inst.AnimState:SetMultColour(1, 1, 1, 0.7)
    local s = 0.87
    inst.Transform:SetScale(s, s, s)
    inst.AnimState:SetLightOverride(.3)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    -- inst.AnimState:SetDeltaTimeMultiplier(math.random() + 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    inst.Transform:SetRotation(math.random() * 360)

    -- inst.flies = inst:SpawnChild("flies")

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)

    return inst
end

return Prefab("spoiled_cloud_base_fx", fn)
