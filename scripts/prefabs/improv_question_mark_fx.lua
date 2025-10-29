local assets ={}

local function shadow_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddFollower()
	inst.entity:AddNetwork()
	inst.entity:AddSoundEmitter()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.entity:AddAnimState()
	inst.AnimState:SetBank("warly_question_mark")
	inst.AnimState:SetBuild("warly_question_mark")
	inst.AnimState:PlayAnimation("idle", true)
	local scale = 1.5
	inst.Transform:SetScale(scale,scale,scale)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:DoTaskInTime(3.5, inst.Remove)

	inst.persists = false

	return inst
end


return Prefab("improv_question_mark_fx", shadow_fn, assets)
