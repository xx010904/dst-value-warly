local function OnOpen(inst)
    inst.SoundEmitter:PlaySound("yotb_2021/common/sewing_machine/open")
end

local function OnClose(inst)
    inst.SoundEmitter:PlaySound("yotb_2021/common/sewing_machine/stop")
end

local function OnPutInInventory(inst)
    if inst.components.container ~= nil then
        inst.components.container:Close()
    end
    if inst.Light then
        inst.Light:Enable(false)
    end
end

local function OnRemoveEntity(inst)
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end
end

-- 光环效果
local function MakeAura(inst, color)
    if not inst.Light then
        inst.entity:AddLight()
    end
    inst.Light:SetFalloff(0.8)
    inst.Light:SetIntensity(0.6)
    inst.Light:SetRadius(2)
    inst.Light:SetColour(unpack(color))
    inst.Light:Enable(true)
end

local function MakeSpiceBag(name, fg_image, color)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("backpack1")
        inst.AnimState:SetBuild("swap_chefpack")
        inst.AnimState:PlayAnimation("anim")

        inst.AnimState:SetSymbolBloom("crystalbase")
        inst.AnimState:SetSymbolLightOverride("Glow_FX", 0.7)
        inst.AnimState:SetSymbolLightOverride("crystalbase", 0.5)
        inst.AnimState:SetLightOverride(0.1)

        MakeInventoryPhysics(inst)

        inst:AddTag("portablestorage")

        -- 背景图
        inst.inv_image_bg = { image = "spicepack.tex" }
        inst.inv_image_bg.atlas = "images/inventoryimages3.xml"

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("container")
        inst.components.container:WidgetSetup("spice_sack")
        inst.components.container.onopenfn = OnOpen
        inst.components.container.onclosefn = OnClose
        inst.components.container.skipclosesnd = true
        inst.components.container.skipopensnd = true
        inst.components.container.droponopen = true

        inst:AddComponent("preserver")
        inst.components.preserver:SetPerishRateMultiplier(TUNING.PERISH_FRIDGE_MULT)

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
        inst.components.inventoryitem.atlasname = "images/inventoryimages3.xml"
        inst.components.inventoryitem:ChangeImageName(fg_image)

        inst.OnRemoveEntity = OnRemoveEntity

        -- 掉落地上生成光环
        inst:ListenForEvent("ondropped", function()
            MakeAura(inst, color)
        end)

        -- 拿回背包时关闭光环
        inst:ListenForEvent("onpickup", function()
            if inst.Light then
                inst.Light:Enable(false)
            end
        end)

        MakeHauntableLaunchAndDropFirstItem(inst)

        return inst
    end

    return Prefab(name, fn)
end

return
    MakeSpiceBag("spice_sack_chili", "spice_chili_over", { 1, 0.25, 0.1 }), -- 🔥红辣椒
    MakeSpiceBag("spice_sack_salt", "spice_salt_over", { 0.7, 0.9, 1.0 }),  -- ❄️盐
    MakeSpiceBag("spice_sack_garlic", "spice_garlic_over", { 0.7, 0.5, 0.9 }), -- 🕯️蒜
    MakeSpiceBag("spice_sack_sugar", "spice_sugar_over", { 1.0, 0.8, 0.4 }) -- 🍯糖
