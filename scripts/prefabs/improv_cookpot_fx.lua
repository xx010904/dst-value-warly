require "prefabutil"

local cooking = require("cooking")
local spicedfoods = require("spicedfoods")

local foods = {}
for cooker, recipes in pairs(cooking.recipes) do
    for product, _ in pairs(recipes) do
        foods[product] = true
    end
end

local food_list = {}
for k in pairs(foods) do
    table.insert(food_list, k)
end

-- 获取基础食物名（去掉调味前缀）
local function GetBaseFood(prefab)
    return spicedfoods[prefab] ~= nil and spicedfoods[prefab].basename or prefab
end

-- 🥔 获取所有食谱产物（包含MOD食谱）
local function GetAllCookableFoods()
    local foods = {}
    for cooker, recipes in pairs(cooking.recipes) do
        if type(recipes) == "table" then
            for product, _ in pairs(recipes) do
                if product ~= nil and product ~= "" then
                    foods[product] = true
                end
            end
        end
    end
    return foods
end

-- 🍲 根据厨师记忆筛选未吃过的食物（无doer则随机全食谱）
local function GetUnmemorizedFoods(doer)
    local allfoods = GetAllCookableFoods()
    local valid = {}

    -- ⚠️ 如果 doer 为空或没有 foodmemory 组件，直接返回全部食物
    if doer == nil or not (doer.components and doer.components.foodmemory) then
        for prefab in pairs(allfoods) do
            table.insert(valid, prefab)
        end
        return valid
    end

    local memory = doer.components.foodmemory

    for prefab in pairs(allfoods) do
        local base = spicedfoods[prefab] ~= nil and spicedfoods[prefab].basename or prefab
        local count = memory:GetMemoryCount(base) or 0
        if count <= 0 then
            table.insert(valid, prefab)
        end
    end

    -- 防止全吃过，空表时退回全表
    if #valid == 0 then
        for prefab in pairs(allfoods) do
            table.insert(valid, prefab)
        end
    end

    return valid
end

local function SetProductSymbol(inst, product, overridebuild)
    local recipe = cooking.GetRecipe("portablecookpot", product)
    local potlevel = recipe ~= nil and recipe.potlevel or nil
    local build = (recipe ~= nil and recipe.overridebuild) or overridebuild or "cook_pot_food"
    local overridesymbol = (recipe ~= nil and recipe.overridesymbolname) or product

    -- print("本次食物：recipe:", recipe, ",potlevel:", potlevel, ",build:", build, ",overridesymbol:", overridesymbol)

    if potlevel == "high" then
        inst.AnimState:Show("swap_high")
        inst.AnimState:Hide("swap_mid")
        inst.AnimState:Hide("swap_low")
    elseif potlevel == "low" then
        inst.AnimState:Hide("swap_high")
        inst.AnimState:Hide("swap_mid")
        inst.AnimState:Show("swap_low")
    else
        inst.AnimState:Hide("swap_high")
        inst.AnimState:Show("swap_mid")
        inst.AnimState:Hide("swap_low")
    end

    inst.AnimState:OverrideSymbol("swap_cooked", build, overridesymbol)
end

-- 🧩 即兴锅 prefab
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("portable_cook_pot")
    inst.AnimState:SetBuild("portable_cook_pot")
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:SetFinalOffset(2)
    inst.AnimState:SetMultColour(1, 1, 1, 0.9)

    inst:AddTag("FX")
    inst:AddTag("improv_cookpot_fx")
    inst.persists = false

    if not TheWorld.ismastersim then
        inst:DoTaskInTime(1, function()
            local label = inst.entity:AddLabel()
            label:SetFont(TALKINGFONT)
            label:SetFontSize(21)
            label:SetWorldOffset(0, 2.2, 0)
            label:SetColour(204 / 255, 99 / 255, 78 / 255)
            local lines = STRINGS.MEAL_WORTH_ACTIONS
            local text = lines[math.random(#lines)]
            label:SetText(text)
            label:Enable(true)
        end)
        return inst
    end

    inst.doer = nil

    inst:ListenForEvent("animover", function()
        if inst.AnimState:IsCurrentAnimation("place") then
            --------------------------------------------------
            -- 🍳 开始煮饭阶段
            --------------------------------------------------
            -- local cook_time = math.random(10, 15)
            local cook_time = 4.4
            inst.AnimState:PlayAnimation("hit_cooking", true)
            inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "cookloop")

            inst:DoTaskInTime(cook_time, function()
                inst.SoundEmitter:KillSound("cookloop")

                --------------------------------------------------
                -- 🍲 煮好 → hit_full 显示食物
                --------------------------------------------------
                local unmemorized = GetUnmemorizedFoods(inst.doer)
                local product = unmemorized[math.random(#unmemorized)]
                local diaplay_product = GetBaseFood(product)

                inst.AnimState:PlayAnimation("hit_full", true)
                SetProductSymbol(inst, diaplay_product) -- ✅ 展示食物

                --------------------------------------------------
                -- ⏳ 展示1秒后 → 弹出食物 & 播放 hit_empty
                --------------------------------------------------
                inst:DoTaskInTime(1, function()
                    inst.AnimState:PlayAnimation("hit_empty", false)

                    -- 🎁 扔出食物实体
                    local loot = SpawnPrefab(math.random() > 0.9 and product or diaplay_product) -- 大概率是未调味的原料理
                    if loot then
                        local x, y, z = inst.Transform:GetWorldPosition()
                        loot.Transform:SetPosition(x, y + 1, z)
                        if loot.Physics then
                            local angle = math.random() * 2 * PI
                            local speed = 1 + math.random()
                            loot.Physics:SetVel(speed * math.cos(angle), 5, speed * math.sin(angle))
                        end
                    end

                    --------------------------------------------------
                    -- 💨 锅塌陷动画
                    --------------------------------------------------
                    inst:ListenForEvent("animover", function()
                        if inst.AnimState:IsCurrentAnimation("hit_empty") then
                            inst.AnimState:PlayAnimation("collapse", false)
                            inst:ListenForEvent("animover", function()
                                if inst.AnimState:IsCurrentAnimation("collapse") then
                                    SpawnPrefab("lucy_ground_transform_fx").Transform:SetPosition(inst.Transform
                                        :GetWorldPosition())
                                    inst:Remove()
                                end
                            end)
                        end
                    end)
                end)
            end)
        end
    end)

    return inst
end

return Prefab("improv_cookpot_fx", fn)
