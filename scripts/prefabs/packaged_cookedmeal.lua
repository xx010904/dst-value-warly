
local function OnUnwrap(inst, doer)
    if inst.mealtype then
        local meal = SpawnPrefab(inst.mealtype)
        meal.Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst:Remove()
        if doer then
            doer.components.talker:Say("解封出一道美味的 " .. STRINGS.NAMES[string.upper(inst.mealtype)] .. "！")
        end
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    inst.AnimState:SetBank("bundle")
    inst.AnimState:SetBuild("bundle")
    inst.AnimState:PlayAnimation("idle_large")

    inst:AddTag("preparedfood")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.mealtype = nil

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    -- inst.components.inventoryitem.imagename = "bundle_large"
	-- inst.components.inventoryitem.atlasname = "images/inventoryimages1.xml"

    inst:AddComponent("packageinfo")
    inst:DoTaskInTime(0, function ()
        inst.components.packageinfo:SetIcon()
    end)

    return inst
end

return Prefab("packaged_cookedmeal", fn)
