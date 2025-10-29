local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("farm_soil")
    inst.AnimState:SetBuild("farm_soil")
    inst.AnimState:PlayAnimation("till_rise")
    local scale = math.random() * 0.2 + 1.1
    inst.AnimState:SetScale(scale, scale, scale)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("FX")
    inst.persists = false

    -- 播放 till_rise 完成后播放 till_idle
    inst:ListenForEvent("animover", function(inst2)
        if inst2.AnimState:IsCurrentAnimation("till_rise") then
            inst2.AnimState:PlayAnimation("till_idle")
        elseif inst2.AnimState:IsCurrentAnimation("till_idle") then
            inst2.AnimState:PlayAnimation("till_remove")
        elseif inst2.AnimState:IsCurrentAnimation("till_remove") then
            inst2:Remove()
        end
    end)

    return inst
end

return Prefab("portableblender_soil_fx", fn)
