-- 下饭操作 Meal-worthy Play
-- “沃利看到别人做出垃圾料理时，被激发厨师灵魂，做出下饭菜”，恢复精神与饥饿。
-- 1 胡乱烹饪（潮湿黏糊，粉末蛋糕，怪物千层饼，怪物鞑靼，曼德拉草汤）：+33饥饿 +33精神
--   胡乱烤（曼德拉草 夜莓 高脚鸟蛋 龙虾）
-- 2 血压飙升 下饭操作都再+30血
-- 3 不能容忍珍贵食材或别有用途的食物被吃掉： 眼球 守护者之角 蜂王浆 曼德拉草 高脚鸟蛋 泻根糖浆 格罗姆的黏液 海带补丁 象鼻、冬象鼻 
-- 4 当场烹饪下饭菜：如果携带着便携锅，就地自动烹饪一份下饭菜；下饭菜还可以回锅，+150饥饿+150精神


--========================================================
-- 沃利监听下饭操作事件
--========================================================
AddPlayerPostInit(function(inst)
    inst:ListenForEvent("funny_play_warly", function(inst, data)
        if inst.prefab == "warly" then
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
                    elseif food_name == "ancientfruit_nightvision" then
                        -- 不做任何回复
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
                        inst.components.hunger:DoDelta(10)   -- 少量饥饿
                        inst.components.sanity:DoDelta(10)   -- 少量精神
                        inst.components.health:DoDelta(5)   -- 少量回血
                    elseif food_name == "ancientfruit_nightvision" then
                        -- 玩家吃古老果实夜视，沃利不回复
                        print("[HOOK] Player eats ancientfruit_nightvision, no recovery.")
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
                    if food_name == "deerclops_eyeball" or food_name == "minotaurhorn" or food_name == "mandrake" then
                        -- 这类食物无论是谁吃，沃利巨量回复
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
-- 胡乱烤（曼德拉草 夜莓 高脚鸟蛋 龙虾）
--========================================================
local huanluo_foods = {
    mandrake = true,
    ancientfruit_nightvision = true,
    tallbirdegg = true,
    tallbirdegg_cracked = true,
    wobster_sheller_land = true,
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
                    local dist_sq = (px - cx)^2 + (py - cy)^2 + (pz - cz)^2
                    local max_distance = 10 -- 可以根据需要调整触发范围
                    if dist_sq <= max_distance*max_distance then
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
-- 胡乱吃（眼球 守护者之角 蜂王浆 曼德拉草 高脚鸟蛋 泻根糖浆 格罗姆的黏液 海带补丁 象鼻、冬象鼻 蝙蝠翅膀）
--========================================================
local valuable_foods = {
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
    ancientfruit_nightvision = true,  -- 古老果实夜视
}

AddComponentPostInit("edible", function(edible)
    local old_OnEaten = edible.OnEaten

    edible.OnEaten = function(self, eater)
        print("[HOOK] OnEaten called for:", self.inst.prefab)

        -- 调用原来的 OnEaten
        if old_OnEaten then
            old_OnEaten(self, eater)
        end

        local food_name = self.inst.prefab
        print("[HOOK] Food eaten:", food_name)

        -- 如果食物在关心的列表中
        if valuable_foods[food_name] then
            -- 将所有的食物食用事件都推送
            for _, player in ipairs(AllPlayers) do
                if player.prefab == "warly" then
                    local px, py, pz = player.Transform:GetWorldPosition()
                    local ex, ey, ez = eater.Transform:GetWorldPosition()
                    local dist_sq = (px - ex)^2 + (py - ey)^2 + (pz - ez)^2
                    local max_distance = 10  -- 可以根据需要调整触发范围
                    if dist_sq <= max_distance * max_distance then
                        print("[HOOK] Nearby Warly found:", player, "triggering event for food:", food_name)
                        player:PushEvent("funny_play_warly", {
                            doer = eater,        -- 吃食物的人
                            item = food_name,     -- 被吃掉的食物名称
                            operation = "eat"     -- 操作类型，标记为“eat”
                        })
                    else
                        print("[HOOK] Warly too far:", player)
                    end
                end
            end
        else
            print("[HOOK] Food not in valuable_foods list or nil")
        end
    end
end)

