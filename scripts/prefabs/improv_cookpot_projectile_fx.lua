local function OnThrown(inst)
    inst.AnimState:PlayAnimation("projectile_loop")
    inst.AnimState:PushAnimation("idle_loop", true)
end

local function OnHit(inst, attacker, target)
    inst:RemoveComponent("complexprojectile")
	inst:ListenForEvent("animover", inst.Remove)
	inst.AnimState:PlayAnimation("projectile_impact")
	inst.DynamicShadow:Enable(false)
	local playsfx = true
	if inst.sfx ~= nil then
		if inst.sfx.played then
			playsfx = false
		else
			inst.sfx.played = true
		end
	end
	if playsfx then
		inst.SoundEmitter:PlaySound("rifts2/thrall_wings/projectile")
	end

    local x, y, z = inst.Transform:GetWorldPosition()

    -- 🎆 爆竹庆祝
    local firecrackers = SpawnPrefab("firecrackers")
    -- firecrackers.components.stackable:SetStackSize(4)
    firecrackers.Transform:SetPosition(x, y, z)
    firecrackers.components.burnable:Ignite()

    -- ✨ 落地生成烹饪锅特效
    local cookfx = SpawnPrefab("improv_cookpot_fx")
    cookfx.Transform:SetPosition(x, y, z)

    local scorch = SpawnPrefab("fused_shadeling_bomb_scorch")
	scorch.Transform:SetPosition(x, y, z)
	scorch.Transform:SetScale(1.2, 1.2, 1.2)
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
	inst.entity:AddNetwork()

	inst.DynamicShadow:SetSize(.8, .8)

	inst.entity:AddPhysics()
	inst.Physics:SetMass(1)
	inst.Physics:SetFriction(0)
	inst.Physics:SetDamping(0)
	inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
	inst.Physics:ClearCollisionMask()
	inst.Physics:CollidesWith(COLLISION.GROUND)
	inst.Physics:SetCapsule(.2, .2)

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("shadow_thrall_projectile_fx")
    inst.AnimState:SetBuild("shadow_thrall_projectile_fx")
    inst.AnimState:PlayAnimation("projectile_pre")
    inst.AnimState:SetLightOverride(1)
    local scale = 1.66
    inst.Transform:SetScale(scale, scale, scale)

	inst:AddTag("projectile")
	inst:AddTag("complexprojectile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:PushAnimation("projectile_loop")
	inst.AnimState:PushAnimation("idle_loop")

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-50)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(0.25, 2.5, 0))
    inst.components.complexprojectile:SetOnLaunch(OnThrown)
    inst.components.complexprojectile:SetOnHit(OnHit)

    inst.persists = false

    return inst
end

return Prefab("improv_cookpot_projectile_fx", fn)
