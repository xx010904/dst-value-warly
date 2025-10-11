---------------------------------------
-- 4格袋子 prefab
---------------------------------------
local function fourbag_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("bundle")
    inst.AnimState:SetBuild("bundle")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("prepack_foodbag")
    MakeInventoryPhysics(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "bundlewrap"
	inst.components.inventoryitem.atlasname = "images/inventoryimages1.xml"
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("prepack_foodbag_4")

    -- 加入自定义打包逻辑
    inst:AddComponent("packagingstation")

    return inst
end

---------------------------------------
-- 5格袋子 prefab（多一个调味槽）
---------------------------------------
local function fivebag_fn()
        local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("bundle")
    inst.AnimState:SetBuild("bundle")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("prepack_foodbag")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "bundlewrap"
	inst.components.inventoryitem.atlasname = "images/inventoryimages1.xml"
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("prepack_foodbag_5")

    -- 加入自定义打包逻辑
    inst:AddComponent("packagingstation")

    return inst
end

return Prefab("prepack_foodbag_4", fourbag_fn),
       Prefab("prepack_foodbag_5", fivebag_fn)
