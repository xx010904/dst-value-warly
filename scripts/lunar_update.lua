AddPrefabPostInit("spoiled_food", function(inst)
    inst:AddComponent("activespoiledcloudtool")
end)

local SPOILED_ON_SACK = Action({ priority = 1, mount_valid = true })
SPOILED_ON_SACK.id = "SPOILED_ON_SACK"
SPOILED_ON_SACK.str = "Use Spoiled Food"
SPOILED_ON_SACK.fn = function(act)
    local target = act.target
    local item = act.invobject
    local doer = act.doer

    if target and target.prefab == "beargerfur_sack" and item then
        local stacksize = item.components.stackable and item.components.stackable.stacksize or 1
        local buffname = "spoiled_cloud_buff" -- 对应你的 buff 名称

        -- 添加或刷新 buff
        if not target:HasDebuff(buffname) then
            target:AddDebuff(buffname, buffname)
        end

        -- 获取 buff 实例并设置持续时间
        local buff_inst = target:GetDebuff(buffname)
        if buff_inst and buff_inst.components.timer then
            local time_left = buff_inst.components.timer:GetTimeLeft("lifetime")
            buff_inst.components.timer:SetTimeLeft("lifetime", stacksize + time_left)
        end

        -- 消耗腐烂物
        if item.components.stackable then
            item.components.stackable:Get():Remove()
        else
            item:Remove()
        end

        return true
    end
    return false
end

AddAction(SPOILED_ON_SACK)


AddComponentAction("USEITEM", "activespoiledcloudtool", function(inst, doer, target, actions)
    if target.prefab == "beargerfur_sack" then
        table.insert(actions, ACTIONS.SPOILED_ON_SACK)
    end
end)

-- 定义SG
AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.SPOILED_ON_SACK, "give"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.SPOILED_ON_SACK, "give"))
