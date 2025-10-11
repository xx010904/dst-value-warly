-- 厨艺
-- 拥有精湛厨艺的厨师并不依赖炊具，甚至不依赖食材，随时随地即兴发挥做出一桌好菜
-- Section 1：下饭操作 Meal-worthy Play
-- 1 “沃利看到别人做出垃圾料理时，被激发厨师灵魂，做出下饭菜”，展示厨艺，当场跟陪一份下饭菜：就地自动烹饪一份随机下饭菜
--   胡乱烹饪：潮湿黏糊，粉末蛋糕，怪物千层饼，怪物鞑靼，曼德拉草汤
--   胡乱烤：曼德拉草 夜莓 高脚鸟蛋 孵化中的高脚鸟蛋 龙虾 红蘑菇 月亮蘑菇 象鼻、冬象鼻
--   胡乱吃（通用）：独眼巨鹿眼球 守护者之角 蜂王浆 曼德拉草 高脚鸟蛋 孵化中的高脚鸟蛋 格罗姆的黏液 海带补丁 象鼻、冬象鼻
--   胡乱吃（玩家）：泻根糖浆
--   胡乱吃（动物）：伏特羊肉冻 彩虹糖豆 鲜果可丽饼 龙虾正餐 华夫饼 黄油 夜莓
-- 2 随机下饭菜概率含调味料
-- 3 直接回饥饿精神和血量（避免食物记忆）+ 3.1 排除记忆的料理
-- 4 队友死了烹饪四菜一汤 （开席） + 4.1 复活队友

-- Section 2 半成品预制菜
-- 1 料理包准备，把4个食材打包起来，就像烹饪锅一样，打包食材就是一个东西，不堆叠
--    打包好的料理包，可以直接放在火堆上面加热（控制火候的人不会失败），烧烤一次掉1/40耐久，生成1个料理
-- 2 料理包可以包含调味料
-- 3 流水线生产可以让打包可以额外产出一些，总使用次数大于40
-- 4 快速送达，会飞的猪


-- =========================================================
-- SECTION1 胡乱料理全表（含恢复与抛锅概率）
-- =========================================================
local spicedfoods = require("spicedfoods")

local FOOD_RECOVERY_TABLE = {

    -- 胡乱烹饪（锅收获触发）
    harvest_pot = {
        wetgoop        = { hunger = 15, sanity = 15, health = 15, throw_chance = 0.7 },
        powdercake     = { hunger = 10, sanity = 10, health = 10, throw_chance = 0.7 },
        monsterlasagna = { hunger = 30, sanity = 20, health = 15, throw_chance = 1.0 },
        monstertartare = { hunger = 25, sanity = 15, health = 10, throw_chance = 0.8 },
        mandrakesoup   = { hunger = 60, sanity = 60, health = 60, throw_chance = 1.0 },
    },

    -- 胡乱烤（火堆）
    cook_fire = {
        mandrake                 = { hunger = 150, sanity = 150, health = 150, throw_chance = 1.0 },
        ancientfruit_nightvision = { hunger = 20, sanity = 25, health = 10, throw_chance = 1.0 },
        tallbirdegg              = { hunger = 25, sanity = 10, health = 20, throw_chance = 1.0 },
        tallbirdegg_cracked      = { hunger = 20, sanity = 10, health = 20, throw_chance = 1.0 },
        red_cap                  = { hunger = 5, sanity = 5, health = 5, throw_chance = 0.2 },
        moon_cap                 = { hunger = 5, sanity = 5, health = 5, throw_chance = 0.2 },
        trunk_summer             = { hunger = 5, sanity = 5, health = 5, throw_chance = 0.8 },
        trunk_winter             = { hunger = 10, sanity = 10, health = 10, throw_chance = 1.0 },
        wobster_sheller_land     = { hunger = 75, sanity = 50, health = 20, throw_chance = 1.0 },
        oceanfish_small_8_inv    = { hunger = 75, sanity = 50, health = 20, throw_chance = 1.0 },
        oceanfish_small_7_inv    = { hunger = 75, sanity = 50, health = 20, throw_chance = 1.0 },
        oceanfish_small_6_inv    = { hunger = 75, sanity = 50, health = 20, throw_chance = 1.0 },
        oceanfish_medium_8_inv   = { hunger = 75, sanity = 50, health = 20, throw_chance = 1.0 },
        mole                     = { hunger = 15, sanity = 10, health = 10, throw_chance = 1.0 },
    },

    -- 胡乱吃（通用）
    eat_common = {
        deerclops_eyeball   = { hunger = 150, sanity = 150, health = 150, throw_chance = 1.0 },
        minotaurhorn        = { hunger = 150, sanity = 150, health = 150, throw_chance = 1.0 },
        royal_jelly         = { hunger = 20, sanity = 20, health = 15, throw_chance = 0.8 },
        mandrake            = { hunger = 150, sanity = 150, health = 150, throw_chance = 1.0 },
        tallbirdegg         = { hunger = 15, sanity = 15, health = 15, throw_chance = 0.7 },
        tallbirdegg_cracked = { hunger = 20, sanity = 25, health = 15, throw_chance = 0.9 },
        glommerfuel         = { hunger = 10, sanity = 15, health = 5, throw_chance = 0.7 },
        boatpatch_kelp      = { hunger = 5, sanity = 10, health = 5, throw_chance = 0.4 },
        trunk_summer        = { hunger = 20, sanity = 10, health = 10, throw_chance = 0.8 },
        trunk_winter        = { hunger = 25, sanity = 10, health = 15, throw_chance = 1.0 },
    },

    -- 胡乱吃（玩家）
    eat_player = {
        ipecacsyrup = { hunger = 15, sanity = 75, health = 10, throw_chance = 1.0 },
    },

    -- 胡乱吃（动物）
    eat_animal = {
        voltgoatjelly            = { hunger = 75, sanity = 75, health = 15, throw_chance = 1.0 },
        jellybean                = { hunger = 15, sanity = 15, health = 25, throw_chance = 0.4 },
        freshfruitcrepes         = { hunger = 75, sanity = 10, health = 15, throw_chance = 1.0 },
        lobsterdinner            = { hunger = 75, sanity = 15, health = 15, throw_chance = 1.0 },
        waffles                  = { hunger = 75, sanity = 10, health = 15, throw_chance = 1.0 },
        butter                   = { hunger = 75, sanity = 25, health = 20, throw_chance = 1.0 },
        ancientfruit_nightvision = { hunger = 10, sanity = 50, health = 10, throw_chance = 1.0 },
    },
}

-- 获取基础食物名（去掉调味前缀）
local function GetBaseFood(prefab)
    return spicedfoods[prefab] ~= nil and spicedfoods[prefab].basename or prefab
end

-- =========================================================
-- 抛锅函数
-- =========================================================
local function SpawnCookPotFX(doer)
    if not doer then return end

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
    if not found then spawn_x, spawn_y, spawn_z = x, 0, z end

    local fx = SpawnPrefab("lucy_transform_fx")
    fx.entity:SetParent(doer.entity)
    fx.entity:AddFollower()
    fx.Follower:FollowSymbol(doer.GUID, "hair", 0, 0, 0)

    local proj = SpawnPrefab("improv_cookpot_projectile_fx")
    proj.Transform:SetPosition(x, y, z)
    proj.components.complexprojectile:Launch(Vector3(spawn_x, spawn_y, spawn_z), doer)
end

local function ApplyTalking(inst, op)
    if op == "eat_common" then
        inst.components.talker:Say(GetString(inst, "ANNOUNCE_BAD_EAT_COMMOM"))
    elseif op == "eat_player" then
        inst.components.talker:Say(GetString(inst, "ANNOUNCE_BAD_EAT_BY_PLAYER"))
    elseif op == "eat_animal" then
        inst.components.talker:Say(GetString(inst, "ANNOUNCE_BAD_EAT_BY_ANIMAL"))
    elseif op == "cook_fire" then
        inst.components.talker:Say(GetString(inst, "ANNOUNCE_BAD_COOKS_FOOD"))
    elseif op == "harvest_pot" then
        inst.components.talker:Say(GetString(inst, "ANNOUNCE_BAD_HARVESTS_POT"))
    end
end

-- =========================================================
-- 恢复处理函数
-- =========================================================
local function ApplyRecovery(inst, doer, food_name, operation)
    if not inst or not inst.components or not food_name or not operation then return end

    local rec_table = FOOD_RECOVERY_TABLE[operation]
    if not rec_table or not rec_table[food_name] then return end

    local values = rec_table[food_name]

    -- 随机浮动回复
    local hunger_base = values.hunger or 0
    local sanity_base = values.sanity or 0
    local health_base = values.health or 0

    local hunger_variation = hunger_base * 0.2
    local sanity_variation = sanity_base * 0.2
    local health_variation = health_base * 0.2

    local hunger_delta = hunger_base + (math.random() * 2 - 1) * hunger_variation
    local sanity_delta = sanity_base + (math.random() * 2 - 1) * sanity_variation
    local health_delta = health_base + (math.random() * 2 - 1) * health_variation

    inst.components.hunger:DoDelta(hunger_delta)
    inst.components.sanity:DoDelta(sanity_delta)
    inst.components.health:DoDelta(health_delta)
end

-- =========================================================
-- 沃利执行动作
-- =========================================================
local function doFunnyCook(inst, doer, food_name, op)
    if inst.prefab ~= "warly" then return end --技能树控制

    local rec_table = FOOD_RECOVERY_TABLE[op]
    local values = rec_table and rec_table[food_name]
    if not values then return end

    -- 抛锅特效概率控制
    local chance = values.throw_chance or 1
    if math.random() < chance then
        SpawnCookPotFX(inst)
    end

    -- 说话逻辑
    ApplyTalking(inst, op)

    -- 恢复逻辑
    ApplyRecovery(inst, doer, food_name, op) --技能树控制

    -- puff 特效
    local puff = SpawnPrefab("small_puff")
    if puff then
        local x, y, z = inst.Transform:GetWorldPosition()
        puff.Transform:SetPosition(x, y, z)
    end
end

-- =========================================================
-- 胡乱烹饪（锅收获触发）
-- =========================================================
AddComponentPostInit("stewer", function(stewer)
    local old_Harvest = stewer.Harvest
    stewer.Harvest = function(self, harvester)
        local product = self.product
        local result = old_Harvest and old_Harvest(self, harvester)
        if product and FOOD_RECOVERY_TABLE.harvest_pot[product] then
            for _, player in ipairs(AllPlayers) do
                if player.prefab == "warly" and harvester and player:IsNear(harvester, 12) then
                    doFunnyCook(player, harvester, product, "harvest_pot")
                end
            end
        end
        return result
    end
end)

-- =========================================================
-- 胡乱烤监听
-- =========================================================
AddComponentPostInit("cookable", function(cookable)
    local old_Cook = cookable.Cook
    cookable.Cook = function(self, cooker, chef)
        local food_name = self.inst and self.inst.prefab or nil
        local product = old_Cook and old_Cook(self, cooker, chef)
        if food_name and FOOD_RECOVERY_TABLE.cook_fire[food_name] then
            for _, player in ipairs(AllPlayers) do
                if player.prefab == "warly" and chef and player:IsNear(chef, 12) then
                    doFunnyCook(player, chef, food_name, "cook_fire")
                end
            end
        end
        return product
    end
end)

-- =========================================================
-- 胡乱吃监听
-- =========================================================
AddComponentPostInit("edible", function(edible)
    local old_OnEaten = edible.OnEaten
    edible.OnEaten = function(self, eater)
        if old_OnEaten then old_OnEaten(self, eater) end

        local food_name = self.inst.prefab
        food_name = GetBaseFood(food_name)
        for _, player in ipairs(AllPlayers) do
            if player.prefab == "warly" and eater and player:IsNear(eater, 12) then
                local operation = nil

                if FOOD_RECOVERY_TABLE.eat_common[food_name] then
                    operation = "eat_common"
                elseif eater:HasTag("player") and FOOD_RECOVERY_TABLE.eat_player[food_name] then
                    operation = "eat_player"
                elseif not eater:HasTag("player") and FOOD_RECOVERY_TABLE.eat_animal[food_name] then
                    operation = "eat_animal"
                end

                if operation then
                    doFunnyCook(player, eater, food_name, operation)
                end
            end
        end
    end
end)


-- =========================================================
-- SECTION2 打包预制菜
-- =========================================================
local containers = require("containers")
local params = containers.params
local cooking = require("cooking")
-- =========================================================
-- 🍱 四格打包袋 prepack_foodbag_4
-- =========================================================
params.prepack_foodbag_4 = {
    widget =
    {
        slotpos =
        {
            Vector3(0, 64 + 32 + 8 + 4, 0),
            Vector3(0, 32 + 4, 0),
            Vector3(0, -(32 + 4), 0),
            Vector3(0, -(64 + 32 + 8 + 4), 0),
        },
        slotbg =
        {
            { image = "cook_slot_food.tex" },
            { image = "cook_slot_food.tex" },
            { image = "cook_slot_food.tex" },
            { image = "cook_slot_food.tex" },
        },
        animbank = "ui_cookpot_1x4",
        animbuild = "ui_cookpot_1x4",
        pos = Vector3(200, 0, 0),
        side_align_tip = 100,
        buttoninfo =
        {
            text = STRINGS.ACTIONS.COOK,
            position = Vector3(0, -165, 0),
        }
    },
    -- acceptsstacks = false,
    type = "cooker",
}

function params.prepack_foodbag_4.itemtestfn(container, item, slot)
    return cooking.IsCookingIngredient(item.prefab) and not container.inst:HasTag("burnt")
end

-- 按钮逻辑：打包触发烹饪
function params.prepack_foodbag_4.widget.buttoninfo.fn(inst, doer)
    if inst.components.container ~= nil then
        -- 服务器端执行打包逻辑
        if inst.components.packagingstation ~= nil then
            inst.components.packagingstation:StartPackaging(doer)
        end
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.COOK.code, inst, ACTIONS.COOK.mod_name)
    end
end

-- 按钮显示条件：容器满时才显示
function params.prepack_foodbag_4.widget.buttoninfo.validfn(inst)
    return inst.replica.container ~= nil and inst.replica.container:IsFull()
end

-- =========================================================
-- 🍱 五格打包袋 prepack_foodbag_5（第五格为调味料）
-- =========================================================
params.prepack_foodbag_5 = {
    widget =
    {
        slotpos =
        {
            -- 四格竖排 + 一格调味料偏右放
            Vector3(0, 64 + 32 + 8 + 4, 0),
            Vector3(0, 32 + 4, 0),
            Vector3(0, -(32 + 4), 0),
            Vector3(0, -(64 + 32 + 8 + 4), 0),
            Vector3(64, -(64 + 32 + 8 + 4), 0), -- 调味料格
        },
        slotbg =
        {
            { image = "cook_slot_food.tex" },
            { image = "cook_slot_food.tex" },
            { image = "cook_slot_food.tex" },
            { image = "cook_slot_food.tex" },
            { image = "cook_slot_spice.tex" },
        },
        animbank = "ui_cookpot_1x4",
        animbuild = "ui_cookpot_1x4",
        pos = Vector3(200, 0, 0),
        side_align_tip = 100,
        buttoninfo =
        {
            text = STRINGS.ACTIONS.COOK,
            position = Vector3(0, -165, 0),
        },
    },
    -- acceptsstacks = false,
    type = "cooker",
}

function params.prepack_foodbag_5.itemtestfn(container, item, slot)
    return item
        and not container.inst:HasTag("burnt")
        and (
            (slot ~= nil and slot < 5 and cooking.IsCookingIngredient(item.prefab))
            or (slot == 5 and (((item.prefab or ""):find("^spice_") ~= nil) or item:HasTag("spice")))
            or (slot == nil and (cooking.IsCookingIngredient(item.prefab) or ((item.prefab or ""):find("^spice_") ~= nil) or item:HasTag("spice")))
        )
end

-- 按钮逻辑：打包触发烹饪
function params.prepack_foodbag_5.widget.buttoninfo.fn(inst, doer)
    if inst.components.container ~= nil then
        BufferedAction(doer, inst, ACTIONS.COOK):Do()
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst, nil)
    end
end

-- 按钮显示条件：容器满时才显示
function params.prepack_foodbag_5.widget.buttoninfo.validfn(inst)
    return inst.replica.container ~= nil and inst.replica.container:IsFull()
end

-- 更新最大格子数量
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, 5)
