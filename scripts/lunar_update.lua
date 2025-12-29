local rottenCloudDurationPerRot = warlyvalueconfig.rottenCloudDurationPerRot or 2.5
-- 0 = 腐烂物 → 桶
-- 1 = 桶 → 腐烂物
local spoiledCloudUseMode = warlyvalueconfig.spoiledCloudUseMode or 0

if spoiledCloudUseMode == 0 then
    AddPrefabPostInit("spoiled_food", function(inst)
        inst:AddComponent("activespoiledcloudtool")
    end)
    AddPrefabPostInit("spoiled_fish", function(inst)
        inst:AddComponent("activespoiledcloudtool")
    end)
    AddPrefabPostInit("spoiled_fish_small", function(inst)
        inst:AddComponent("activespoiledcloudtool")
    end)
    AddPrefabPostInit("rottenegg", function(inst)
        inst:AddComponent("activespoiledcloudtool")
    end)
else
    AddPrefabPostInit("beargerfur_sack", function(inst)
        inst:AddComponent("activespoiledcloudtool")
    end)
    AddPrefabPostInit("coonfur_sack", function(inst)
        inst:AddComponent("activespoiledcloudtool")
    end)
end



--========================================================
-- 释放腐烂云雾
--========================================================
local function ApplySpoiledCloud(doer, rot, sack)
    if not (doer and sack and rot) then
        print("[ApplySpoiledCloud] Abort: invalid params")
        return false
    end

    if not doer:HasTag("warly_allegiance_lunar") then
        print("[ApplySpoiledCloud] Abort: doer has no warly_allegiance_lunar")
        return false
    end

    local damage = 0
    if sack.prefab == "beargerfur_sack" then
        damage = 5.2
    elseif sack.prefab == "coonfur_sack" then
        damage = 2.6
    else
        print("[ApplySpoiledCloud] Abort: invalid sack prefab =", sack.prefab)
        return false
    end

    local stacksize = rot.components.stackable and rot.components.stackable.stacksize or 1

    local buffname = "spoiled_cloud_buff"

    if not sack:HasDebuff(buffname) then
        sack:AddDebuff(buffname, buffname)
    else
        print("[ApplySpoiledCloud] Refresh buff =", buffname)
    end

    local buff_inst = sack:GetDebuff(buffname)
    if buff_inst and buff_inst.components.timer then
        buff_inst.damage = damage

        local time_left = buff_inst.components.timer:GetTimeLeft("lifetime") or 0
        local add_time = stacksize * rottenCloudDurationPerRot
        local final_time = time_left + add_time
        buff_inst.components.timer:SetTimeLeft("lifetime", final_time)

        if buff_inst.PlusFxLastTime then
            buff_inst:PlusFxLastTime()
        end
    else
        print("[ApplySpoiledCloud] Warning: buff_inst or timer missing")
    end

    rot:Remove()

    return true
end


local SPOILED_ON_SACK = Action({ priority = 1, mount_valid = true })
SPOILED_ON_SACK.id = "SPOILED_ON_SACK"
SPOILED_ON_SACK.str = STRINGS.ACTIONS.SPOILED_ON_SACK
SPOILED_ON_SACK.fn = function(act)
    if spoiledCloudUseMode == 0 then
        -- 模式=0，腐烂物invobject → 桶target
        return ApplySpoiledCloud(act.doer, act.invobject, act.target)
    else
        -- 模式=1，桶invobject → 腐烂物target
        return ApplySpoiledCloud(act.doer, act.target, act.invobject)
    end
end
AddAction(SPOILED_ON_SACK)

if spoiledCloudUseMode == 0 then
    AddComponentAction("USEITEM", "activespoiledcloudtool", function(inst, doer, target, actions)
        if doer:HasTag("warly_allegiance_lunar") and target
            and (target.prefab == "beargerfur_sack" or target.prefab == "coonfur_sack") then
            table.insert(actions, ACTIONS.SPOILED_ON_SACK)
        end
    end)
else
    AddComponentAction("USEITEM", "activespoiledcloudtool", function(inst, doer, target, actions)
        if doer:HasTag("warly_allegiance_lunar") and target and
            (target.prefab == "spoiled_food" or target.prefab == "spoiled_fish" or target.prefab == "spoiled_fish_small" or target.prefab == "rottenegg") then
            table.insert(actions, ACTIONS.SPOILED_ON_SACK)
        end
    end)
end
-- 加个新的SG
local warlyIdleState = State {
    name = "spoiled_on_sack", -- 新状态名称
    tags = { "doing", "busy" },

    onenter = function(inst)
        -- 进入状态时无敌
        inst.components.health.invincible = true
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:RemotePausePrediction()
            inst.components.playercontroller:Enable(false)
            inst.components.playercontroller:EnableMapControls(false)
        end
        inst.components.inventory:Hide()
        inst:SetCameraDistance(14)

        -- 停止角色移动
        inst.sg:SetTimeout(66 * FRAMES)  -- 设置超时为 66 帧（动画持续时间）
        inst.components.locomotor:Stop() -- 停止移动

        -- 播放 idle_warly 动画
        inst.AnimState:PlayAnimation("idle_warly", false)
        inst.AnimState:SetTime(0) -- 确保动画从头开始播放

        inst:PerformBufferedAction()
    end,

    timeline =
    {
        -- 在 66 帧后移除 "busy" 状态，切换回空闲状态
        TimeEvent(66 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("busy")
        end),
    },

    ontimeout = function(inst)
        -- 动画播放完后切换到 idle 状态
        inst.AnimState:PlayAnimation("idle", true)
        inst.sg:GoToState("idle", true)
    end,

    events =
    {
        -- 动画队列完成时，切换到 idle 状态
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },

    onexit = function(inst)
        -- 清除缓冲的动作（如果有）
        inst:ClearBufferedAction()
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:EnableMapControls(true)
            inst.components.playercontroller:Enable(true)
        end
        inst:SetCameraDistance()
        if not inst.sg.statemem.keep_open then
            inst.components.inventory:Show()
        end
        -- 离开状态时取消无敌
        inst.components.health.invincible = false
    end,
}

-- 将状态添加到服务端的 StateGraph
AddStategraphState('wilson', warlyIdleState)


local warlyIdleState_Client = State {
    name = "spoiled_on_sack",              -- 新状态名称
    tags = { "doing", "busy" },
    server_states = { "spoiled_on_sack" }, -- 确保客户端和服务端同步状态

    onenter = function(inst)
        -- 停止角色移动
        inst.components.locomotor:Stop() -- 停止移动

        -- 播放 idle_warly 动画
        inst.AnimState:PlayAnimation("idle_warly", false)
        inst.AnimState:SetTime(0) -- 确保动画从头开始播放

        -- 设置超时，确保动画播放 66 帧
        inst.sg:SetTimeout(66 * FRAMES)

        inst:PerformPreviewBufferedAction()
    end,

    timeline =
    {
        -- 在 66 帧后移除 "busy" 状态，切换回空闲状态
        TimeEvent(66 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("busy")
        end),
    },

    ontimeout = function(inst)
        -- 动画播放完后切换到 idle 状态
        inst.AnimState:PlayAnimation("idle", true)
        inst.sg:GoToState("idle", true)
    end,

    events =
    {
        -- 动画队列完成时，切换到 idle 状态
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },

    onexit = function(inst)
        -- 清除缓冲的动作（如果有）
        inst:ClearBufferedAction()
    end,
}

-- 将状态添加到客户端的 StateGraph
AddStategraphState('wilson_client', warlyIdleState_Client)


-- 为 wilson 和 wilson_client 添加新的动作处理
AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.SPOILED_ON_SACK, "spoiled_on_sack"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.SPOILED_ON_SACK, "spoiled_on_sack"))


--========================================================
-- 猫尾桶配方
--========================================================
AddRecipe2("coonfur_sack",
    {
        Ingredient("bluegem", 1),
        Ingredient("coontail", 3),
        Ingredient("moonglass", 3),
        Ingredient("marble", 5),
    },
    TECH.NONE,
    {
        product = "coonfur_sack", -- 唯一id
        atlas = "images/inventoryimages/coonfur_sack.xml",
        image = "coonfur_sack.tex",
        builder_tag = "masterchef",
        builder_skill = "warly_allegiance_lunar", -- 指定技能树才能做
        description = "coonfur_sack",             -- 描述的id，而非本身
        numtogive = 1,
    }
)
AddRecipeToFilter("coonfur_sack", "CHARACTER")

-- 猫尾桶格子定义
local containers = require("containers")
local params = containers.params
params.coonfur_sack =
{
    widget =
    {
        slotpos        = {},
        slotbg         = {},
        animbank       = "ui_icepack_2x3",
        animbuild      = "ui_icepack_2x3",
        pos            = Vector3(75, 195, 0),
        side_align_tip = 160,
    },
    acceptsstacks = false,
    type = "chest",
}

for y = 0, 2 do
    for x = 0, 1 do
        table.insert(params.coonfur_sack.widget.slotpos, Vector3(-163 + (75 * x), -75 * y + 73, 0))
        table.insert(params.coonfur_sack.widget.slotbg, { image = "preparedfood_slot.tex", atlas = "images/hud2.xml" })
    end
end

function params.coonfur_sack.itemtestfn(container, item, slot)
    -- Prepared food.
    return item:HasTag("beargerfur_sack_valid") or item:HasTag("preparedfood")
end
