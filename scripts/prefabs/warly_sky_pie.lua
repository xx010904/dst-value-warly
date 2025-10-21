local cooking = require("cooking")

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
            local newPie = SpawnPrefab(inst.prefab)
            newPie.Transform:SetPosition(eater.Transform:GetWorldPosition())
            LaunchAt(newPie, eater, eater, nil, nil, eater:GetPhysicsRadius(0) + .25)
        else
            if eater.components.talker then
                eater.components.talker:Say(GetString(eater, "ANNOUNCE_EAT_PIE"))
            end
            eater:AddDebuff("warly_sky_pie_inspire_buff", "warly_sky_pie_inspire_buff")
        end
        return true
    end
end

-- 返回所有以 best_food 为基础的调味版 prefab 名（使用 allCookableFoods 作为来源）
local function FindSpicedVariants(best_food, allCookableFoods)
    local variants = {}
    if not best_food or best_food == "" then
        return variants
    end
    -- 遍历所有可烹饪产物（包含 MOD）寻找匹配
    for prefabname, _ in pairs(allCookableFoods or {}) do
        if type(prefabname) == "string" and prefabname ~= "" then
            -- 常见命名样式：
            -- <base>_spice_<x>
            -- <base>_spiced_<x>
            -- <base>_spice<x> （兼容更宽松的格式）
            -- 以及某些 MOD 可能会把 spice 放在后缀位置，或用中划线等
            -- 我们使用若干简单的前缀检查 + 模式匹配来提高兼容性
            if prefabname:sub(1, #best_food + 7) == best_food .. "_spice_" then
                table.insert(variants, prefabname)
            elseif prefabname:sub(1, #best_food + 8) == best_food .. "_spiced_" then
                table.insert(variants, prefabname)
            else
                -- 更宽松的匹配：包含 "<base>_spice" 或 "<base>-spice" 等
                if prefabname:find("^" .. best_food .. ".*[_%-]spice") or prefabname:find("^" .. best_food .. ".*[_%-]spiced") then
                    table.insert(variants, prefabname)
                end
            end
        end
    end
    return variants
end

-- 🥔 获取所有食谱产物（包含MOD食谱）
local function GetAllCookableFoods()
    local allCookableFoods = {}
    for cooker, recipes in pairs(cooking.recipes) do
        if type(recipes) == "table" then
            for product, _ in pairs(recipes) do
                if product ~= nil and product ~= "" then
                    allCookableFoods[product] = true
                end
            end
        end
    end
    return allCookableFoods
end

-- 从所有调味变体中随机返回一个，如果没有则返回原始 best_food
local function GetRandomSpicedFoodFromAll(best_food)
    local allFoods = GetAllCookableFoods() -- 你已有的函数，返回 map 类型
    local variants = FindSpicedVariants(best_food, allFoods)

    if #variants > 0 then
        return variants[math.random(#variants)]
    end

    -- 兜底：没有调味版，返回原食物
    return best_food
end


local function MakeSpicedFood(inst, cooker, chef)
    local prefab_to_spawn = "ash"

    local hasBakedSkill = chef and chef.components.skilltreeupdater and
        chef.components.skilltreeupdater:IsActivated("warly_sky_pie_baked")
    local hasFavoriteSkill = chef and chef.components.skilltreeupdater and
        chef.components.skilltreeupdater:IsActivated("warly_sky_pie_favorite")
    if hasBakedSkill then -- 技能树控制，可以烤饼而不是烤灰
        -- 就生成烤饼
        prefab_to_spawn = "warly_sky_pie_baked"
        -- 可以烤出梦想料理
        if hasFavoriteSkill then
            -- 初始化累积概率
            chef.warly_skypie_accum_chance = chef.warly_skypie_accum_chance or 0

            -- 累积随机值 0.01 ~ 0.09
            local increment = math.random() * 0.08 + 0.01
            chef.warly_skypie_accum_chance = chef.warly_skypie_accum_chance + increment

            -- 累积触发
            if chef.warly_skypie_accum_chance >= 1 then
                chef.warly_skypie_accum_chance = chef.warly_skypie_accum_chance - 1
                local x, y, z = inst.Transform:GetWorldPosition()

                local targets = {}  -- 最终参与随机的对象列表
                local nearby = TheSim:FindEntities(x, y, z, 12)  -- 找附近12格的所有实体

                for _, ent in ipairs(nearby) do
                    if ent:HasTag("player") and not ent:HasTag("playerghost") then
                        table.insert(targets, ent)
                    elseif ent.prefab == "hermitcrab" then
                        table.insert(targets, ent)
                    end
                end

                if #targets > 0 then
                    local target = targets[math.random(#targets)]

                    -- ping个问号❓
                    local chefMark = SpawnPrefab("improv_question_mark_fx")
                    chefMark.entity:SetParent(chef.entity)
                    chefMark.Transform:SetPosition(0, 3, 0)
                    local idiotMark = SpawnPrefab("improv_question_mark_fx")
                    idiotMark.entity:SetParent(target.entity)
                    idiotMark.Transform:SetPosition(0, 3, 0)

                    if target == chef then -- 技能树控制（沃利是飞饼）
                        prefab_to_spawn = "warly_sky_pie_boomerang"
                    elseif target.prefab == "hermitcrab" then -- 寄居蟹
                        prefab_to_spawn = "flowersalad"
                    else
                        local affinity = target.components.foodaffinity
                        if affinity ~= nil and affinity.prefab_affinities ~= nil then
                            local best_food = nil
                            local best_mult = 0

                            -- 找到倍率最高的食物
                            for prefab, mult in pairs(affinity.prefab_affinities) do
                                if mult > best_mult then
                                    best_food = prefab
                                    best_mult = mult
                                end
                            end

                            -- 如果有最喜欢的食物 → 生成那道菜
                            if best_food ~= nil then
                                prefab_to_spawn = GetRandomSpicedFoodFromAll(best_food)
                            end
                        end
                    end
                end
            end
        end
    end

    -- 非沃利厨师失败
    return prefab_to_spawn
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
        return MakeSpicedFood(inst, cooker, chef)
    end

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("warly_sky_pie", fn, {})
