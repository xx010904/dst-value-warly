-----------------------------------------------------------------------------------------------

local sounds =
{
    open  = "rifts3/bearger_sack/open_f5_loopstart",
    close = "rifts3/bearger_sack/close",
}

local function GetOpenSoundName(inst)
	return "openloop"..tostring(inst.GUID)
end

-----------------------------------------------------------------------------------------------

local function ToggleFrostFX(inst, start, remove)
    if inst._opentask ~= nil then
        inst._opentask:Cancel()
        inst._opentask = nil
    end

    if start and inst._frostfx == nil then
        inst._frostfx = SpawnPrefab("beargerfur_sack_frost_fx")
        inst._frostfx.entity:SetParent(inst.entity)
        inst._frostfx.Follower:FollowSymbol(inst.GUID, "ground", -25, -15, 0)

    elseif inst._frostfx ~= nil then
        if remove then
            inst._frostfx:Remove()
        else
            inst._frostfx:Kill()
        end

        inst._frostfx = nil
    end
end

local function StopOpenSound(inst)
	if inst._soundent then
		if inst._soundent:IsValid() then
			inst._soundent.SoundEmitter:KillSound(GetOpenSoundName(inst))
		end
		inst._soundent = nil
	end
end

local function StartOpenSound(inst)
	inst._startsoundtask = nil

	StopOpenSound(inst)

	local ent = inst.components.inventoryitem:GetGrandOwner() or inst
	if ent.SoundEmitter then
		ent.SoundEmitter:PlaySound(inst._sounds.open, GetOpenSoundName(inst))
		inst._soundent = ent
	end
end

local function OnOpen(inst)
    inst.AnimState:PlayAnimation("open")
    inst.components.inventoryitem.imagename = "coonfur_sack_open"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/coonfur_sack_open.xml"

    if inst._startsoundtask ~= nil then
        inst._startsoundtask:Cancel()
		inst._startsoundtask = nil
    end
    if inst._opentask ~= nil then
        inst._opentask:Cancel()
		inst._opentask = nil
    end

	if not inst.components.inventoryitem:IsHeld() then
		StopOpenSound(inst)
		local time = inst.AnimState:GetCurrentAnimationLength() - inst.AnimState:GetCurrentAnimationTime()
		inst._opentask = inst:DoTaskInTime(time, ToggleFrostFX, true)
		inst._startsoundtask = inst:DoTaskInTime(5 * FRAMES, StartOpenSound)
	else
		StartOpenSound(inst)
	end
end

local function OnClose(inst)
	if inst._startsoundtask then
		inst._startsoundtask:Cancel()
		inst._startsoundtask = nil
	end
	StopOpenSound(inst)
    inst.components.inventoryitem.imagename = "coonfur_sack"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/coonfur_sack.xml"


	if not inst.components.inventoryitem:IsHeld() then
        inst.AnimState:PlayAnimation("close")
        inst.AnimState:PushAnimation("closed", false)
    else
        inst.AnimState:PlayAnimation("closed", false)
    end
	ToggleFrostFX(inst, false)

	local SoundEmitter = (inst.components.inventoryitem:GetGrandOwner() or inst).SoundEmitter
	if SoundEmitter then
		SoundEmitter:PlaySound(inst._sounds.close)
	end
end

local function OnPutInInventory(inst)
	ToggleFrostFX(inst, false, true)

    inst.components.container:Close()
    inst.AnimState:PlayAnimation("closed", false)
end

local function OnRemoveEntity(inst)
	ToggleFrostFX(inst, false, true)
	StopOpenSound(inst)
end


-----------------------------------------------------------------------------------------------

local floatable_swap_data = { bank = "beargerfur_sack", anim = "closed" }

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("beargerfur_sack.png")

    inst.AnimState:SetBank("coonfur_sack")
    inst.AnimState:SetBuild("coonfur_sack")
    inst.AnimState:PlayAnimation("closed")

    inst.AnimState:SetSymbolBloom("crystalbase")
    inst.AnimState:SetSymbolLightOverride("Glow_FX", 0.7)
    inst.AnimState:SetSymbolLightOverride("crystalbase", 0.5)

    inst.AnimState:SetLightOverride(0.1)

    MakeInventoryPhysics(inst)

    MakeInventoryFloatable(inst, "small", 0.35, 1.15, nil, nil, floatable_swap_data)

    inst:AddTag("portablestorage")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._sounds = sounds
    inst._frostfx = nil

    inst:AddComponent("inspectable")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("coonfur_sack")
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    inst.components.container.droponopen = true

    inst:AddComponent("preserver")
    inst.components.preserver:SetPerishRateMultiplier(TUNING.BEARGERFUR_SACK_PRESERVER_RATE)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem.imagename = "coonfur_sack"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/coonfur_sack.xml"

    inst.OnRemoveEntity = OnRemoveEntity

    MakeHauntableLaunchAndDropFirstItem(inst)

    return inst
end

return Prefab( "coonfur_sack", fn)
