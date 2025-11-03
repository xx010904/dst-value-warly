local SPELLCOSTS = {
    ["HUNGER_PREFER"] = 2,
    ["HEALTH_PREFER"] = 2,
    ["SANITY_PREFER"] = 2,
    ["RANDOM"] = 1,
}

local function Consume(inst, doer, spell)
    local cost = SPELLCOSTS[spell]
    -- print("cost: "..cost)
    local stacksize = inst.components.stackable:StackSize()
    if stacksize >= cost then
        inst.components.stackable:Get(cost):Remove()
    elseif doer and doer.components.inventory and doer.components.inventory:Has(inst.prefab, cost) then
        inst:Remove()
        doer.components.inventory:ConsumeByName(inst.prefab, cost - stacksize)
    else
        return
    end
end

local function CheckStackSize(inst, doer, spell)
    return doer.replica.inventory ~= nil and doer.replica.inventory:Has(inst.prefab, SPELLCOSTS[spell])
end

local function OnOpenSpellBook(inst)
    local inventoryitem = inst.replica.inventoryitem
    if inventoryitem ~= nil then
        inventoryitem:OverrideImage("improv_cooking_power_actived")
    end
end

local function OnCloseSpellBook(inst)
    local inventoryitem = inst.replica.inventoryitem
    if inventoryitem ~= nil then
        inventoryitem:OverrideImage(nil)
    end
end


local function ReticuleTargetAllowWaterFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()
    --Cast range is 12, leave room for error
    --4 is the aoe range
    for r = 10, 0, -.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
        if ground:IsPassableAtPoint(pos.x, 0, pos.z, true) and not ground:IsGroundTargetBlocked(pos) then
            return pos
        end
    end
    return pos
end

-------------------------------------------------------------

local function StartAOETargeting(inst)
    local playercontroller = ThePlayer.components.playercontroller
    if playercontroller ~= nil then
        playercontroller:StartAOETargetingUsing(inst)
    end
end
-------------------------------------------------

local function DoSpellFn(inst, doer, pos, type)
    if not CheckStackSize(inst, doer, type) then
        return false, "NOT_ENOUGH_COOKING_POWER"
    else
        Consume(inst, doer, type)
        local proj = SpawnPrefab("improv_cookpot_projectile_fx")
        proj.doer = doer
        -- proj.meal = meal
        proj.Transform:SetPosition(doer.Transform:GetWorldPosition())
        proj.components.complexprojectile:Launch(Vector3(pos.x, pos.y, pos.z), doer)

        return true
    end
end

local function HungerSpellFn(inst, doer, pos)
    DoSpellFn(inst, doer, pos, "HUNGER_PREFER")
end

local function HealthSpellFn(inst, doer, pos)
    DoSpellFn(inst, doer, pos, "HEALTH_PREFER")
end

local function SanitySpellFn(inst, doer, pos)
    DoSpellFn(inst, doer, pos, "SANITY_PREFER")
end

local function RandomSpellFn(inst, doer, pos)
    DoSpellFn(inst, doer, pos, "RANDOM")
end

------------------------------------------------------------------------------------------------------------------------

local function Lightning_ReticuleTargetFn()
    --Cast range is 8, leave room for error (6.5 lunge)
    return Vector3(ThePlayer.entity:LocalToWorldSpace(6.5, 0, 0))
end

local function Lightning_ReticuleUpdatePositionFn(inst, pos, reticule, ease, smoothing, dt)
    local x, y, z = inst.Transform:GetWorldPosition()
    reticule.Transform:SetPosition(x, 0, z)
    local rot = -math.atan2(pos.z - z, pos.x - x) / DEGREES
    if ease and dt ~= nil then
        local rot0 = reticule.Transform:GetRotation()
        local drot = rot - rot0
        rot = Lerp((drot > 180 and rot0 + 360) or (drot < -180 and rot0 - 360) or rot0, rot, dt * smoothing)
    end
    reticule.Transform:SetRotation(rot)
end

---------------------------------------------------

local ICON_SCALE = .6
local SPELLBOOK_RADIUS = 100
local SKILLTREE_SPELL_DEFS = {

    {
        label = STRINGS.IMPROV_COOKING_POWER.RANDOM,
        onselect = function(inst)
            inst.components.spellbook:SetSpellName(STRINGS.IMPROV_COOKING_POWER.RANDOM)
            inst.components.aoetargeting:SetAllowRiding(true)
            inst.components.aoetargeting.reticule.reticuleprefab = "reticuleline"
            inst.components.aoetargeting.reticule.pingprefab = "reticulelineping"
            inst.components.aoetargeting.reticule.targetfn = Lightning_ReticuleTargetFn
            inst.components.aoetargeting.reticule.mousetargetfn = nil
            inst.components.aoetargeting.reticule.updatepositionfn = Lightning_ReticuleUpdatePositionFn
            inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
            inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
            inst.components.aoetargeting.reticule.ease = true
            inst.components.aoetargeting.reticule.mouseenabled = true

            if TheWorld.ismastersim then
                inst.components.aoetargeting:SetTargetFX("reticuleaoesummontarget_1d2")
                inst.components.aoespell:SetSpellFn(RandomSpellFn)
                inst.components.spellbook:SetSpellFn(nil)
            end
        end,
        execute = StartAOETargeting,
        bank = "spell_icons_willow",
        build = "spell_icons_willow",
        anims =
        {
            idle = { anim = "fire_burst" },
            focus = { anim = "fire_burst_focus", loop = true },
            down = { anim = "fire_burst_pressed" },
        },
        widget_scale = ICON_SCALE,
    },

    {
        label = STRINGS.IMPROV_COOKING_POWER.HUNGER_PREFER,
        onselect = function(inst)
            inst.components.spellbook:SetSpellName(STRINGS.IMPROV_COOKING_POWER.HUNGER_PREFER)
            inst.components.aoetargeting:SetAllowRiding(true)
            inst.components.aoetargeting.reticule.reticuleprefab = "reticuleline"
            inst.components.aoetargeting.reticule.pingprefab = "reticulelineping"
            inst.components.aoetargeting.reticule.targetfn = Lightning_ReticuleTargetFn
            inst.components.aoetargeting.reticule.mousetargetfn = nil
            inst.components.aoetargeting.reticule.updatepositionfn = Lightning_ReticuleUpdatePositionFn
            inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
            inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
            inst.components.aoetargeting.reticule.ease = true
            inst.components.aoetargeting.reticule.mouseenabled = true

            if TheWorld.ismastersim then
                inst.components.aoetargeting:SetTargetFX("reticuleaoefiretarget_1")
                inst.components.aoespell:SetSpellFn(HungerSpellFn)
                inst.components.spellbook:SetSpellFn(nil)
            end
        end,
        execute = StartAOETargeting,
        bank = "spell_icons_willow",
        build = "spell_icons_willow",
        anims =
        {
            idle = { anim = "fire_burst" },
            focus = { anim = "fire_burst_focus", loop = true },
            down = { anim = "fire_burst_pressed" },
        },
        widget_scale = ICON_SCALE,
    },

    {
        label = STRINGS.IMPROV_COOKING_POWER.HEALTH_PREFER,
        onselect = function(inst)
            inst.components.spellbook:SetSpellName(STRINGS.IMPROV_COOKING_POWER.HEALTH_PREFER)
            inst.components.aoetargeting:SetAllowRiding(true)
            inst.components.aoetargeting.reticule.reticuleprefab = "reticuleline"
            inst.components.aoetargeting.reticule.pingprefab = "reticulelineping"
            inst.components.aoetargeting.reticule.targetfn = Lightning_ReticuleTargetFn
            inst.components.aoetargeting.reticule.mousetargetfn = nil
            inst.components.aoetargeting.reticule.updatepositionfn = Lightning_ReticuleUpdatePositionFn
            inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
            inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
            inst.components.aoetargeting.reticule.ease = true
            inst.components.aoetargeting.reticule.mouseenabled = true

            if TheWorld.ismastersim then
                inst.components.aoetargeting:SetTargetFX(nil)
                inst.components.aoespell:SetSpellFn(HealthSpellFn)
                inst.components.spellbook:SetSpellFn(nil)
            end
        end,
        execute = StartAOETargeting,
        bank = "spell_icons_willow",
        build = "spell_icons_willow",
        anims =
        {
            idle = { anim = "fire_burst" },
            focus = { anim = "fire_burst_focus", loop = true },
            down = { anim = "fire_burst_pressed" },
        },
        widget_scale = ICON_SCALE,
    },

    {
        label = STRINGS.IMPROV_COOKING_POWER.SANITY_PREFER,
        onselect = function(inst)
            inst.components.spellbook:SetSpellName(STRINGS.IMPROV_COOKING_POWER.SANITY_PREFER)
            inst.components.aoetargeting:SetAllowRiding(true)
            inst.components.aoetargeting.reticule.reticuleprefab = "reticuleline"
            inst.components.aoetargeting.reticule.pingprefab = "reticulelineping"
            inst.components.aoetargeting.reticule.targetfn = Lightning_ReticuleTargetFn
            inst.components.aoetargeting.reticule.mousetargetfn = nil
            inst.components.aoetargeting.reticule.updatepositionfn = Lightning_ReticuleUpdatePositionFn
            inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
            inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
            inst.components.aoetargeting.reticule.ease = true
            inst.components.aoetargeting.reticule.mouseenabled = true

            if TheWorld.ismastersim then
                inst.components.aoetargeting:SetTargetFX("reticuleaoesummontarget_1d2")
                inst.components.aoespell:SetSpellFn(SanitySpellFn)
                inst.components.spellbook:SetSpellFn(nil)
            end
        end,
        execute = StartAOETargeting,
        bank = "spell_icons_willow",
        build = "spell_icons_willow",
        anims =
        {
            idle = { anim = "fire_burst" },
            focus = { anim = "fire_burst_focus", loop = true },
            down = { anim = "fire_burst_pressed" },
        },
        widget_scale = ICON_SCALE,
    },
}

-----------------------------------------------
local function topocket(inst)
    inst.persists = true
end

local function toground(inst)
    inst.persists = false
    if inst.AnimState:IsCurrentAnimation("idle") then
		inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
    end
end

local COOKING_POWER_TAGS = { "improv_cooking_power" }
local function OnDropped(inst)
    if inst.components.stackable ~= nil and inst.components.stackable:IsStack() then
        local x, y, z = inst.Transform:GetWorldPosition()
        local num = 10 - #TheSim:FindEntities(x, y, z, 4, COOKING_POWER_TAGS)
        if num > 0 then
            for i = 1, math.min(num, inst.components.stackable:StackSize()) do
                local cooking_power = inst.components.stackable:Get()
                cooking_power.Physics:Teleport(x, y, z)
                cooking_power.components.inventoryitem:OnDropped(true)
            end
        end
    end
end
-----------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("improv_cooking_power")
    inst.AnimState:SetBuild("improv_cooking_power")
    inst.AnimState:PlayAnimation("idle", true)
    -- inst.AnimState:SetScale(0.9, 0.9)

    inst:AddTag("throw_line")
    inst:AddTag("improv_cooking_power")
    inst:AddTag("nosteal")
    inst:AddTag("NOCLICK")

    inst:AddComponent("spellbook")
    inst.components.spellbook:SetRequiredTag("warly_funny_cook_base")
    inst.components.spellbook:SetRadius(SPELLBOOK_RADIUS)
    inst.components.spellbook:SetFocusRadius(SPELLBOOK_RADIUS) --UIAnimButton don't use focus radius SPELLBOOK_FOCUS_RADIUS)
    inst.components.spellbook:SetItems(SKILLTREE_SPELL_DEFS)
    inst.components.spellbook:SetOnOpenFn(OnOpenSpellBook)
    inst.components.spellbook:SetOnCloseFn(OnCloseSpellBook)
    inst.components.spellbook.opensound = "yotc_2022_1/decor1/play3"
    inst.components.spellbook.closesound = "yotc_2022_1/decor1/play1"

    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting:SetAllowWater(false)
    inst.components.aoetargeting:SetRange(12)
    inst.components.aoetargeting.reticule.targetfn = ReticuleTargetAllowWaterFn
    inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true
    inst.components.aoetargeting.reticule.twinstickmode = 1
    inst.components.aoetargeting.reticule.twinstickrange = 8

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("aoespell")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canonlygoinpocketorpocketcontainers = true
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)

    inst:AddComponent("locomotor")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    inst.components.stackable.forcedropsingle = true

    inst:AddComponent("inspectable")

    inst._activetask = nil
    inst._soundtasks = {}

    inst:ListenForEvent("onputininventory", topocket)
    inst:ListenForEvent("ondropped", toground)

    inst.castsound = "yotc_2022_1/kitpet/foodbag"

    inst._task = nil

    return inst
end

if TheSim then -- updateprefabs guard
    SetDesiredMaxTakeCountFunction("improv_cooking_power", function(player, inventory, container_item, container)
        print("[improv_cooking_power] SetDesiredMaxTakeCountFunction called")

        local max_count = 0

        if player and player.components.skilltreeupdater then
            print("[improv_cooking_power] player has skilltreeupdater")

            if player.components.skilltreeupdater:IsActivated("warly_funny_cook_base") then
                max_count = TUNING.STACK_SIZE_SMALLITEM
                print("[improv_cooking_power] skill 'warly_funny_cook_base' is activated! max_count =", max_count)
            else
                print("[improv_cooking_power] skill 'warly_funny_cook_base' NOT activated")
            end
        else
            print("[improv_cooking_power] player has NO skilltreeupdater")
        end

        local has, count = inventory:Has("improv_cooking_power", 0, false)
        print(string.format("[improv_cooking_power] inventory check: has=%s, count=%d", tostring(has), count or -1))

        local result = math.max(max_count - count, 0)
        print("[improv_cooking_power] returning", result)

        return result
    end)
end


return Prefab("improv_cooking_power", fn)
