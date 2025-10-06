local assets ={}

local function shadow_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddFollower()
	inst.entity:AddNetwork()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.AnimState:SetBank("daywalker_pillar")
	inst.AnimState:SetBuild("daywalker_pillar")
	inst.AnimState:PlayAnimation("link_"..math.random(1, 4), true)
	-- inst.AnimState:SetMultColour(1, 1, 1, 0.5)
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
	-- inst:ListenForEvent("animover", function(inst)
	-- 	if inst.AnimState:IsCurrentAnimation("link_1") then
	-- 		inst.AnimState:PlayAnimation("link_break_1", false)
	-- 	elseif inst.AnimState:IsCurrentAnimation("link_2") then
	-- 		inst.AnimState:PlayAnimation("link_break_2", false)
	-- 	elseif inst.AnimState:IsCurrentAnimation("link_3") then
	-- 		inst.AnimState:PlayAnimation("link_break_3", false)
	-- 	elseif inst.AnimState:IsCurrentAnimation("link_4") then
	-- 		inst.AnimState:PlayAnimation("link_break_4", false)
	-- 	elseif inst.AnimState:IsCurrentAnimation("link_break_1") or
	-- 		inst.AnimState:IsCurrentAnimation("link_break_2") or
	-- 		inst.AnimState:IsCurrentAnimation("link_break_3") or
	-- 		inst.AnimState:IsCurrentAnimation("link_break_4")
	-- 	then
	-- 		inst:Hide()
	-- 		inst:Remove()
	-- 	end
	-- end)

	return inst
end


return Prefab("shadow_hook_link_fx", shadow_fn, assets)
