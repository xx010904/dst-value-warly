local spicedfoods = require("spicedfoods")

-- 获取基础食物名（去掉调味前缀/后缀），更稳健地处理 spicedfoods[prefab] 存在但 .basename 为空的情况
local function GetBaseFood(prefab)
    if not prefab then return prefab end

    -- 优先使用 spicedfoods 表里的 basename
    local info = spicedfoods[prefab]
    if info and info.basename and type(info.basename) == "string" and info.basename ~= "" then
        return info.basename
    end

    -- 尝试匹配 "_spice_" 及其后所有内容为调味后缀
    -- 例：koalefig_trunk_spice_jelly -> koalefig_trunk
    --     frogfishbowl_spice_mandrake_jam -> frogfishbowl
    local base = prefab:gsub("_spice_.+$", "")
    if base ~= prefab then
        return base
    end

    return prefab
end

-- 🍲 根据厨师记忆筛选未吃过的食物（无doer则随机全食谱）
local function GetUnmemorizedFoods(inst)
    local allfoods = _G.ALL_COOKALBE_FOODS
	if "HUNGER_PREFER" == inst.prefer_type then
		allfoods = _G.TOP_HUNGER_FOODS
	elseif "SANITY_PREFER" == inst.prefer_type then
		allfoods = _G.TOP_SANITY_FOODS
	elseif "HEALTH_PREFER" == inst.prefer_type then
		allfoods = _G.TOP_HEALTH_FOODS
	end

	-- print("improv_cookpot_projectile_fx 使用食物表类型：", inst.prefer_type, "，食物总数：", #allfoods)
    local valid = {}

    if inst.doer and inst.doer.components.foodmemory then
        local memory = inst.doer.components.foodmemory

        -- 限制最多排除 10 种食物
        local excluded = 0
        for prefab in pairs(allfoods) do
            local base = GetBaseFood(prefab)
            -- print("随机烹饪的basename：", base, "，原名：", prefab)
            local count = memory:GetMemoryCount(base) or 0

            if count <= 0 or excluded >= 10 then
                table.insert(valid, prefab)
            else
                -- print("排除食物", base, "，原名：", prefab)
                excluded = excluded + 1
            end
        end
    else
        -- print("doer 为空或没有 foodmemory 组件，直接返回全部食物：", doer)
        for prefab in pairs(allfoods) do
            table.insert(valid, prefab)
        end
    end

	-- print("improv_cookpot_projectile_fx 可选食物数量：", #valid)

    return valid
end

local function OnThrown(inst)
    -- 附着锅特效
    local fx = SpawnPrefab("warly_sky_pie_cook_fx") -- 借用一下
    fx.AnimState:PlayAnimation("idle_ground")
    local scale = 0.55
    fx.Transform:SetScale(scale, scale, scale)
    fx.AnimState:SetMultColour(1, 1, 1, 0.9)
    fx.entity:SetParent(inst.entity)
    fx.AnimState:SetSortOrder(3)
    -- 开始动画
    inst.AnimState:PlayAnimation("projectile_loop")
    inst.AnimState:PushAnimation("idle_loop", true)
	inst:DoTaskInTime(1*FRAMES, function()
		if inst.meal == nil then
			-- 随机食物
			local unmemorized = GetUnmemorizedFoods(inst)
			inst.meal = unmemorized[math.random(#unmemorized)] or "wetgoop"
		end
		inst.display_meal = GetBaseFood(inst.meal)
	end)
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
    local cookpotfx = SpawnPrefab("improv_cookpot_fx")
    cookpotfx.Transform:SetPosition(x, y, z)
	cookpotfx.doer = inst.doer
	cookpotfx.meal = inst.meal
	cookpotfx.display_meal = inst.display_meal

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

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(3)

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

	inst.doer = nil
	inst.meal = nil
	inst.prefer_type = nil

    inst.persists = false

    return inst
end

return Prefab("improv_cookpot_projectile_fx", fn)
