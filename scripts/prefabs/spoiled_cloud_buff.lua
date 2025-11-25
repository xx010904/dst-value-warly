local EXPLODETARGET_MUST_TAGS = { "_health", "_combat" }
local EXPLODETARGET_CANT_TAGS = { "INLIMBO", "notarget", "noattack", "flight", "invisible", "wall", "player", "companion", "structure" }

local function AlignToTarget(inst, target)
    inst.Transform:SetRotation(target.Transform:GetRotation())
end

local function OnChangeFollowSymbol(inst, target, followsymbol, followoffset)
    inst.Follower:FollowSymbol(target.GUID, followsymbol, followoffset.x, followoffset.y, followoffset.z)
end

local function damage_nearby(inst, target)
    if not target or not target:IsValid() then return end
    local x, y, z = target.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 4.88, EXPLODETARGET_MUST_TAGS, EXPLODETARGET_CANT_TAGS)

    for _, ent in ipairs(ents) do
        if ent and ent:IsValid() and ent.components.health and not ent:HasTag("player") then
            -- 计算目标和中心的距离
            local ex, ey, ez = ent.Transform:GetWorldPosition()
            local distance = math.sqrt((ex - x)^2 + (ey - y)^2 + (ez - z)^2)  -- 使用欧几里得距离

            -- 计算伤害，距离越近伤害越大
            local max_damage = inst.damage
            local min_damage = 1
            local max_distance = 4.88  -- 设定最大有效距离
            local damage = math.max(min_damage, max_damage * (1 - distance / max_distance))  -- 根据距离调整伤害

            -- 应用伤害
            ent.components.health:DoDelta(-damage)

            -- ⚠️ 施加减速与削弱 Buff
            if not ent.components.health:IsDead() then
                if ent:HasTag("spoiled_cloud_debuff") then
                    ent:RemoveDebuff("spoiled_cloud_debuff")
                end
                ent:AddDebuff("spoiled_cloud_debuff", "spoiled_cloud_debuff")
            end
        end
    end
end


local function PlusFxLastTime(inst)
    -- 获取剩余的生命周期
    local total_time = inst.components.timer:GetTimeLeft("lifetime")
    -- print("加钟了,", total_time)

    -- 如果 inst.clouds 存在，遍历它们
    if inst.clouds then
        for _, cloudfx in ipairs(inst.clouds) do
            if cloudfx and cloudfx.components.timer then
                -- 随机化生命周期时间，稍微减少一点时间
                cloudfx.components.timer:SetTimeLeft("lifetime", total_time - math.random())
            end
        end
    end

    -- 对 basefx 进行相同的操作
    if inst.basefx and inst.basefx.components.timer then
        inst.basefx.components.timer:SetTimeLeft("lifetime", total_time - math.random())
    end
end

local function AddCloudFx(inst)
    local total_time = inst.components.timer:GetTimeLeft("lifetime")
    local basefx = SpawnPrefab("spoiled_cloud_base_fx")
    if basefx ~= nil then
        basefx.entity:SetParent(inst.entity)
        basefx.components.timer:StartTimer("lifetime", total_time - math.random())
        inst.basefx = basefx
    end

    local radius = 2  -- 设置云朵围绕中心的半径
    -- 生成 6 个云朵，分布在圆周上
    for i = 1, 6 do
        local cloudfx = SpawnPrefab("spoiled_cloud_fx")
        if cloudfx ~= nil then
            cloudfx.entity:SetParent(inst.entity)

            -- 计算每个 cloudfx 的相对位置，使其围绕中心分布
            local angle = (i - 1) * 60  -- 每个云朵之间的角度间隔 60°
            local offset_x = radius * math.cos(math.rad(angle))  -- 计算 X 坐标偏移
            local offset_z = radius * math.sin(math.rad(angle))  -- 计算 Z 坐标偏移

            -- 将 cloudfx 放置在围绕中心的圆周上（相对位置）
            cloudfx.Transform:SetPosition(offset_x, 0, offset_z)  -- Y 位置保持不变，只有 X 和 Z 偏移

            -- 每个云朵旋转朝向对应的方向
            cloudfx.Transform:SetRotation(angle)

            cloudfx.components.timer:StartTimer("lifetime", total_time - math.random())

            table.insert(inst.clouds, cloudfx)
        end
    end
end

local function OnAttached(inst, target, followsymbol, followoffset)
    inst._target = target -- 在罐子上
    OnChangeFollowSymbol(inst, target, followsymbol, Vector3(followoffset.x, 100, followoffset.z)) --y越小，位置越高

    if inst._followtask ~= nil then
        inst._followtask:Cancel()
    end
    inst._followtask = inst:DoPeriodicTask(0, AlignToTarget, nil, target)
    AlignToTarget(inst, target)

    -- 增加云特效
    inst:DoTaskInTime(1*FRAMES, function()
        AddCloudFx(inst)
    end)

    -- 定期造成伤害
    inst._damagetask = inst:DoPeriodicTask(7*FRAMES, function() damage_nearby(inst, target) end)

    -- 持续时间
    inst.components.timer:StartTimer("lifetime", 1)

    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/spore_cloud_LP", "spore_loop")
end

local function OnDetached(inst)
    if inst._damagetask then
        inst._damagetask:Cancel()
        inst._damagetask = nil
    end
    inst._target.SoundEmitter:PlaySound("yotd2024/startingpillar/light2")
    inst._target = nil

    inst.SoundEmitter:KillSound("spore_loop")
    if inst.flies ~= nil then
        inst.flies:Remove()
        inst.flies = nil
    end
    inst:Remove()
end

local function ontimerdone(inst, data)
    if data.name == "lifetime" then
        inst.AnimState:PlayAnimation("sporecloud_pst")
        inst:ListenForEvent("animover", function (inst)
            inst.components.debuff:Stop()
        end)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddFollower()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("sporecloud")
    inst.AnimState:SetBuild("sporecloud")
    inst.AnimState:PlayAnimation("sporecloud_pre")
    inst.AnimState:PushAnimation("sporecloud_loop", true)
    inst.AnimState:SetLightOverride(.3)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.Transform:SetFourFaced()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(OnDetached)
    inst.components.debuff.keepondespawn = true

    inst.SoundEmitter:PlaySound("yotd2024/startingpillar/light1")

    inst.damage = 2.56
    inst.flies = inst:SpawnChild("flies")
    inst.basefx = nil
    inst.clouds = {}

    inst.PlusFxLastTime = PlusFxLastTime

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)

    return inst
end

return Prefab("spoiled_cloud_buff", fn)
