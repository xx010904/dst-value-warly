
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

local function PushIdleLoop(inst)
    if inst.components.finiteuses:GetUses() > 0 then
        inst.AnimState:PushAnimation("idle")
    else
        inst.AnimState:PlayAnimation("broken")
    end
end

local function OnStopFloating(inst)
    inst.fx.AnimState:SetFrame(0)
    inst:DoTaskInTime(0, PushIdleLoop) --#V2C: #HACK restore the looping anim, timing issues.
end

----------------------------------------------------------------------------------------------------------------

local function SetupComponents(inst)
    inst:AddComponent("equippable")
    inst.components.equippable.dapperness = -TUNING.DAPPERNESS_MED
    inst.components.equippable.is_magic_dapperness = true
    inst.components.equippable.walkspeedmult = TUNING.VOIDCLOTH_BOOMERANG_SPEEDMULT
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
end


local SWAP_DATA = { sym_build = "boomerang_voidcloth", bank = "boomerang_voidcloth" }


----------------------------------------------------------------------------------------------------------------

local function OnDischarged(inst)
    inst.components.weapon:SetRange(nil)
    inst.components.weapon:SetProjectile(nil)
end

local function OnCharged(inst)
    inst.components.weapon:SetRange(TUNING.VOIDCLOTH_BOOMERANG_ATTACK_DIST, TUNING.VOIDCLOTH_BOOMERANG_ATTACK_DIST_MAX)
    inst.components.weapon:SetProjectile("warly_sky_pie_boomerang_proj")
end

----------------------------------------------------------------------------------------------------------------

local function OnProjectileCountChanged(inst)
    if #inst._projectiles >= inst.max_projectiles then
        inst.components.rechargeable:Discharge(999999) -- NOTES(JBK): This is saved so do not make it math.huge.
    else
        inst.components.rechargeable:SetPercent(1)
    end
end

----------------------------------------------------------------------------------------------------------------

local function OnPreLoad(inst, data, newents)
    if data ~= nil then
        -- NOTES(DiogoW): Clean up rechargeable save data, we are not using rechargeable in the regular way...
        data.rechargeable = nil
    end
end

----------------------------------------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("warly_sky_pie_boomerang")
    inst.AnimState:SetBuild("warly_sky_pie_boomerang")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("rangedweapon")

    -- Weapon (from weapon component) added to pristine state for optimization.
    inst:AddTag("weapon")

    -- Shadowlevel (from shadowlevel component) added to pristine state for optimization.
    inst:AddTag("shadowlevel")

    -- Rechargeable (from rechargeable component) added to pristine state for optimization.
    inst:AddTag("rechargeable")

    inst.projectiledelay = FRAMES

    inst:AddComponent("floater")

    inst.components.floater:SetBankSwapOnFloat(true, -6, SWAP_DATA)
    if inst.fx ~= nil then
        inst.fx:Show()
    end
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._projectiles = {}
    inst.max_projectiles = 1

    inst.SetFxOwner = SetFxOwner
    inst.OnProjectileCountChanged = OnProjectileCountChanged

    -----------------------------------------------------------

    -- Follow symbol FX initialization.
    local frame = math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1
    inst.AnimState:SetFrame(frame)
    --V2C: one networked fx for frame 3 (needed for floating)
    --     all other frames will be spawned locally client-side by this fx.
    inst.fx = SpawnPrefab("warly_sky_pie_boomerang_fx")
    inst.fx.AnimState:SetFrame(frame)
    inst:SetFxOwner(nil)
    inst:ListenForEvent("floater_stopfloating", OnStopFloating)

    -----------------------------------------------------------

    SetupComponents(inst)

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.VOIDCLOTH_BOOMERANG_USES)
    inst.components.finiteuses:SetUses(TUNING.VOIDCLOTH_BOOMERANG_USES)

    inst:AddComponent("weapon")
    inst.components.weapon:SetRange(TUNING.VOIDCLOTH_BOOMERANG_ATTACK_DIST, TUNING.VOIDCLOTH_BOOMERANG_ATTACK_DIST_MAX)
    inst.components.weapon:SetProjectile("warly_sky_pie_boomerang_proj")

    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetOnDischargedFn(OnDischarged)
    inst.components.rechargeable:SetOnChargedFn(OnCharged)

    inst.OnPreLoad = OnPreLoad

    MakeHauntableLaunch(inst)

    return inst
end

----------------------------------------------------------------------------------------------------------------

local PROJECTILE_COLLECT_DIST_SQ = 1*1

local PROJECTILE_MAX_SIZE = 1
local PROJECTILE_MIN_SIZE = .4

local PROJECTILE_RETURN_SPEED_ACCELERATION_RATE = 1/3

local function Projectile_OnRemoved(inst)
    if inst._boomerang ~= nil and inst._boomerang:IsValid() then
        table.removearrayvalue(inst._boomerang._projectiles, inst)

        inst._boomerang:OnProjectileCountChanged()
    end
end

local function Projectile_ReturnToThrower(inst, thrower)
    inst.scalingdata = {
        start = inst.scale or PROJECTILE_MAX_SIZE, -- In case inst.scale is nil.
        finish = PROJECTILE_MIN_SIZE,
        totaltime = TUNING.BOOMERANG_DISTANCE / TUNING.VOIDCLOTH_BOOMERANG_PROJECTILE.RETURN_SPEED,
        currenttime = 0,
    }

    inst._returntarget = thrower

    inst.Physics:ClearCollidesWith(COLLISION.LIMITS) -- Projectile:Stop() makes it collide with limits again.
    inst.Physics:SetMotorVel(TUNING.VOIDCLOTH_BOOMERANG_PROJECTILE.RETURN_SPEED, 0, 0)
end

local function Projectile_OnHit(inst, attacker, target)
    inst:ReturnToThrower(attacker)

    if target ~= nil and target:IsValid() then
        local fx = SpawnPrefab("voidcloth_boomerang_impact_fx")

        local radius = math.max(0, target:GetPhysicsRadius(0) - .5)
        local angle = (inst.Transform:GetRotation() + 180) * DEGREES
        local x, y, z = target.Transform:GetWorldPosition()

        x = x + math.cos(angle) * radius
        z = z - math.sin(angle) * radius

        fx.Transform:SetPosition(x, y, z)
    end
end

local function Projectile_OnMiss(inst, attacker, target)
    inst:ReturnToThrower(attacker)
end

local function Projectile_OnUpdateFn(inst, dt)
    local scalingdata = inst.scalingdata or {}

    if inst._returntarget == nil then
        -- Do nothing!

    elseif not inst._returntarget:IsValid() or inst._returntarget:IsInLimbo() then
        inst:Remove()

        return
    else
        local p_pos = inst:GetPosition()
        local t_pos = inst._returntarget:GetPosition()

        if distsq(p_pos, t_pos) < PROJECTILE_COLLECT_DIST_SQ then
            inst:Remove()

            return
        else
            local direction = (t_pos - p_pos):GetNormalized()
            local projected_speed = TUNING.VOIDCLOTH_BOOMERANG_PROJECTILE.RETURN_SPEED * TheSim:GetTickTime() * TheSim:GetTimeScale()
            local projected = p_pos + direction * projected_speed

            if direction:Dot(t_pos - projected) < 0 then
                inst:Remove()

                return
            end

            inst:FacePoint(t_pos)

            local speed_mult = math.max(1, scalingdata.currenttime * PROJECTILE_RETURN_SPEED_ACCELERATION_RATE)
            inst.Physics:SetMotorVel(TUNING.VOIDCLOTH_BOOMERANG_PROJECTILE.RETURN_SPEED * speed_mult, 0, 0)
        end
    end

    if scalingdata.totaltime == nil then
        return
    end

    scalingdata.currenttime = (scalingdata.currenttime or 0) + dt

    if scalingdata.currenttime >= scalingdata.totaltime then
        inst.scale = scalingdata.finish

    else
        inst.scale = Lerp(scalingdata.start, scalingdata.finish, scalingdata.currenttime / scalingdata.totaltime)
    end

    if inst.scale ~= nil then
        inst.AnimState:SetScale(inst.scale, inst.scale)

        local damage_scale = Remap(inst.scale, PROJECTILE_MIN_SIZE, PROJECTILE_MAX_SIZE, 0, 1)
        local bonus_mult = inst._bonusenabled and TUNING.WEAPONS_VOIDCLOTH_SETBONUS_DAMAGE_MULT or 1

        inst.components.weapon:SetDamage(bonus_mult * Lerp(TUNING.VOIDCLOTH_BOOMERANG_DAMAGE.min, TUNING.VOIDCLOTH_BOOMERANG_DAMAGE.max, damage_scale))
    end
end

local function Projectile_OnThrown(inst, owner, target, attacker)
    inst.SoundEmitter:PlaySound("rifts4/voidcloth_boomerang/throw_lp", "loop")

    inst._boomerang = owner
    inst._bonusenabled = owner ~= nil and owner._bonusenabled

    if owner ~= nil and owner.components.weapon ~= nil then
        owner.components.weapon:OnAttack(attacker, target, inst)

        table.insert(owner._projectiles, inst)

        owner:OnProjectileCountChanged()
    end

    if attacker ~= nil and attacker:IsValid() then
        local fx = SpawnPrefab("voidcloth_boomerang_launch_fx")

        local pos = target:GetPositionAdjacentTo(attacker, .5)

        fx.Transform:SetPosition(pos:Get())
        fx.Transform:SetRotation(fx:GetAngleToPoint(target.Transform:GetWorldPosition()) - 90)
    end
end

local function OnEntitySleep(inst)
    inst.components.projectile:Stop()
    inst:Remove()
end

----------------------------------------------------------------------------------------------------------------

local function ProjectileFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeProjectilePhysics(inst)

    inst.AnimState:SetBank("warly_sky_pie_boomerang")
    inst.AnimState:SetBuild("warly_sky_pie_boomerang")
    inst.AnimState:PlayAnimation("projectile", true)

    inst.AnimState:SetScale(PROJECTILE_MIN_SIZE, PROJECTILE_MIN_SIZE)

    inst.AnimState:SetLightOverride(.1)
    inst.AnimState:SetSymbolLightOverride("lightning", .5)

    inst.AnimState:SetSymbolMultColour("blade", 1, 1, 1, .8)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    -- weapon (from weapon component) added to pristine state for optimization.
    inst:AddTag("weapon")

    -- projectile (from projectile component) added to pristine state for optimization.
    inst:AddTag("projectile")

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scalingdata = {
        start = PROJECTILE_MIN_SIZE,
        finish = PROJECTILE_MAX_SIZE,
        totaltime = TUNING.VOIDCLOTH_BOOMERANG_ATTACK_DIST / TUNING.VOIDCLOTH_BOOMERANG_PROJECTILE.LAUNCH_SPEED,
        currenttime = 0,
    }

    inst.persists = false

    inst.ReturnToThrower = Projectile_ReturnToThrower

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.VOIDCLOTH_BOOMERANG_DAMAGE.min)

    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnUpdateFn(Projectile_OnUpdateFn)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(TUNING.VOIDCLOTH_BOOMERANG_PROJECTILE.LAUNCH_SPEED)
    inst.components.projectile:SetRange(20)
    inst.components.projectile:SetOnHitFn(Projectile_OnHit)
    inst.components.projectile:SetOnMissFn(Projectile_OnMiss)
    inst.components.projectile:SetOnThrownFn(Projectile_OnThrown)
    inst.components.projectile.has_damage_set = true

    inst.OnRemoveEntity = Projectile_OnRemoved
    inst.OnEntitySleep = OnEntitySleep

    return inst
end

----------------------------------------------------------------------------------------


local FX_DEFS =
{
    { anim = "f1", frame_begin = 0, frame_end = 2  },
  --{ anim = "f3", frame_begin = 2                 },
}

local function CreateFxFollowFrame()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()

    inst:AddTag("FX")

    inst.AnimState:SetBank("warly_sky_pie_boomerang")
    inst.AnimState:SetBuild("warly_sky_pie_boomerang")

    inst.AnimState:SetLightOverride(.1)

    inst:AddComponent("highlightchild")

    inst.persists = false

    return inst
end

local function FxRemoveAll(inst)
    for i = 1, #inst.fx do
        inst.fx[i]:Remove()
        inst.fx[i] = nil
    end
end

local function FxColourChanged(inst, r, g, b, a)
    for i = 1, #inst.fx do
        inst.fx[i].AnimState:SetAddColour(r, g, b, a)
    end
end

local function FxOnEquipToggle(inst)
    local owner = inst.equiptoggle:value() and inst.entity:GetParent() or nil
    if owner ~= nil then
        if inst.fx == nil then
            inst.fx = {}
        end
        local frame = inst.AnimState:GetCurrentAnimationFrame()
        for i, v in ipairs(FX_DEFS) do
            local fx = inst.fx[i]
            if fx == nil then
                fx = CreateFxFollowFrame()
                -- fx.AnimState:PlayAnimation("swap_loop_"..v.anim, true)
                fx.AnimState:PlayAnimation("idle", true)
                inst.fx[i] = fx
            end
            fx.entity:SetParent(owner.entity)
            fx.Follower:FollowSymbol(owner.GUID, "swap_object", nil, nil, nil, true, nil, v.frame_begin, v.frame_end)
            fx.AnimState:SetFrame(frame)
            fx.components.highlightchild:SetOwner(owner)
        end
        inst.components.colouraddersync:SetColourChangedFn(FxColourChanged)
        inst.OnRemoveEntity = FxRemoveAll
    elseif inst.OnRemoveEntity ~= nil then
        inst.OnRemoveEntity = nil
        inst.components.colouraddersync:SetColourChangedFn(nil)
        FxRemoveAll(inst)
    end
end

local function FxToggleEquipped(inst, equipped)
    if equipped ~= inst.equiptoggle:value() then
        inst.equiptoggle:set(equipped)
        -- Dedicated server does not need to spawn the local fx.
        if not TheNet:IsDedicated() then
            FxOnEquipToggle(inst)
        end
    end
end

local function FollowSymbolFxFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.AnimState:SetBank("warly_sky_pie_boomerang")
    inst.AnimState:SetBuild("warly_sky_pie_boomerang")
    inst.AnimState:PlayAnimation("swap_loop_f3", true) -- Frame 3 is used for floating.

    inst.AnimState:SetLightOverride(.1)

    inst:AddComponent("highlightchild")
    inst:AddComponent("colouraddersync")

    inst.equiptoggle = net_bool(inst.GUID, "voidcloth_boomerang_fx.equiptoggle", "equiptoggledirty")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("equiptoggledirty", FxOnEquipToggle)
        return inst
    end

    inst.ToggleEquipped = FxToggleEquipped
    inst.persists = false

    return inst
end

----------------------------------------------------------------------------------------------------------------
return Prefab("warly_sky_pie_boomerang", fn),
    Prefab("warly_sky_pie_boomerang_fx",   FollowSymbolFxFn),
    Prefab("warly_sky_pie_boomerang_proj", ProjectileFn)