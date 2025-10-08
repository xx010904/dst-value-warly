local assets ={}

local function shadow_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddFollower()
	inst.entity:AddNetwork()
	inst.entity:AddSoundEmitter()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst:AddTag("shadow_hook_head_fx")

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.Transform:SetEightFaced()

    local phys = inst.entity:AddPhysics()
    phys:SetSphere(1)
    phys:SetCollides(false)

	inst.AnimState:SetBank("nightmare_axe")
	inst.AnimState:SetBuild("nightmare_axe")
	inst.AnimState:PlayAnimation("swap_level1_f1", true)
	-- inst.AnimState:SetMultColour(1, 1, 1, 1)
	-- inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    -- inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    -- inst.AnimState:SetSortOrder(3)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false
	-- inst:DoTaskInTime(1*FRAMES,function(inst)
	-- 	inst:Remove()
	-- end)

	return inst
end


return Prefab("shadow_hook_head_fx", shadow_fn, assets)
