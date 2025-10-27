local assets = {}
local prefabs = {}

--------------------------------------------------------------------------

local function OnHit(inst, attacker, target)
	local x, y, z = inst.Transform:GetWorldPosition()
	local anim_length = inst.AnimState:GetCurrentAnimationLength()

	inst.AnimState:PlayAnimation("hit_cooking", false)
	-- inst.AnimState:PlayAnimation("projectile_impact", false)
	inst.SoundEmitter:KillSound("toss")
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound") -- ✅ 增加爆炸音效

	local fx = SpawnPrefab("groundpoundring_fx")
	if fx then
		fx.Transform:SetScale(0.75, 0.75, 0.75)
		fx.Transform:SetPosition(x, y, z)
		fx:FastForward()
	end

	local fx2 = SpawnPrefab("groundpound_fx")
	if fx2 then
		-- fx2.Transform:SetScale(0.5,0.5,0.5)
		fx2.Transform:SetPosition(x, y, z)
	end

	local fx3 = SpawnPrefab("lucy_ground_transform_fx")
	if fx3 then
		fx3.Transform:SetPosition(x, y, z)
	end

	-- ✅ 延迟爆炸：等待动画播放到一半时爆炸
	local EXPLODETARGET_MUST_TAGS = { "_health", "_combat" }
	local EXPLODETARGET_CANT_TAGS = { "INLIMBO", "notarget", "noattack", "flight", "invisible", "wall", "player", "companion", "structure" }
	attacker:DoTaskInTime(anim_length / 7, function()
		if not inst:IsValid() then return end

		local explosive_range = 6
		local max_damage = 300 -- 中心最大伤害
		local min_damage = 100 -- 边缘最小伤害

		-- 搜索范围内所有可被攻击的实体
		local etargets = TheSim:FindEntities(x, y, z, explosive_range, EXPLODETARGET_MUST_TAGS, EXPLODETARGET_CANT_TAGS)
		for _, etarget in ipairs(etargets) do
			if etarget.components.combat then
				local tx, ty, tz = etarget.Transform:GetWorldPosition()
				local dist = math.sqrt((tx-x)^2 + (tz-z)^2)
				local damage = max_damage
				if dist > 0 then
					-- 线性衰减
					damage = math.max(min_damage, max_damage * (1 - dist / explosive_range))
				end
				if etarget:HasTag("scapegoat") then
					damage = damage * 0.25
				end
				etarget.components.combat:GetAttacked(attacker, damage)
			end
		end

		-- 移除炸弹
		inst:Remove()
	end)
end

--------------------------------------------------------------------------

local function onthrown(inst, attacker)
	inst:AddTag("NOCLICK")
	inst.persists = false

	inst.ispvp = attacker ~= nil and attacker:IsValid() and attacker:HasTag("player")

	-- inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	-- inst.AnimState:PlayAnimation("projectile_pre", false)
	-- inst.AnimState:PushAnimation("projectile_loop", true)
	-- inst.Transform:SetScale(1.5, 1.5, 1.5)
	inst.AnimState:PlayAnimation("collapse", false)
	inst.AnimState:PushAnimation("idle_ground", true)
	inst.Transform:SetScale(0.9, 0.9, 0.9)

	inst.SoundEmitter:PlaySound("dontstarve/common/together/portable/cookpot/place", "toss")

	inst.Physics:SetMass(1)
	inst.Physics:SetFriction(0)
	inst.Physics:SetDamping(0)
	inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
	inst.Physics:SetCollisionMask(
		COLLISION.GROUND,
		COLLISION.OBSTACLES,
		COLLISION.ITEMS
	)
	inst.Physics:SetCapsule(.2, .2)

end

--------------------------------------------------------------------------

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst.Transform:SetTwoFaced()

	MakeInventoryPhysics(inst)

	inst:AddTag("projectile")
	inst:AddTag("complexprojectile")
	inst:AddTag("NOCLICK")

	inst.AnimState:SetBank("portable_cook_pot")
	inst.AnimState:SetBuild("portable_cook_pot")
	inst.AnimState:PlayAnimation("idle_ground")
	inst.Transform:SetScale(0.9, 0.9, 0.9)
	-- inst.AnimState:SetBank("shadow_thrall_projectile_fx")
	-- inst.AnimState:SetBuild("shadow_thrall_projectile_fx")
	-- inst.AnimState:PlayAnimation("idle_loop")
	-- inst.Transform:SetScale(2.5, 2.5, 2.5)

	MakeInventoryFloatable(inst, "small", 0.1, 0.8)

	inst.entity:SetPristine()

	-- ✅ 新增字段：控制是否生成锅
	inst.should_spawn_pot = false

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("locomotor")

	inst:AddComponent("complexprojectile")
	inst.components.complexprojectile:SetHorizontalSpeed(14)  -- 更快，更有重量感
	inst.components.complexprojectile:SetGravity(-60)         -- 更快下坠
	inst.components.complexprojectile:SetLaunchOffset(Vector3(0.25, 1.1, 0))  -- 只抬高一点点
	inst.components.complexprojectile:SetOnLaunch(onthrown)
	inst.components.complexprojectile:SetOnHit(OnHit)


	MakeHauntableLaunch(inst)

	return inst
end

--------------------------------------------------------------------------

return Prefab("bomb_crockpot", fn, assets, prefabs)
