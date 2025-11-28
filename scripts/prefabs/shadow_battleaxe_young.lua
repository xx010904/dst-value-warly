local youthShadowMaceDurability = warlyvalueconfig.youthShadowMaceDurability or 150

local function OnEquip(inst, owner)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    inst:SetFxOwner(owner)

    owner.AnimState:ClearOverrideSymbol("swap_object")
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    inst:SetFxOwner(nil)

    owner.AnimState:ClearOverrideSymbol("swap_object")
end

----------------------------------------------------------------------------------------------------------------

local function SetFxOwner(inst, owner)
    if inst._fxowner ~= nil and inst._fxowner.components.colouradder ~= nil then
        inst._fxowner.components.colouradder:DetachChild(inst.fx)
    end

    inst._fxowner = owner

    if owner ~= nil then
        inst.fx.entity:SetParent(owner.entity)
        inst.fx.Follower:FollowSymbol(owner.GUID, "swap_object", nil, nil, nil, true, nil, 2)
        inst.fx.components.highlightchild:SetOwner(owner)
        inst.fx:ToggleEquipped(true)

        if owner.components.colouradder ~= nil then
            owner.components.colouradder:AttachChild(inst.fx)
        end
    else
        inst.fx.entity:SetParent(inst.entity)
        -- For floating.
        inst.fx.Follower:FollowSymbol(inst.GUID, "swap_spear", nil, nil, nil, true, nil, 2)
        inst.fx.components.highlightchild:SetOwner(inst)
        inst.fx:ToggleEquipped(false)
    end
end

----------------------------------------------------------------------------------------------------------------

local hitsparks_fx_colouroverride = {1, 0, 0}

local function DoAttackEffects(inst, owner, target)
    local spark = SpawnPrefab("hitsparks_fx")
    spark:Setup(owner, target, nil, hitsparks_fx_colouroverride)
    spark.black:set(true)

    return spark -- Mods.
end

local function IsLifeDrainable(target)
	return not target:HasAnyTag(NON_LIFEFORM_TARGET_TAGS) or target:HasTag("lifedrainable")
end

local function onattack(inst, owner, target)
    if target ~= nil and target:IsValid() then
        inst:DoAttackEffects(owner, target)
    end

    -- 拉人的时候不吸血，所以这里给得比较多6.8/3.4
	if owner.components.health and owner.components.health:IsHurt() and IsLifeDrainable(target) then
        owner.components.health:DoDelta(TUNING.BATBAT_DRAIN, false, "batbat")
		if owner.components.sanity ~= nil then
	        owner.components.sanity:DoDelta(-.5 * TUNING.BATBAT_DRAIN)
		end
    end
end

----------------------------------------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("nightmare_axe")
    inst.AnimState:SetBuild("nightmare_axe")
    inst.AnimState:PlayAnimation("idle_level1", true)

    inst.AnimState:SetLightOverride(.1)
    inst.AnimState:SetSymbolLightOverride("red", .5)
    inst.AnimState:SetSymbolLightOverride("dread_red", .5)
    inst.AnimState:SetSymbolLightOverride("eye_inner", .5)

    inst:AddTag("sharp")

    -- Weapon (from weapon component) added to pristine state for optimization.
    inst:AddTag("weapon")

    inst:AddTag("shadow_item")

    inst:AddComponent("floater")

    -- Dedicated server does not need to spawn the local sound fx.
    if not TheNet:IsDedicated() then
        inst.localsounds = CreateEntity()
        inst.localsounds:AddTag("FX")

        --[[Non-networked entity]]
        inst.localsounds.entity:AddTransform()
        inst.localsounds.entity:AddSoundEmitter()
        inst.localsounds.entity:SetParent(inst.entity)

        inst.localsounds:Hide()
        inst.localsounds.persists = false

    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.level = 1

    inst.SetFxOwner = SetFxOwner
    inst.DoAttackEffects = DoAttackEffects

    -----------------------------------------------------------

    -- Follow symbol FX initialization.
    local frame = math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1
    inst.AnimState:SetFrame(frame)
    --V2C: one networked fx for frame 3 (needed for floating)
    --     all other frames will be spawned locally client-side by this fx.
    inst.fx = SpawnPrefab("shadow_battleaxe_fx")
    inst.fx.AnimState:SetFrame(frame)
    inst:SetFxOwner(nil)

    -----------------------------------------------------------

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(48)
    inst.components.weapon:SetOnAttack(onattack)

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.CHOP, 1.5)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "shadow_battleaxe_young"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/shadow_battleaxe_young.xml"

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(youthShadowMaceDurability)
    inst.components.finiteuses:SetUses(youthShadowMaceDurability)
    inst.components.finiteuses:SetConsumption(ACTIONS.CHOP, 1)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("shadowhooktool")

    inst:AddComponent("shadowlevel")
	inst.components.shadowlevel:SetDefaultLevel(TUNING.BATBAT_SHADOW_LEVEL)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("shadow_battleaxe_young",fn)