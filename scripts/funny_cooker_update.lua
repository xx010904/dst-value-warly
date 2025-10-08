-- 下饭操作 Meal-worthy Play
-- 1 “沃利看到别人做出垃圾料理时，被激发厨师灵魂，做出下饭菜”，展示厨艺，记忆次数满时，当场跟陪一份下饭菜：就地自动烹饪一份随机下饭菜
--   胡乱烹饪（潮湿黏糊，粉末蛋糕，怪物千层饼，怪物鞑靼，曼德拉草汤）
--   胡乱烤（曼德拉草 夜莓 孵化中的高脚鸟蛋 龙虾）
--   不能容忍珍贵食材或别有用途的食物被吃掉：黄油 眼球 守护者之角 蜂王浆 曼德拉草 高脚鸟蛋 孵化中的高脚鸟蛋 泻根糖浆 格罗姆的黏液 海带补丁 象鼻、冬象鼻
--   不能容忍珍贵料理被非玩家吃掉：羊角冻 鲜果可丽饼
-- 2 随机下饭菜概率带调料
-- 3 直接回饥饿精神和血量（避免食物记忆）
-- 4 队友死了烹饪四菜一汤


--========================================================
-- 沃利监听下饭操作事件
--========================================================
local function TrySpawnImprovCookPot(doer)
    -- 5% 触发概率
    if math.random() >= 0.95 then
        return
    end

    doer:DoTaskInTime(0.1, function()
        doer.AnimState:PlayAnimation("pyrocast")
    end)

    local x, y, z = doer.Transform:GetWorldPosition()
    local spawn_x, spawn_y, spawn_z
    local found = false
    for i = 1, 24 do
        local angle = math.random() * 2 * PI
        local tx = x + math.cos(angle) * math.random(1, 6)
        local tz = z + math.sin(angle) * math.random(1, 6)
        if TheWorld.Map:IsPassableAtPoint(tx, 0, tz) and not TheWorld.Map:IsOceanAtPoint(tx, 0, tz) then
            local nearby_fx = TheSim:FindEntities(tx, 0, tz, 3.5, { "FX", "improv_cookpot_fx" })
            if #nearby_fx == 0 then
                spawn_x, spawn_y, spawn_z = tx, 0, tz
                found = true
                break
            end
        end
    end

    -- 如果所有距离都没找到，就默认玩家脚下
    if not found then
        spawn_x, spawn_y, spawn_z = x, 0, z
    end

    local fx = SpawnPrefab("lucy_transform_fx")
    fx.entity:SetParent(doer.entity)
	fx.entity:AddFollower()
	fx.Follower:FollowSymbol(doer.GUID, "hair", 0, 0, 0)

    local proj = SpawnPrefab("improv_cookpot_projectile_fx")
    proj.Transform:SetPosition(x, y, z)
    proj.components.complexprojectile:Launch(Vector3(spawn_x, spawn_y, spawn_z), doer)
end

AddPlayerPostInit(function(inst)
    inst:ListenForEvent("funny_play_warly", function(inst, data)
        if inst.prefab == "warly" then
            TrySpawnImprovCookPot(inst)

            local food_name = data.item
            local operation = data.operation
            local doer = data.doer

            -- 判断 doer 是否为玩家
            local doer_is_player = doer and doer:HasTag("player")

            -- 沃利说话，基于操作类型和 doer 的角色说不同的台词
            if operation == "eat" then
                if doer_is_player then
                    if food_name == "glommerfuel" or food_name == "royal_jelly" or food_name == "tallbirdegg" or food_name == "tallbirdegg_cracked" then
                        -- 使用占位符填充 food_name 和 doer.prefab
                        inst.components.talker:Say(GetString(inst, "ANNOUNCE_EATS_SMALL_RECOVERY"))
                    elseif food_name == "ancientfruit_nightvision" and food_name == "butter"
                        and food_name == "freshfruitcrepes" and food_name == "voltgoatjelly" then
                        -- 不说话，因为本来就是给人吃的
                    elseif food_name == "deerclops_eyeball" or food_name == "minotaurhorn" or food_name == "mandrake" then
                        inst.components.talker:Say(GetString(inst, "ANNOUNCE_EATS_LARGE_RECOVERY"))
                    else
                        inst.components.talker:Say(GetString(inst, "ANNOUNCE_EATS_NORMAL_RECOVERY"))
                    end
                else
                    -- 如果是其他生物吃
                    inst.components.talker:Say(GetString(inst, "ANNOUNCE_EATS_BY_ANIMAL"))
                end
            elseif operation == "cook_fire" then
                inst.components.talker:Say(GetString(inst, "ANNOUNCE_COOKS_FOOD"))
            elseif operation == "harvest_pot" then
                inst.components.talker:Say(GetString(inst, "ANNOUNCE_HARVESTS_POT"))
            end

            -- 根据食物和 doer 的判断执行恢复操作
            if operation == "eat" then
                -- 判断玩家吃的食物
                if doer_is_player then
                    if food_name == "glommerfuel" or food_name == "royal_jelly" or food_name == "tallbirdegg" or food_name == "tallbirdegg_cracked" then
                        -- 玩家吃这些食物，沃利少量回复
                        inst.components.hunger:DoDelta(10) -- 少量饥饿
                        inst.components.sanity:DoDelta(10) -- 少量精神
                        inst.components.health:DoDelta(5)  -- 少量回血
                    elseif food_name == "ancientfruit_nightvision" and food_name == "butter"
                        and food_name == "freshfruitcrepes" and food_name == "voltgoatjelly" then
                        -- 玩家吃古老果实夜视，沃利不回复
                        -- print("[HOOK] Player eats ancientfruit_nightvision, no recovery.")
                    elseif food_name == "deerclops_eyeball" or food_name == "minotaurhorn" or food_name == "mandrake" then
                        -- 这类食物无论是谁吃，沃利巨量回复
                        inst.components.hunger:DoDelta(250)
                        inst.components.sanity:DoDelta(200)
                        inst.components.health:DoDelta(150)
                    else
                        -- 其他正常食物，沃利默认回复
                        inst.components.hunger:DoDelta(30)
                        inst.components.sanity:DoDelta(30)
                        inst.components.health:DoDelta(15)
                    end
                else
                    -- 如果是其他生物吃
                    if food_name == "deerclops_eyeball" or food_name == "minotaurhorn" or food_name == "mandrake" and food_name == "butter"
                        and food_name == "freshfruitcrepes" and food_name == "voltgoatjelly" then
                        -- 这类食物给其他生物吃，沃利巨量回复
                        inst.components.hunger:DoDelta(250)
                        inst.components.sanity:DoDelta(200)
                        inst.components.health:DoDelta(150)
                    else
                        -- 其他正常食物，沃利默认回复
                        inst.components.hunger:DoDelta(30)
                        inst.components.sanity:DoDelta(60)
                        inst.components.health:DoDelta(15)
                    end
                end
                -- 播放小气泡
                local puff = SpawnPrefab("small_puff")
                if puff then
                    puff.Transform:SetPosition(inst.Transform:GetWorldPosition())
                end
            elseif operation == "cook_fire" then
                -- 烤食物的情况
                if food_name == "mandrake" then
                    inst.components.hunger:DoDelta(250)
                    inst.components.sanity:DoDelta(200)
                    inst.components.health:DoDelta(150)
                else
                    -- 其他正常食物，沃利默认回复
                    inst.components.hunger:DoDelta(25)
                    inst.components.sanity:DoDelta(25)
                    inst.components.health:DoDelta(15)
                end
                -- 播放小气泡
                local puff = SpawnPrefab("small_puff")
                if puff then
                    puff.Transform:SetPosition(inst.Transform:GetWorldPosition())
                end
            elseif operation == "harvest_pot" then
                -- 收获锅里食物的情况
                if food_name == "mandrakesoup" then
                    inst.components.hunger:DoDelta(250)
                    inst.components.sanity:DoDelta(200)
                    inst.components.health:DoDelta(150)
                elseif food_name == "monstertartare" then
                    inst.components.hunger:DoDelta(15)
                    inst.components.sanity:DoDelta(15)
                    inst.components.health:DoDelta(10)
                else
                    -- 其他正常食物，沃利默认回复
                    inst.components.hunger:DoDelta(25)
                    inst.components.sanity:DoDelta(25)
                    inst.components.health:DoDelta(15)
                end
                -- 播放小气泡
                local puff = SpawnPrefab("small_puff")
                if puff then
                    puff.Transform:SetPosition(inst.Transform:GetWorldPosition())
                end
            end
        end
    end)
end)

--========================================================
-- 胡乱烹饪（潮湿黏糊，粉末蛋糕，怪物千层饼，怪物鞑靼，曼德拉草汤）
--========================================================
local bad_foods = {
    wetgoop = true,
    powdercake = true,
    monsterlasagna = true,
    monstertartare = true,
    mandrakesoup = true,
}

AddComponentPostInit("stewer", function(stewer)
    -- 保存原来的 Harvest
    local old_Harvest = stewer.Harvest

    -- 覆盖 Harvest
    stewer.Harvest = function(self, harvester)
        -- 先记录product
        local product = self.product
        -- 调用原来的 Harvest
        local result = nil
        if old_Harvest then
            result = old_Harvest(self, harvester)
        end

        if harvester and harvester.prefab == "warly" and product ~= nil and bad_foods[product] then
            -- 触发事件
            harvester:PushEvent("funny_play_warly", {
                doer = harvester,
                item = product,
                operation = "harvest_pot"
            })
        else
            print("[HOOK] Conditions not met for funny_play_warly")
        end
        return result
    end
end)

--========================================================
-- 胡乱烤（曼德拉草 夜莓 孵化中的高脚鸟蛋 龙虾）
--========================================================
local huanluo_foods = {
    mandrake = true,
    ancientfruit_nightvision = true,
    tallbirdegg = true, --苏格兰高鸟蛋不能用熟鸟蛋
    tallbirdegg_cracked = true,
    wobster_sheller_land = true,
    corn = true, --纯亏
    red_cap = true, --纯亏
    moon_cap = true, --纯亏
    -- 作物种子？
}

AddComponentPostInit("cookable", function(cookable)
    local old_Cook = cookable.Cook

    cookable.Cook = function(self, cooker, chef)
        local food_name = self.inst and self.inst.prefab or nil
        -- print("[HOOK] Cook called for:", cooker.prefab, "chef prefab:", chef and chef.prefab, "food_name:", food_name)

        -- 调用原来的 Cook
        local product = nil
        if old_Cook then
            product = old_Cook(self, cooker, chef)
            -- print("[HOOK] Original Cook returned:", product and product.prefab)
        end

        -- 只要烤出的食物在胡乱烤列表
        if food_name and huanluo_foods[food_name] then
            -- 遍历所有玩家，找到附近的沃利
            for _, player in ipairs(AllPlayers) do
                if player.prefab == "warly" then
                    local px, py, pz = player.Transform:GetWorldPosition()
                    local cx, cy, cz = chef.Transform:GetWorldPosition()
                    local dist_sq = (px - cx) ^ 2 + (py - cy) ^ 2 + (pz - cz) ^ 2
                    local max_distance = 10 -- 可以根据需要调整触发范围
                    if dist_sq <= max_distance * max_distance then
                        -- print("[HOOK] Nearby Warly found:", player, "triggering event for food:", food_name)
                        player:PushEvent("funny_play_warly", {
                            doer = chef,
                            item = food_name,
                            operation = "cook_fire"
                        })
                    else
                        -- print("[HOOK] Warly too far:", player)
                    end
                end
            end
        else
            -- print("[HOOK] Food not in huanluo_foods list or nil")
        end

        return product
    end
end)

--========================================================
-- 胡乱吃（黄油 眼球 守护者之角 蜂王浆 曼德拉草 高脚鸟蛋 泻根糖浆 格罗姆的黏液 海带补丁 象鼻、冬象鼻 蝙蝠翅膀）
--========================================================
_G.valuable_foods = {
    -- 原材料类
    butter = true,
    deerclops_eyeball = true,
    minotaurhorn = true,
    royal_jelly = true,
    mandrake = true,
    tallbirdegg = true,
    tallbirdegg_cracked = true,
    ipecacsyrup = true,
    glommerfuel = true,
    boatpatch_kelp = true,
    trunk_summer = true,
    trunk_winter = true,
    batwing = true,
    moonglass_charged = true,
    moonglass = true,
    ancientfruit_nightvision = true, -- 古老果实夜视
    -- 料理类
    freshfruitcrepes = true,
    voltgoatjelly = true,
}

AddComponentPostInit("edible", function(edible)
    local old_OnEaten = edible.OnEaten

    edible.OnEaten = function(self, eater)
        -- print("[HOOK] OnEaten called for:", self.inst.prefab)

        -- 调用原来的 OnEaten
        if old_OnEaten then
            old_OnEaten(self, eater)
        end

        local food_name = self.inst.prefab
        -- print("[HOOK] Food eaten:", food_name)

        -- 如果食物在关心的列表中
        if valuable_foods[food_name] then
            -- 将所有的食物食用事件都推送
            for _, player in ipairs(AllPlayers) do
                if player.prefab == "warly" then
                    local px, py, pz = player.Transform:GetWorldPosition()
                    local ex, ey, ez = eater.Transform:GetWorldPosition()
                    local dist_sq = (px - ex) ^ 2 + (py - ey) ^ 2 + (pz - ez) ^ 2
                    local max_distance = 10 -- 可以根据需要调整触发范围
                    if dist_sq <= max_distance * max_distance then
                        -- print("[HOOK] Nearby Warly found:", player, "triggering event for food:", food_name)
                        player:PushEvent("funny_play_warly", {
                            doer = eater,     -- 吃食物的人
                            item = food_name, -- 被吃掉的食物名称
                            operation = "eat" -- 操作类型，标记为“eat”
                        })
                    else
                        -- print("[HOOK] Warly too far:", player)
                    end
                end
            end
        else
            -- print("[HOOK] Food not in valuable_foods list or nil")
        end
    end
end)
