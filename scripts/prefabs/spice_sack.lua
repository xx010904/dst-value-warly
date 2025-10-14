
-----------------------------------------------------------------------------------------------

local function OnOpen(inst)
end

local function OnClose(inst)
end

local function OnPutInInventory(inst)
end

local function OnRemoveEntity(inst)
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

    inst.AnimState:SetBank("backpack1")
    inst.AnimState:SetBuild("swap_chefpack")
    inst.AnimState:PlayAnimation("anim")

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


    inst:AddComponent("inspectable")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("spice_sack")
    -- inst.components.container.onopenfn = OnOpen
    -- inst.components.container.onclosefn = OnClose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    inst.components.container.droponopen = true

    inst:AddComponent("preserver")
    inst.components.preserver:SetPerishRateMultiplier(TUNING.PERISH_FRIDGE_MULT)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem.imagename = "spicepack"
    inst.components.inventoryitem.atlasname = "images/inventoryimages3.xml"

    inst.OnRemoveEntity = OnRemoveEntity

    MakeHauntableLaunchAndDropFirstItem(inst)

    return inst
end



return Prefab( "spice_sack", fn  )