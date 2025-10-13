local assets = {}

local function shadow_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddFollower()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("portable_cook_pot")
    inst.AnimState:SetBuild("portable_cook_pot")
    inst.AnimState:PlayAnimation("collapse")
    local scale = 0.75
    inst.Transform:SetScale(scale, scale, scale)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(3)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:DoTaskInTime(18 * FRAMES, inst.Remove)

    inst.persists = false

    return inst
end


return Prefab("warly_sky_pie_cook_fx", shadow_fn, assets)
