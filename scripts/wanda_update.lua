local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler

local TorchFuelConsumption = wilsonvalueconfig.TorchFuelConsumption
local TorchRadius = wilsonvalueconfig.TorchRadius
local IsNewTree = wilsonvalueconfig.IsNewTree

if TorchToss ~= 1 then

    local function GetPointSpecialActions(inst, pos, useitem, right)
        if right then
            if useitem == nil then
                local inventory = inst.replica.inventory
                if inventory ~= nil then
                    useitem = inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                end
            end
            if useitem
                and inst.components.skilltreeupdater:IsActivated("wilson_torch_7")
                and useitem:HasTag("special_action_toss")
                and ((useitem.prefab == "lunar_torch" and inst.components.skilltreeupdater:IsActivated("wilson_allegiance_lunar"))
                 or useitem.prefab == "torch")
            then
                return { ACTIONS.TOSS_SCIENCE }
            end
        end
        return {}
    end

    local function OnSetOwner(inst)
        if inst.components.playeractionpicker ~= nil then
            inst.components.playeractionpicker.pointspecialactionsfn = GetPointSpecialActions
        end
    end

    local function ReticuleTargetFn()
        local player = ThePlayer
        local ground = TheWorld.Map
        local pos = Vector3()
        local TorchToss = wilsonvalueconfig.TorchToss --Toss range is 8 
        for r = (6.5*TorchToss), 1, -.25 do
            pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
            if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
                return pos
            end
        end
        pos.x, pos.y, pos.z = player.Transform:GetWorldPosition()
        return pos
    end

    function UpdateOverheatprotectionSpells(inst)
        if not inst.components.beard then
            inst:AddComponent("beard")
        end
        inst:StartUpdatingComponent(inst.components.beard) -- 每帧检测
    end

    AddPrefabPostInit("wilson", function (inst)
        inst.components.reticule.targetfn = ReticuleTargetFn
        inst:ListenForEvent("setowner", OnSetOwner)

        local onskillrefresh_client = function(inst) UpdateOverheatprotectionSpells(inst) end
        local onskillrefresh_server = function(inst) UpdateOverheatprotectionSpells(inst) end
        inst:ListenForEvent("onactivateskill_server", onskillrefresh_server)
		inst:ListenForEvent("ondeactivateskill_server", onskillrefresh_server)
        inst:ListenForEvent("onactivateskill_client", onskillrefresh_client)
		inst:ListenForEvent("ondeactivateskill_client", onskillrefresh_client)
        
        -- inst.components.beard:EnableGrowth(false)
    end)
end


local function IsOcean(x, y, z)
    -- 检查给定位置是否是陆地
    local tile = TheWorld.Map:GetTileAtPoint(x, y, z)
    return IsOceanTile(tile)
end
local function CanDeploy(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    return inst.canoverlap or TheWorld.Map:IsDeployPointClear(Vector3(x, y, z), nil, 1)
end
local function IsPossbleLand(x, y, z)
    -- local x, y, z = inst.Transform:GetWorldPosition()
    return TheWorld.Map:IsPassableAtPoint(x, y, z)
        and not IsOcean(x, y, z)
end

local function MoveToNearestLand(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    if IsPossbleLand(x, y, z) and CanDeploy(inst) then
        -- print("IsPossbleLand"..tostring(IsPossbleLand(x, y, z)))
        -- print("CanDeploy:"..tostring(CanDeploy(inst)))
        return
    end

    -- print("FindNearestLand"..tostring(IsPossbleLand(x, y, z)))
    -- print("FindNearestLand:"..tostring(CanDeploy(inst)))
    -- 查找附近的陆地
    local sx, sy, sz = FindRandomPointOnShoreFromOcean(x, y, z)
    if sx ~= nil then
        inst.Transform:SetPosition(sx, sy, sz)
        inst.components.health:DoDelta(-inst.components.health.currenthealth * 0.111)  -- 落水伤害
    end
end

if IsNewTree then
    AddStategraphPostInit("wilson_client", function(sg)
        if sg.states and sg.states.knockback then
            local oldonexit = sg.states.knockback.onexit
            sg.states.knockback.onexit = function(inst)
                if oldonexit then
                    MoveToNearestLand(inst)
                    oldonexit(inst)
                end
            end
        end
    end)
    AddStategraphPostInit("wilson_client", function(sg)
        if sg.states and sg.states.knockbacklanded then
            local oldonexit = sg.states.knockbacklanded.onexit
            sg.states.knockbacklanded.onexit = function(inst)
                if oldonexit then
                    MoveToNearestLand(inst)
                    oldonexit(inst)
                end
            end
        end
    end)

    AddStategraphPostInit("wilson", function(sg)
        if sg.states and sg.states.knockback then
            local oldonexit = sg.states.knockback.onexit
            sg.states.knockback.onexit = function(inst)
                if oldonexit then
                    MoveToNearestLand(inst)
                    oldonexit(inst)
                end
            end
        end
    end)
    AddStategraphPostInit("wilson", function(sg)
        if sg.states and sg.states.knockbacklanded then
            local oldonexit = sg.states.knockbacklanded.onexit
            sg.states.knockbacklanded.onexit = function(inst)
                if oldonexit then
                    MoveToNearestLand(inst)
                    oldonexit(inst)
                end
            end
        end
    end)
end