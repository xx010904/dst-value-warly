local NUM_PERDS = 3
local RADIUS = 6.5       -- 跑动半径
local ROTATE_SPEED = 1.5 -- 每秒旋转速度（弧度）
local BUFF_DURATION_BASE = 44

local INSTANT_TARGET_MUST_HAVE_TAGS = { "_combat", "_health" }
local INSTANT_TARGET_CANTHAVE_TAGS = { "INLIMBO", "structure", "butterfly", "wall", "balloon", "groundspike", "smashable", "player", "companion" }

-- 创建火鸡围绕玩家旋转
local function MakePerdFollowInCircle(inst, num_perds)
    num_perds = num_perds or NUM_PERDS

    local target = inst
    if not target then return end

    if not target.perd_runners then
        target.perd_runners = {}
    end

    -- 清理旧的
    for _, v in ipairs(target.perd_runners) do
        if v:IsValid() then
            v:Remove()
        end
    end
    target.perd_runners = {}

    -- 创建火鸡
    for i = 1, num_perds do
        local perd = SpawnPrefab("perd")
        perd:SetBrain(nil)
        perd.persists = false
        perd.entity:SetCanSleep(false)
        MakeInventoryPhysics(perd)
        perd.Transform:SetPosition(target.Transform:GetWorldPosition())
        perd:AddComponent("named")
        perd.components.named:SetName(STRINGS.NAMES.NOOB_CHICKEN)

        perd._owner = target
        perd._index = i

        -- 嘲讽开启
        perd:DoPeriodicTask(0.5 + math.random(), function()
            if perd and perd:IsValid() and perd.components.combat then
                local x, y, z = perd.Transform:GetWorldPosition()
                local entities_near_perd = TheSim:FindEntities(x, y, z, RADIUS, INSTANT_TARGET_MUST_HAVE_TAGS,
                    INSTANT_TARGET_CANTHAVE_TAGS)
                for _, ent in ipairs(entities_near_perd) do
                    if ent:IsValid() and ent.components.combat then
                        ent.components.combat:SetTarget(perd)
                    end
                end
            end
        end)

        -- 火鸡死亡回调
        perd:ListenForEvent("death", function()
            if target.perd_runners then
                for j, v in ipairs(target.perd_runners) do
                    if perd and v == perd then
                        SpawnPrefab("weregoose_transform_fx").Transform:SetPosition(perd.Transform:GetWorldPosition())
                        if inst then
                            SpawnPrefab("weregoose_transform_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
                        end
                        table.remove(target.perd_runners, j)
                        break
                    end
                end
                if #target.perd_runners == 0 then
                    -- 所有火鸡死亡，移除Debuff
                    if target.debuff_parent and target.debuff_parent.components.debuff then
                        target.debuff_parent.components.debuff:Stop()
                    end
                end
            end
        end)

        table.insert(target.perd_runners, perd)
    end

    -- 全局旋转任务
    local angle = 0
    target._perd_rotate_task = target:DoPeriodicTask(FRAMES, function(dt)
        if not target:IsValid() then return end

        angle = angle + ROTATE_SPEED * FRAMES
        local owner_pos = target:GetPosition()

        for i, perd in ipairs(target.perd_runners) do
            if perd:IsValid() then
                if not perd._owner or not perd._owner:IsValid() then
                    perd:Remove()
                    return
                end
                local offset_angle = (i - 1) * (2 * PI / num_perds)
                local next_angle = angle + offset_angle
                local target_x = owner_pos.x + math.cos(next_angle) * RADIUS
                local target_z = owner_pos.z + math.sin(next_angle) * RADIUS
                local target_pos = Vector3(target_x, 0, target_z)

                local current_pos = perd:GetPosition()
                local dist = distsq(current_pos, target_pos) -- 计算距离平方
                if dist > 225 then                           -- 15^2 = 225
                    -- 距离太远，瞬移
                    perd.Transform:SetPosition(target_x, 0, target_z)
                else
                    -- 平滑移动
                    if perd.components.locomotor then
                        perd.components.locomotor:GoToPoint(target_pos, nil, true)
                    end
                end
            end
        end
        if not target:HasTag("groggy") then
            target:AddTag("groggy")
        end
    end)
end

-- Debuff绑定
local function OnAttached(inst, target)
    if not target then
        inst:Remove()
        return
    end

    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0)
    inst.target = target
    target.debuff_parent = inst

    -- 生成火鸡
    local num_perds = inst.saved_num_perds or NUM_PERDS
    MakePerdFollowInCircle(target, num_perds)

    -- Buff持续时间
    inst.components.timer:StartTimer("expire", BUFF_DURATION_BASE)
    -- print("菜鸡buff剩余时间", inst.components.timer:GetTimeLeft("expire"))

    target.components.locomotor:SetExternalSpeedMultiplier(inst, "warly_noob_debuff", 0.2333)
end

local function OnDetached(inst, target)
    if target then
        -- 清理火鸡
        if target._perd_rotate_task then
            target._perd_rotate_task:Cancel()
            target._perd_rotate_task = nil
        end
        if target.perd_runners then
            for _, v in ipairs(target.perd_runners) do
                -- print("还剩几个火鸡:", #target.perd_runners)
                v:DoTaskInTime(0, function()
                    if v:IsValid() and v.components.health then
                        v.components.health:Kill()
                        -- print("火鸡被干掉了", v.GUID)
                    end
                end)
            end
            target.perd_runners = nil
        end
        target.debuff_parent = nil
    end
    target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "warly_noob_debuff")
    if target.components.grogginess and not target.components.grogginess:IsGroggy() then
        target:RemoveTag("groggy")
    end

    target:DoTaskInTime(0, function()
        target.AnimState:PlayAnimation("pyrocast")
    end)
    inst:DoTaskInTime(1 * FRAMES, inst.Remove)
end

local function OnTimerDone(inst, data)
    if data.name == "expire" then
        if inst.components.debuff then
            inst.components.debuff:Stop()
        end
    end
end

-- 保存火鸡数量
local function OnSave(inst, data)
    if inst.target and inst.target.perd_runners then
        data.num_perds = #inst.target.perd_runners
    end
end

-- 加载火鸡数量
local function OnLoad(inst, data)
    if data and data.num_perds then
        inst.saved_num_perds = data.num_perds
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddFollower()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("debuff")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(OnDetached)
    inst.components.debuff.keepondespawn = true

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", OnTimerDone)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("warly_noob_debuff", fn, {})
