---------------------------------------------------------
-- 随机调味逻辑
---------------------------------------------------------
local function GetRandomSpice()
    -- 1.从官方调料中选择
    if math.random() < 0.5 then
        local spicepool = {
            { prefab = "spice_salt",   weight = 30 },
            { prefab = "spice_sugar",  weight = 35 },
            { prefab = "spice_chili",  weight = 35 },
            { prefab = "spice_garlic", weight = 35 },
            { prefab = "ash",          weight = 15 },
            { prefab = "hound",        weight = 15 },
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
    else
        -- 2.否则从全局调料表中选择
        local spicepool = _G.ALL_SPICES
        local valid = {}
        for spice, _ in pairs(spicepool) do
            table.insert(valid, spice)
        end
        return valid[math.random(1, #valid)]
    end
end

---------------------------------------------------------
-- 动画逻辑
---------------------------------------------------------
local HIT_DURATION = 3 -- hit 动画持续时间

-- 生成随机位置的 FX
local function SpawnNearbyFXLoop(x, y, z, remainingTime)
    if remainingTime <= 0 then
        return
    end
    SpawnPrefab("groundpound_fx").Transform:SetPosition(x, y, z)

    -- 随机生成 1~2 个 FX
    local count = math.random(1, 2)
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

    local x, y, z = inst.Transform:GetWorldPosition()

    -- 播放 place 动画和声音
    inst.AnimState:PlayAnimation("place")
    inst.SoundEmitter:PlaySound("dontstarve/common/together/portable/blender/place")

    -- 等 place 动画播放完后再播放 hit 动画和 loop 声音
    inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(), function()
        if inst and inst:IsValid() then
            -- 播放 hit 动画和循环声音
            inst.AnimState:PlayAnimation("hit", true)
            inst.SoundEmitter:PlaySound("grotto/common/turf_crafting_station/prox_LP", "loop_sound")

            -- 在 hit 播放期间随机生成 FX
            SpawnNearbyFXLoop(x, y, z, HIT_DURATION)

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
                    local spicePrefab = GetRandomSpice()
                    if spicePrefab then
                        if spicePrefab == "hound" then
                            if TheWorld.ismastersim then
                                local hound = SpawnPrefab("hound")
                                hound.Transform:SetPosition(x + math.random() * 0.3, y, z + math.random() * 0.3)
                                hound.sg:GoToState("mutated_spawn")
                                -- hound.components.health:SetPercent(math.random())
                            else
                                local worm = SpawnPrefab("worm")
                                worm.Transform:SetPosition(x + math.random() * 0.3, y, z + math.random() * 0.3)
                                worm.sg:GoToState("lure_enter")
                                -- worm.components.health:SetPercent(math.random())
                            end
                        else
                            local item = SpawnPrefab(spicePrefab)
                            item.Transform:SetPosition(x + math.random() * 0.3, y, z + math.random() * 0.3)
                            Launch2(item, inst2, 1.5, 1.25, 0.3, 0, 2)
                            SpawnPrefab("sand_puff_large_front").Transform:SetPosition(item.Transform:GetWorldPosition())
                        end
                    end

                    -- 重生研磨器
                    local newblender = SpawnPrefab("portableblender_item", inst.linked_skinname, inst.skin_id)
                    if newblender then
                        newblender.Transform:SetPosition(x, y, z)
                        newblender.SoundEmitter:PlaySound("dontstarve/common/together/portable/blender/collapse")
                    end

                    inst2:Remove()
                end
            end)
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

    inst:SetPhysicsRadiusOverride(.5)
    MakeObstaclePhysics(inst, inst.physicsradiusoverride)

    inst.AnimState:SetBank("portable_blender")
    inst.AnimState:SetBuild("portable_blender")
    inst.AnimState:PlayAnimation("idle_ground")

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
