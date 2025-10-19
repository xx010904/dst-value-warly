local function OnEaten(inst, eater)
    if eater and eater:IsValid() and eater.components.hunger then
        local skilltreeupdater = eater.components.skilltreeupdater
        -- 判断技能是否激活
        local hasSkill = (skilltreeupdater ~= nil and skilltreeupdater:IsActivated("warly_sky_pie_baked"))
        if hasSkill then
            eater.components.hunger:DoDelta(10)
        end
        return true
    end
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("warly_sky_pie_baked")
    inst.AnimState:SetBuild("warly_sky_pie_baked")
    inst.AnimState:PlayAnimation("idle", true)

    MakeInventoryFloatable(inst, "small", 0.2, 0.95)

    inst:AddTag("warly_sky_pie_baked")
    inst:AddTag("preparedfood")
    inst:AddTag("show_spoilage")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "warly_sky_pie_baked"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/warly_sky_pie_baked.xml"

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.GOODIES
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = 0
    inst.components.edible.sanityvalue = 0
    inst.components.edible:SetOnEatenFn(OnEaten)

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "ash"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("warly_sky_pie_baked", fn, {})