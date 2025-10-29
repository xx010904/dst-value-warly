---------------------------------------------------------
-- 随机调味逻辑
---------------------------------------------------------
local function GetRandomFlavor()
    local spicepool = {
        { prefab = "spice_salt",  weight = 30 },
        { prefab = "spice_sugar", weight = 25 },
        { prefab = "spice_chili", weight = 20 },
        { prefab = "spice_garlic",  weight = 15 },
        { prefab = "ash",         weight = 10 },
    }

    local total = 0
    for _, v in ipairs(spicepool) do total = total + v.weight end
    local roll = math.random() * total
    for _, v in ipairs(spicepool) do
        roll = roll - v.weight
        if roll <= 0 then
            return v.prefab
        end
    end
end

---------------------------------------------------------
-- 动画逻辑
---------------------------------------------------------
local HIT_DURATION = 3  -- hit 动画持续时间

-- 生成随机位置的 FX
local function SpawnNearbyFXLoop(x, y, z, remainingTime)
    if remainingTime <= 0 then
        return
    end
    SpawnPrefab("groundpound_fx").Transform:SetPosition(x, y, z)

    -- 随机生成 1~3 个 FX
    local count = math.random(1, 3)
    for i = 1, count do
        local fx = SpawnPrefab("portableblender_soil_fx")
        if fx then
            local offset_x = (math.random() - 0.5) * 0.4 -- ±0.2 范围
            local offset_z = (math.random() - 0.5) * 0.4
            fx.Transform:SetPosition(x + offset_x, y, z + offset_z)
        end
    end

    -- 随机间隔 0.1~0.6 秒再次调用自己
    local interval = 0.1 + math.random() * 0.5
    remainingTime = remainingTime - interval

    TheWorld:DoTaskInTime(interval, function()
        SpawnNearbyFXLoop(x, y, z, remainingTime)
    end)
end


local function PlaySequence(inst)
    if not inst or not inst:IsValid() then
        return
    end

    inst.AnimState:PlayAnimation("hit", true)
    inst.SoundEmitter:PlaySound("grotto/common/turf_crafting_station/prox_LP", "loop_sound")

    local x, y, z = inst.Transform:GetWorldPosition()

    -- 在 hit 播放期间随机生成 FX
    SpawnNearbyFXLoop(x, y, z, HIT_DURATION + math.random()) -- 每次生成 1~3 个

    -- 3 秒后播放 collapse
    inst:DoTaskInTime(HIT_DURATION, function()
        if inst:IsValid() then
            inst.AnimState:PlayAnimation("collapse")
        end
    end)

    inst:ListenForEvent("animover", function(inst2)
        if inst2.AnimState:IsCurrentAnimation("collapse") then
            inst2.SoundEmitter:KillSound("loop_sound")
            -- 掉落调味料
            local spice = GetRandomFlavor()
            if spice then
                local item = SpawnPrefab(spice)
                if item then
                    item.Transform:SetPosition(x + math.random() * 0.3, y, z + math.random() * 0.3)
                    Launch2(item, inst2, 1.5, 1.25, 0.3, 0, 2)
                end
            end

            -- 重生研磨器
            local newblender = SpawnPrefab("portableblender_item")
            if newblender then
                newblender.Transform:SetPosition(x, y, z)
            end

            inst2:Remove()
        end
    end)
end

---------------------------------------------------------
-- prefab 本体
---------------------------------------------------------
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("portable_blender")
    inst.AnimState:SetBuild("portable_blender")
    inst.AnimState:PlayAnimation("hit", true)
    inst.AnimState:SetSortOrder(2)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")

    inst.persists = false

    if not TheWorld.ismastersim then
        return inst
    end

    -- 启动动画序列
    inst:DoTaskInTime(0, PlaySequence)

    return inst
end

return Prefab("portableblender_sacrifice_fx", fn)
