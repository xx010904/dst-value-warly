local assets ={}

local function shadow_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddFollower()
	inst.entity:AddNetwork()
	inst.entity:AddSoundEmitter()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.AnimState:SetBank("daywalker_pillar")
	inst.AnimState:SetBuild("daywalker_pillar")
	inst.AnimState:PlayAnimation("link_"..math.random(1, 4), true)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false

	return inst
end


return Prefab("shadow_hook_link_fx", shadow_fn, assets)
