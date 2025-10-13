local function OnEaten(inst, eater)
    if eater and eater:IsValid() and eater.components then
        -- local buff_name = "warly_sky_pie_buff"

        -- -- 如果已经有buff
        -- if eater:HasDebuff(buff_name) then
        --     local buff_inst = eater:GetDebuff(buff_name)
        --     if buff_inst and buff_inst.components.timer then
        --         local remaining = buff_inst.components.timer:GetTimeLeft("explode") or 0
        --         local addtime = 200 -- 每吃一次增加200秒
        --         buff_inst.components.timer:SetTimeLeft("explode", remaining + addtime)
        --         -- 回复效果减半
        --         if eater.components.hunger then
        --             eater.components.hunger:DoDelta(25)
        --         end
        --         if eater.components.sanity then
        --             eater.components.sanity:DoDelta(25)
        --         end
        --         -- print("画大饼debuff剩余时间", remaining)
        --     end

        --     -- 播放台词
        --     if eater.components.talker then
        --         eater.components.talker:Say(GetString(eater, "ANNOUNCE_EAT_PIE_REPEATLY"))
        --     end
        -- else
        --     -- 没有buff，添加新的
        --     eater:AddDebuff(buff_name, buff_name)
        --     -- 回复效果正常
        --     if eater.components.hunger then
        --         eater.components.hunger:DoDelta(50)
        --     end
        --     if eater.components.sanity then
        --         eater.components.sanity:DoDelta(50)
        --     end
        -- end
        if eater:HasDebuff("warly_sky_pie_inspire_buff") then
            if eater.components.talker then
                eater.components.talker:Say(GetString(eater, "ANNOUNCE_EAT_PIE_REPEATLY"))
            end
        else
            if eater.components.talker then
                eater.components.talker:Say(GetString(eater, "ANNOUNCE_EAT_PIE"))
            end
            eater:AddDebuff("warly_sky_pie_inspire_buff", "warly_sky_pie_inspire_buff")
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

    inst.AnimState:SetBank("warly_sky_pie")
    inst.AnimState:SetBuild("warly_sky_pie")
    inst.AnimState:PlayAnimation("idle", true)

    MakeInventoryFloatable(inst, "small", 0.2, 0.95)

    inst:AddTag("warly_sky_pie")
    inst:AddTag("cookable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "warly_sky_pie"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/warly_sky_pie.xml"

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.GOODIES
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = 0
    inst.components.edible.sanityvalue = 0
    inst.components.edible:SetOnEatenFn(OnEaten)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("cookable")
    inst.components.cookable.product = function(inst, cooker, chef)
        -- return MakeSpicedFood(inst, cooker, chef)
    end

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("warly_sky_pie", fn, {})