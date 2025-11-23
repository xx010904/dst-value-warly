local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddFollower()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("sporecloud")
    inst.AnimState:SetBuild("sporecloud")
    inst.AnimState:PlayAnimation("sporecloud_loop", true)
    -- local s = math.random()
    -- inst.Transform:SetScale(s, s, s)
    inst.AnimState:SetMultColour(1,1,1,0.5)
    inst.AnimState:SetLightOverride(.3)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetDeltaTimeMultiplier(2)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    inst.Transform:SetRotation(math.random() * 360)

    -- 默认 1 秒（你可以改）
    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

return Prefab("spoiled_cloud_fx", fn)
