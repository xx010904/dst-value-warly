-- 厨艺（解决获取料理调料难）
-- 拥有精湛厨艺的厨师并不依赖炊具，甚至不依赖食材，随时随地即兴发挥做出一桌好菜
-- Section 1：下饭操作 Meal-worthy Play
-- 1 “沃利看到别人做出垃圾料理时，被激发厨师灵魂，做出下饭菜”，展示厨艺，当场跟陪一份下饭菜：就地自动烹饪一份随机下饭菜
--   胡乱烹饪：潮湿黏糊，粉末蛋糕，怪物千层饼，怪物鞑靼，曼德拉草汤
--   胡乱烤：曼德拉草 夜莓 高脚鸟蛋 孵化中的高脚鸟蛋 红蘑菇 月亮蘑菇 象鼻、冬象鼻 龙虾 4种季节鱼 鼹鼠
--   胡乱吃（通用）：独眼巨鹿眼球 守护者之角 蜂王浆 曼德拉草 高脚鸟蛋 孵化中的高脚鸟蛋 格罗姆的黏液 海带补丁 象鼻、冬象鼻
--   胡乱吃（玩家）：泻根糖浆
--   胡乱吃（动物）：伏特羊肉冻 彩虹糖豆 鲜果可丽饼 龙虾正餐 华夫饼 黄油 夜莓
-- 2 自私回复加强：直接回饥饿精神和血量（避免食物记忆）+ 3.1 排除记忆的料理
-- 3 团队回复加强：队友死了烹饪四菜一汤 （开席） + 4.1 有一道菜是毒菜，吃了的人贡献自己的生命力复活死者
-- 4 随机下饭菜概率含调味料
-- 新版
-- 1 下饭操作
-- 2 开席
-- 3 喜新厌旧 在烹饪下饭菜时，沃利会进行一次“试味”，略微恢复三维。 若即将产出的菜肴存在于他的食物记忆中，将自动转化为随机未知料理。
-- 4 更加下饭

-- Section 2：画大饼
-- 1 沃利仅仅需要介绍一下他的厨艺，便可让大家饱腹。锅检测到附近有三维不满的队友，右键点击锅直接补，然后慢慢消耗
-- 2 沃利可以手搓大饼。吃了大饼效果同锅补（给寄居蟹）
-- 3 大饼可以烤而不是变成灰烬
-- 4 现烤大饼变成附近玩家最喜欢的食物，或者飞饼

-- Section 3
-- 1 真香警告：可以喂解读挑食角色食物
-- 2 真香警告：可以喂其他角色腐烂物


-- =========================================================
-- SECTION1 胡乱料理全表（含恢复与抛锅概率）
-- =========================================================
local spicedfoods = require("spicedfoods")

local FOOD_RECOVERY_TABLE = {

    -- 胡乱烹饪（锅收获触发）一个垃圾料理换一个随机料理
    harvest_pot = {
        wetgoop        = { hunger = 15, sanity = 15, health = 15, throw_chance = 0.7 },
        powdercake     = { hunger = 10, sanity = 10, health = 10, throw_chance = 0.7 },
        monsterlasagna = { hunger = 30, sanity = 20, health = 15, throw_chance = 1.0 },
        monstertartare = { hunger = 25, sanity = 15, health = 10, throw_chance = 0.8 },
        mandrakesoup   = { hunger = 60, sanity = 60, health = 60, throw_chance = 1.0 },
    },

    -- 胡乱烤（火堆）一个食材换一个随机料理
    cook_fire = {
        mandrake                 = { hunger = 25, sanity = 25, health = 25, throw_chance = 1.0 },
        ancientfruit_nightvision = { hunger = 5, sanity = 5, health = 5, throw_chance = 0.6 },
        tallbirdegg              = { hunger = 15, sanity = 5, health = 20, throw_chance = 0.4 },
        tallbirdegg_cracked      = { hunger = 15, sanity = 5, health = 20, throw_chance = 0.4 },
        red_cap                  = { hunger = 5, sanity = 1, health = 5, throw_chance = 0.1 },
        moon_cap                 = { hunger = 5, sanity = 1, health = 5, throw_chance = 0.1 },
        trunk_summer             = { hunger = 5, sanity = 5, health = 5, throw_chance = 0.4 },
        trunk_winter             = { hunger = 5, sanity = 5, health = 5, throw_chance = 0.5 },
        wobster_sheller_land     = { hunger = 15, sanity = 15, health = 15, throw_chance = 0.5 },
        oceanfish_small_8_inv    = { hunger = 15, sanity = 15, health = 15, throw_chance = 0.5 },
        oceanfish_small_7_inv    = { hunger = 15, sanity = 15, health = 15, throw_chance = 0.5 },
        oceanfish_small_6_inv    = { hunger = 15, sanity = 15, health = 15, throw_chance = 0.5 },
        oceanfish_medium_8_inv   = { hunger = 15, sanity = 15, health = 15, throw_chance = 0.5 },
        mole                     = { hunger = 15, sanity = 10, health = 10, throw_chance = 0.3 },
    },

    -- 胡乱吃（通用）一个食材换一个随机料理
    eat_common = {
        deerclops_eyeball   = { hunger = 150, sanity = 150, health = 150, throw_chance = 1.0 },
        minotaurhorn        = { hunger = 150, sanity = 150, health = 150, throw_chance = 1.0 },
        royal_jelly         = { hunger = 20, sanity = 20, health = 15, throw_chance = 0.4 },
        mandrake            = { hunger = 25, sanity = 25, health = 25, throw_chance = 1.0 },
        tallbirdegg         = { hunger = 15, sanity = 15, health = 15, throw_chance = 0.4 },
        tallbirdegg_cracked = { hunger = 20, sanity = 25, health = 15, throw_chance = 0.5 },
        glommerfuel         = { hunger = 10, sanity = 15, health = 5, throw_chance = 0.7 },
        boatpatch_kelp      = { hunger = 5, sanity = 10, health = 5, throw_chance = 0.4 },
        trunk_summer        = { hunger = 20, sanity = 10, health = 10, throw_chance = 0.4 },
        trunk_winter        = { hunger = 25, sanity = 10, health = 15, throw_chance = 0.5 },
    },

    -- 胡乱吃（玩家）一个食材换一个随机料理
    eat_player = {
        ipecacsyrup = { hunger = 33, sanity = 33, health = 33, throw_chance = 1.0 },
    },

    -- 胡乱吃（动物）一个料理换一个随机料理
    eat_animal = {
        voltgoatjelly            = { hunger = 15, sanity = 25, health = 15, throw_chance = 1.0 },
        jellybean                = { hunger = 25, sanity = 15, health = 25, throw_chance = 0.4 },
        freshfruitcrepes         = { hunger = 25, sanity = 10, health = 15, throw_chance = 1.0 },
        lobsterdinner            = { hunger = 25, sanity = 15, health = 15, throw_chance = 1.0 },
        waffles                  = { hunger = 25, sanity = 10, health = 15, throw_chance = 1.0 },
        butter                   = { hunger = 15, sanity = 25, health = 20, throw_chance = 1.0 },
        ancientfruit_nightvision = { hunger = 5, sanity = 5, health = 5, throw_chance = 0.6 },
    },
}

-- 保存沃利抛锅和烤饼的累计概率
AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return
    end

    -- 只对沃利生效
    if inst.prefab ~= "warly" then
        return
    end

    inst.warly_throw_pot_accum_chance = inst.warly_throw_pot_accum_chance or 0
    inst.warly_skypie_accum_chance = inst.warly_skypie_accum_chance or 0

    local _OldOnSave_throw = inst.OnSave
    inst.OnSave = function(inst, data)
        if _OldOnSave_throw then
            _OldOnSave_throw(inst, data)
        end
        data.throw_accumulator = inst.warly_throw_pot_accum_chance
        data.warly_skypie_accum_chance = inst.warly_skypie_accum_chance
    end

    local _OldOnLoad_throw = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if _OldOnLoad_throw then
            _OldOnLoad_throw(inst, data)
        end
        if data and data.throw_accumulator then
            inst.warly_throw_pot_accum_chance = data.throw_accumulator
        end
        if data and data.warly_skypie_accum_chance then
            inst.warly_skypie_accum_chance = data.warly_skypie_accum_chance
        end
    end
end)

-- 获取基础食物名（去掉调味前缀/后缀），更稳健地处理 spicedfoods[prefab] 存在但 .basename 为空的情况
local function GetBaseFood(prefab)
    if not prefab then return prefab end

    -- 优先使用 spicedfoods 表里的 basename
    local info = spicedfoods[prefab]
    if info and info.basename and type(info.basename) == "string" and info.basename ~= "" then
        return info.basename
    end

    -- 尝试匹配 "_spice_" 及其后所有内容为调味后缀
    -- 例：koalefig_trunk_spice_jelly -> koalefig_trunk
    --     frogfishbowl_spice_mandrake_jam -> frogfishbowl
    local base = prefab:gsub("_spice_.+$", "")
    if base ~= prefab then
        return base
    end

    return prefab
end

-- =========================================================
-- 抛锅函数
-- =========================================================
local function SpawnCookPotFX(chef, idiot, meal)
    if not chef then return end

    chef:DoTaskInTime(0.1, function()
        chef.AnimState:PlayAnimation("pyrocast")
    end)

    local x, y, z = chef.Transform:GetWorldPosition()
    local spawn_x, spawn_y, spawn_z = idiot.Transform:GetWorldPosition()

    local fx = SpawnPrefab("lucy_transform_fx")
    fx.entity:SetParent(chef.entity)
    fx.entity:AddFollower()
    fx.Follower:FollowSymbol(chef.GUID, "hair", 0, 0, 0)

    local proj = SpawnPrefab("improv_cookpot_projectile_fx")
    proj.doer = chef
    proj.meal = meal
    proj.Transform:SetPosition(x, y, z)
    proj.components.complexprojectile:Launch(Vector3(spawn_x, spawn_y, spawn_z), chef)
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
local function ApplyRecovery(inst, idiot, food_name, operation)
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
local function doFunnyCook(inst, idiot, food_name, op)
    local rec_table = FOOD_RECOVERY_TABLE[op]
    local values = rec_table and rec_table[food_name]
    if not values then return end

    -- ping个问号❓
    local playerMark = SpawnPrefab("improv_question_mark_fx")
    playerMark.entity:SetParent(inst.entity)
    playerMark.Transform:SetPosition(0, 3, 0)
    local idiotMark = SpawnPrefab("improv_question_mark_fx")
    idiotMark.entity:SetParent(idiot.entity)
    idiotMark.Transform:SetPosition(0, 3, 0)

    -- 抛锅特效概率控制
    inst.warly_throw_pot_accum_chance = inst.warly_throw_pot_accum_chance or 0
    -- 基础概率
    local base_chance = values.throw_chance or 1
    -- 随机浮动范围
    local min_mult = 0.8
    local max_mult = 1.2
    -- 生成一次随机浮动值
    local chance = base_chance * (math.random() * (max_mult - min_mult) + min_mult)
    inst.warly_throw_pot_accum_chance = inst.warly_throw_pot_accum_chance + chance
    while inst.warly_throw_pot_accum_chance >= 1 do
        inst.warly_throw_pot_accum_chance = inst.warly_throw_pot_accum_chance - 1

        inst:DoTaskInTime(0.5, function(inst)
            if inst and inst:IsValid() then
                SpawnCookPotFX(inst, idiot)
                -- puff 特效
                local puff = SpawnPrefab("warly_sky_pie_cook_fx")
                if puff then
                    puff.entity:SetParent(inst.entity)
                    puff.Transform:SetPosition(0, 1, 0)
                end
            end
        end)
    end

    -- 说话逻辑
    ApplyTalking(inst, op)

    -- 恢复逻辑
    ApplyRecovery(inst, idiot, food_name, op)
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
                if player.prefab == "warly" and player.components.health and not player.components.health:IsDead() then
                    if harvester and player:IsNear(harvester, 12) then
                        local hasSkill = player.components.skilltreeupdater and
                            player.components.skilltreeupdater:IsActivated("warly_funny_cook_base")
                        if hasSkill then
                            doFunnyCook(player, harvester, product, "harvest_pot")
                            break
                        end
                    end
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
                if player.prefab == "warly" and player.components.health and not player.components.health:IsDead() then
                    if chef and player:IsNear(chef, 12) then
                        local hasSkill = player.components.skilltreeupdater and
                            player.components.skilltreeupdater:IsActivated("warly_funny_cook_base")
                        if hasSkill then
                            doFunnyCook(player, chef, food_name, "cook_fire")
                            break
                        end
                    end
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
        if not self.inst:HasTag("dummyfood") then
            local food_name = self.inst.prefab
            food_name = GetBaseFood(food_name)
            for _, player in ipairs(AllPlayers) do
                if player.prefab == "warly" and player.components.health and not player.components.health:IsDead() then
                    if eater and player:IsNear(eater, 12) then
                        local hasSkill = player.components.skilltreeupdater and
                            player.components.skilltreeupdater:IsActivated("warly_funny_cook_base")
                        if hasSkill then
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
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- =========================================================
-- 死亡监听开席
-- =========================================================
AddPlayerPostInit(function(dead)
    if not TheWorld.ismastersim then
        return
    end
    -- 监听玩家死亡事件
    dead:ListenForEvent("death", function(inst, data)
        -- 遍历所有玩家，找附近的沃利
        for _, player in ipairs(AllPlayers) do
            if player.prefab == "warly" and player.components.health and not player.components.health:IsDead()
                and dead and player:IsNear(dead, 12)
            then
                -- 技能树控制
                local hasSkill = player.components.skilltreeupdater and
                    player.components.skilltreeupdater:IsActivated("warly_funny_cook_feast")
                if hasSkill then
                    -- 沃利发现队友去世，哀悼 + 献上“四菜一汤”
                    -- 打出问号特效❓
                    local dead_fx = SpawnPrefab("improv_question_mark_fx")
                    if dead_fx then
                        dead_fx.entity:SetParent(dead.entity)
                        dead_fx.Transform:SetPosition(0, 3, 0)
                    end
                    local warly_fx = SpawnPrefab("improv_question_mark_fx")
                    if warly_fx then
                        warly_fx.entity:SetParent(player.entity)
                        warly_fx.Transform:SetPosition(0, 3, 0)
                    end

                    -- 菜谱顺序
                    local dishes = { "ratatouille_spice_chili", "ratatouille_spice_garlic", "ratatouille_spice_salt",
                        "ratatouille_spice_sugar", "bonesoup" }

                    -- 逐个生成特效（每0.25秒）
                    for i, prefab in ipairs(dishes) do
                        player:DoTaskInTime((i - 1) * 0.25, function()
                            if player:IsValid() and dead:IsValid() then
                                SpawnCookPotFX(player, dead, prefab)
                            end
                        end)
                    end
                end
            end
        end
    end, dead)
end)


-- =========================================================
-- SECTION2 可以右键点击动作“画饼”的锅
-- =========================================================
-- ----------------------------------------------------------
-- 定义沃利专属的warly_sky_pie配方
-- ----------------------------------------------------------
AddRecipe2("warly_sky_pie",
    {
        Ingredient("portablecookpot_item", 0),
        Ingredient(CHARACTER_INGREDIENT.SANITY, 30)
    },
    TECH.NONE,
    {
        product = "warly_sky_pie",
        atlas = "images/inventoryimages/warly_sky_pie.xml",
        image = "warly_sky_pie.tex",
        builder_tag = "masterchef",           -- 仅沃利可做
        builder_skill = "warly_sky_pie_make", -- 指定技能树才能做
        description = "warly_sky_pie",
        numtogive = 3,
        no_deconstruction = true, -- 可选：防止分解还原
        sg_state = "spawn_warly_sky_pie"
    }
)

-- 添加到角色专属标签页
AddRecipeToFilter("warly_sky_pie", "CHARACTER")

-- ----------------------------------------------------------
-- 可以右键点击动作“画饼”的锅
-- ----------------------------------------------------------
-- 1) Hook portablecookpot_item prefab，本体逻辑：扫描、激活标志、提示
AddPrefabPostInit("portablecookpot_item", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("skypieinspiretool")

    -- 内部函数：启动 / 停止 检测任务
    local function StartDetection(inst)
        if inst._detect_task == nil then
            inst._detect_task = inst:DoPeriodicTask(1, function()
                local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
                if not (owner and owner:IsValid()) then
                    inst:RemoveTag("active_pot_pie")
                    inst.pie_target = nil
                    if inst.components.inventoryitem then
                        inst.components.inventoryitem.imagename = "portablecookpot_item"
                        inst.components.inventoryitem.atlasname = "images/inventoryimages2.xml"
                    end
                    return
                end

                -- 以持有者为中心检测附近玩家
                local x, y, z = owner.Transform:GetWorldPosition()
                local players = TheSim:FindEntities(x, y, z, 10, { "player" }, { "playerghost" })

                local should_activate = false
                for _, p in ipairs(players) do
                    if p and p:IsValid() and p.prefab ~= "warly" and not p:HasDebuff("warly_sky_pie_inspire_buff") then
                        if (p.components.hunger and p.components.hunger:GetPercent() < 0.5)
                            or (p.components.sanity and p.components.sanity:GetPercent() < 0.5)
                            or (p.components.health and p.components.health:GetPercent() < 0.5) then
                            should_activate = true
                            inst.pie_target = p
                            break
                        end
                    end
                end

                if should_activate then
                    if not inst:HasTag("active_pot_pie") then
                        inst:AddTag("active_pot_pie")
                        if inst.components.inventoryitem then
                            inst.components.inventoryitem.imagename = "portablecookpot_item_actived"
                            inst.components.inventoryitem.atlasname =
                            "images/inventoryimages/portablecookpot_item_actived.xml"
                        end
                        if owner.components.talker then
                            owner.components.talker:Say(GetString(owner, "ANNOUNCE_NEED_PIE"))
                        end
                    end
                else
                    if inst:HasTag("active_pot_pie") then
                        inst:RemoveTag("active_pot_pie")
                        inst.pie_target = nil
                        if inst.components.inventoryitem then
                            inst.components.inventoryitem.imagename = "portablecookpot_item"
                            inst.components.inventoryitem.atlasname = "images/inventoryimages2.xml"
                        end
                    end
                end
            end)
        end
    end

    local function StopDetection(inst)
        if inst._detect_task ~= nil then
            inst._detect_task:Cancel()
            inst._detect_task = nil
        end
        inst:RemoveTag("active_pot_pie")
        inst.pie_target = nil
        if inst.components.inventoryitem then
            inst.components.inventoryitem.imagename = "portablecookpot_item"
            inst.components.inventoryitem.atlasname = "images/inventoryimages2.xml"
        end
    end

    -- 监听物品拾取 / 丢弃
    inst:ListenForEvent("onputininventory", function(inst, owner)
        local hasSkill = owner and owner:HasTag("warly_sky_pie_pot")
        if hasSkill and owner:HasTag("player") then
            StartDetection(inst)
        else
            StopDetection(inst)
        end
    end)

    inst:ListenForEvent("ondropped", function(inst)
        StopDetection(inst)
    end)

    -- 如果生成时就在玩家身上，直接启动检测
    inst:DoTaskInTime(60, function()
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        local hasSkill = owner and owner:HasTag("warly_sky_pie_pot")
        -- print("画饼的锅是否激活：", hasSkill)
        if hasSkill and owner:HasTag("player") then
            StartDetection(inst)
        end
    end)

    inst.StartDetection = StartDetection
    inst.StopDetection = StopDetection
end)

-- 2) 定义自定义 Action
local ACTIVATE_POT_PIE = AddAction("ACTIVATE_POT_PIE", STRINGS.ACTIONS.ACTIVATE_POT_PIE, function(act)
    if not act or not act.doer then
        return
    end

    local inst = act.invobject -- 背包里的物品
    local doer = act.doer

    local hasSkill = doer and doer:HasTag("warly_sky_pie_pot") -- 技能树控制
    if not hasSkill then
        return
    end

    if not inst or not inst:IsValid() or not doer or not doer:IsValid() then
        return
    end

    -- 检查激活与冷却标志（以防万一）
    local target = inst.pie_target
    if not inst:HasTag("active_pot_pie") or target == nil then
        if doer.components.talker then
            doer.components.talker:Say("It's a bug.")
        end
        return
    end

    -- 给持有者添加 debuff（buff）
    if target:HasDebuff("warly_sky_pie_inspire_buff") then
        return
    else
        target:AddDebuff("warly_sky_pie_inspire_buff", "warly_sky_pie_inspire_buff")
    end

    -- 效果：动画
    if target.components.inventory:IsHeavyLifting() and not target.components.rider:IsRiding() then
        target.AnimState:PlayAnimation("heavy_eat")
    else
        target.AnimState:PlayAnimation("eat_pre")
        target.AnimState:PushAnimation("eat", false)
    end

    -- 效果：音效/特效/台词
    if target.SoundEmitter then
        target.SoundEmitter:PlaySound("dontstarve/common/cookingpot_finish")
    end

    if target.components.talker then
        target.components.talker:Say(GetString(target, "ANNOUNCE_EAT_PIE"))
    end

    -- 物品不能使用
    inst:RemoveTag("active_pot_pie")
    inst.pie_target = nil
    inst.components.inventoryitem.imagename = "portablecookpot_item"
    inst.components.inventoryitem.atlasname = "images/inventoryimages2.xml"

    return true
end)

ACTIONS.ACTIVATE_POT_PIE.mount_valid = true

-- 3) 在 inventory 中为目标 prefab 动态添加这个 Action（右键菜单）
-- 当玩家右键背包物品时，客户端会调用这个 hook 去决定是否显示动作
AddComponentAction("INVENTORY", "skypieinspiretool", function(inst, doer, actions, right)
    -- inst：物品实体；doer：玩家实体
    -- 我们只为 portablecookpot_item 添加动作，且需要 inst._is_activated 为 true 且不在冷却
    if inst and inst.prefab == "portablecookpot_item" and inst:HasTag("active_pot_pie") then
        if doer:HasTag("masterchef") and doer:HasTag("warly_sky_pie_pot") then -- 技能树控制
            table.insert(actions, ACTIONS.ACTIVATE_POT_PIE)
        end
    end
end)

-- 4) 给常见的 StateGraph 注册 ActionHandler
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.ACTIVATE_POT_PIE, "spawn_warly_sky_pie"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.ACTIVATE_POT_PIE, "spawn_warly_sky_pie"))

-- 5) 画饼的sg
AddStategraphState("wilson",
    State {
        name = "spawn_warly_sky_pie",
        tags = { "doing", "busy", "nocraftinginterrupt", "nomorph", "keep_pocket_rummage" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wormwood_cast_spawn_pre")
            inst.AnimState:PushAnimation("wormwood_cast_spawn", false)
            inst.sg.statemem.action = inst.bufferedaction
        end,

        timeline =
        {
            FrameEvent(0, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/cook")
                local fx = SpawnPrefab("warly_sky_pie_cook_fx")
                local x, y, z = inst.Transform:GetWorldPosition()
                fx.Transform:SetPosition(x, y + 1, z)
            end),
            FrameEvent(24, function(inst)
                inst:PerformBufferedAction()
            end),
            FrameEvent(38, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            -- FrameEvent(42, TryResumePocketRummage),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action and
                (not inst.components.playercontroller or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
            -- CheckPocketRummageMem(inst)
        end,
    }
)

AddStategraphState("wilson_client",
    State {
        name = "spawn_warly_sky_pie",
        tags = { "doing", "busy" },
        server_states = { "spawn_warly_sky_pie" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wormwood_cast_spawn_pre")
            inst.AnimState:PlayAnimation("wormwood_cast_spawn_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(1)
        end,

        onupdate = function(inst)
            if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("wormwood_cast_spawn")
                inst.AnimState:SetFrame(37)
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("wormwood_cast_spawn")
            inst.AnimState:SetFrame(37)
            inst.sg:GoToState("idle", true)
        end,
    }
)

-- 6) 过量吃东西抵消画饼buff
AddComponentPostInit("eater", function(Eater)
    local old_Eater_Eat_delta_buff = Eater.Eat

    function Eater:Eat(food, feeder)
        if not food then
            return old_Eater_Eat_delta_buff(self, food, feeder)
        end

        local stack_mult = self.eatwholestack and food.components.stackable ~= nil and
            food.components.stackable:StackSize() or 1

        -- 记录当前属性值
        local hunger_comp = self.inst.components.hunger
        local sanity_comp = self.inst.components.sanity
        local health_comp = self.inst.components.health

        local cur_hunger = hunger_comp and hunger_comp.current or 0
        local cur_sanity = sanity_comp and sanity_comp.current or 0
        local cur_health = health_comp and health_comp.currenthealth or 0

        local max_hunger = hunger_comp and hunger_comp.max or 0
        local max_sanity = sanity_comp and sanity_comp.max or 0
        local max_health = health_comp and health_comp.maxhealth or 0

        -- 自行计算食物提供量
        local health_delta = food.components.edible and food.components.edible:GetHealth(self.inst) * stack_mult or 0
        local hunger_delta = food.components.edible and food.components.edible:GetHunger(self.inst) * stack_mult or 0
        local sanity_delta = food.components.edible and food.components.edible:GetSanity(self.inst) * stack_mult or 0

        -- 计算溢出量（不计算沃利的食物记忆，给沃利一点空子）
        local overflow_health = math.max((cur_health + health_delta) - max_health, 0)
        local overflow_hunger = math.max((cur_hunger + hunger_delta) - max_hunger, 0)
        local overflow_sanity = math.max((cur_sanity + sanity_delta) - max_sanity, 0)

        -- 调用原始Eat逻辑
        old_Eater_Eat_delta_buff(self, food, feeder)

        -- 扣除buff待扣量
        if self.inst:HasDebuff("warly_sky_pie_inspire_buff") then
            local buff = self.inst:GetDebuff("warly_sky_pie_inspire_buff")
            if buff then
                if overflow_hunger > 0 then
                    buff._restore_hunger = math.max(0, (buff._restore_hunger or 0) - overflow_hunger)
                    -- print("[SkyPieBuff] 饥饿抵消:", overflow_hunger, "剩余待扣", buff._restore_hunger)
                end
                if overflow_sanity > 0 then
                    buff._restore_sanity = math.max(0, (buff._restore_sanity or 0) - overflow_sanity)
                    -- print("[SkyPieBuff] 理智抵消:", overflow_sanity, "剩余待扣", buff._restore_sanity)
                end
                if overflow_health > 0 then
                    buff._restore_health = math.max(0, (buff._restore_health or 0) - overflow_health)
                    -- print("[SkyPieBuff] 生命抵消:", overflow_health, "剩余待扣", buff._restore_health)
                end
            end
        end

        return true
    end
end)

-- 7) 补充逻辑，激活技能点的时候激活锅的扫描
function UpdatePiePotSpells(inst)
    -- 获取技能树更新组件
    local skilltreeupdater = inst.components.skilltreeupdater
    -- 判断技能是否激活
    local hasSkill = (skilltreeupdater ~= nil and skilltreeupdater:IsActivated("warly_sky_pie_pot"))

    -- 如果技能激活，激活锅的扫描
    if hasSkill then
        -- 获取玩家背包中所有带有"skypieinspiretool"标签的物品
        local inventory = inst.components.inventory
        if inventory then
            local items = inventory:GetItemsWithTag("skypieinspiretool")
            if items then
                for _, item in ipairs(items) do
                    -- 激活锅的扫描功能
                    if item.StartDetection then
                        item:StartDetection()
                    end
                end
            end
        end
    else
        -- 如果技能取消，停止锅的扫描
        local inventory = inst.components.inventory
        if inventory then
            local items = inventory:GetItemsWithTag("skypieinspiretool")
            if items then
                for _, item in ipairs(items) do
                    -- 停止锅的扫描功能
                    if item.StopDetection then
                        item:StopDetection()
                    end
                end
            end
        end
    end
end

AddPrefabPostInit("warly", function(inst)
    -- 监听技能激活和取消
    local onskillrefresh_client = function(inst) UpdatePiePotSpells(inst) end
    local onskillrefresh_server = function(inst) UpdatePiePotSpells(inst) end
    inst:ListenForEvent("onactivateskill_server", onskillrefresh_server)
    inst:ListenForEvent("ondeactivateskill_server", onskillrefresh_server)
    inst:ListenForEvent("onactivateskill_client", onskillrefresh_client)
    inst:ListenForEvent("ondeactivateskill_client", onskillrefresh_client)
end)



-- local function lamp_turnon(inst)
--     -- inst.AnimState:PlayAnimation("idle")
--     -- inst.AnimState:OverrideSymbol("swap_food", "cook_pot_food", "meatballs")
--     --     inst.AnimState:SetBank("flint")
--     -- inst.AnimState:SetBuild("flint")
--     -- inst.AnimState:PlayAnimation("idle")
-- end

-- local function lamp_ondropped(inst)
--     -- Works because of the IsEmpty check in turnon
--     -- lamp_turnoff(inst)
--     -- lamp_turnon(inst)
--     inst.AnimState:SetBank("flint")
--     inst.AnimState:SetBuild("flint")
--     inst.AnimState:PlayAnimation("idle", true)
-- end

-- AddPrefabPostInit("meatballs", function(inst)
--     inst.entity:AddFollower()
--     inst:AddTag("furnituredecor") 
--     local furnituredecor = inst:AddComponent("furnituredecor")
--     -- furnituredecor.onputonfurniture = lamp_ondropped
-- end)
-- AddPrefabPostInit("flint", function(inst)
--     inst.entity:AddFollower()
--     local furnituredecor = inst:AddComponent("furnituredecor")
--     furnituredecor.onputonfurniture = lamp_ondropped

--     -- 🔧 关键：强制刷新显示

-- end)
-- AddPrefabPostInit("decor_food", function(inst)
--     inst.entity:AddFollower()
-- end)
-- AddPrefabPostInit("decor_lamp", function(inst)
--     inst.AnimState:SetBank("flint")
--     inst.AnimState:SetBuild("flint")
--     inst.AnimState:PlayAnimation("idle")
-- end)


-- modmain.lua （或你的主脚本）
local ACTION_PLACE_FOOD_ON_TABLE = AddAction("PLACE_FOOD_ON_TABLE", "Place on table", -- perform fn:
    function(act)
        local doer = act.doer
        local target = act.target
        local invobject = act.invobject -- the item in-hand (preparedfood)
        if not (doer and target and invobject) then return end
        if not (target:HasTag("decortable") and target:HasTag("structure")) then return end
        if not invobject:HasTag("preparedfood") then return end
        if doer.prefab ~= "warly" then return end

        -- server side logic (this function runs on server)
        -- ensure table netvars exist (create if missing)
        if not target.has_table_food then
            target.has_table_food = net_bool(target.GUID, "decortable.has_table_food")
            target.table_food_hunger = net_float(target.GUID, "decortable.table_food_hunger")
        end

        local function SetTableFood(inst, prefabname, hunger)
            if prefabname and prefabname ~= "" then
                inst.has_table_food:set(true)
                inst.table_food_hunger:set(hunger or 0)
            else
                inst.has_table_food:set(false)
                inst.table_food_hunger:set(0)
            end
        end

        local function SpawnDecorFoodFor(inst, item)
            local x, y, z = inst.Transform:GetWorldPosition()
            local decor = SpawnPrefab("decor_food")
            if not decor then return nil end

            -- 确保食物存在 AnimState
            if decor.AnimState then
                -- 打印调试信息，检查传递的参数
                print("[DecorFood] 名字prefab: ", item.prefab, "food_symbol_build:", item.food_symbol_build or "cook_pot_food", "food_basename:", item.food_basename)

                -- 处理调料
                local spicename = nil
                if item.components and item.components.edible and item.components.edible.spice then
                    spicename = string.lower(item.components.edible.spice)
                elseif item.spice then
                    spicename = string.lower(item.spice)
                end
                print("[DecorFood] 调料: ", spicename)

                -- 设置食物的build和bank
                if spicename ~= nil then
                    decor.AnimState:SetBuild("plate_food")
                    decor.AnimState:SetBank("plate_food")
                    decor.AnimState:OverrideSymbol("swap_garnish", "spices", spicename)
                    decor:AddTag("spicedfood")
                else
                    decor.AnimState:SetBuild(item.food_symbol_build or "cook_pot_food")
                    decor.AnimState:SetBank("cook_pot_food")
                end

                decor.AnimState:OverrideSymbol("swap_food", item.food_symbol_build or "cook_pot_food", item.food_basename or item.prefab)

                -- 覆盖食物符号
                if decor.Physics then decor.Physics:SetActive(false) end
                if decor.Follower then decor.Follower:FollowSymbol(inst.GUID, "swap_object") end
                -- decor.components.inventoryitem:DoDropPhysics(x, y, z, 1, 1)

                print("[DecorFood] Finished applying symbols.")
            else
                print("[DecorFood] No AnimState found on decor!")
            end

            -- 返回装饰物
            return decor
        end

        -- read hunger
        local hunger = 0
        if invobject.components and invobject.components.edible then
            hunger = invobject.components.edible.hungervalue or 0
        end

        -- set table state
        SetTableFood(target, invobject.food_basename or invobject.prefab, hunger)

        -- spawn decor visual and store reference on server
        local decor = SpawnDecorFoodFor(target, invobject)
        target._table_decor_food = decor

        -- disable accepting other decor
        if target.components.furnituredecortaker then
            target.components.furnituredecortaker:SetEnabled(false)
        end

        target:AddTag("has_table_food")

        -- play sound
        if target.SoundEmitter then
            target.SoundEmitter:PlaySound("wintersfeast2019/winters_feast/table/food")
        end

        -- remove original food item (stack handling)
        if invobject.components.stackable and invobject.components.stackable:IsStack() then
            invobject.components.stackable:Get():Remove()
        else
            invobject:Remove()
        end

        -- Done
        return true
    end
)

-- Make the action appear when using a preparedfood from inventory onto a table
AddComponentAction("USEITEM", "inventoryitem", function(inst, doer, target, actions, right)
    if not target or not doer or not inst then return end
    if not target:HasTag("has_table_food") and not target:HasTag("hasfurnituredecoritem") and target:HasTag("decortable") and target:HasTag("structure") and inst:HasTag("preparedfood") and doer.prefab == "warly" then
        table.insert(actions, ACTIONS.PLACE_FOOD_ON_TABLE)
    end
end)

-- Add a stategraph action handler so the player plays the short action animation
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.PLACE_FOOD_ON_TABLE, "dolongaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.PLACE_FOOD_ON_TABLE, "dolongaction"))


-- ---- 第二个动作：当桌子被占用且 doer.hunger == 0 时，右键桌子恢复饥饿并释放桌子 ----
local ACTION_CONSUME_TABLE_FOOD = AddAction("CONSUME_TABLE_FOOD", "Consume table food",
    function(act)
        local doer = act.doer
        local target = act.target
        if not (doer and target) then return end
        if not target.has_table_food then
            -- ensure netvars exist
            target.has_table_food = net_bool(target.GUID, "decortable.has_table_food")
            target.table_food_hunger = net_float(target.GUID, "decortable.table_food_hunger")
        end
        if not target.has_table_food:value() then
            return
        end
        if not doer.components or not doer.components.hunger then return end
        -- only allow when hunger is zero (<=0 used for safety)
        if doer.components.hunger.current > 0 then
            return
        end

        -- give hunger
        local give = target.table_food_hunger:value() or 0
        if give > 0 then
            doer.components.hunger:DoDelta(give, true, "table_food_consume")
        end

        -- clear table visuals & state (server)
        if target._table_decor_food then
            if target._table_decor_food.Follower then
                target._table_decor_food.Follower:StopFollowing()
            end
            target._table_decor_food:Remove()
            target._table_decor_food = nil
        end

        -- clear netvars
        target.has_table_food:set(false)
        target.table_food_hunger:set(0)

        target:RemoveTag("has_table_food")

        if target.components.furnituredecortaker then
            target.components.furnituredecortaker:SetEnabled(true)
        end

        if target.SoundEmitter then
            target.SoundEmitter:PlaySound("dontstarve/common/eat")
        end

        return true
    end
)

-- Make the action appear on right-click context if table is occupied and doer hunger == 0
AddComponentAction("SCENE", "furnituredecortaker", function(inst, doer, actions, right)
    -- ensure netvars exist
    if not inst.has_table_food then
        inst.has_table_food = net_bool(inst.GUID, "decortable.has_table_food")
        inst.table_food_hunger = net_float(inst.GUID, "decortable.table_food_hunger")
    end
    if inst.has_table_food:value() then
        table.insert(actions, ACTIONS.CONSUME_TABLE_FOOD)
    end
end)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.CONSUME_TABLE_FOOD, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.CONSUME_TABLE_FOOD, "doshortaction"))


-- ---- 视觉更新的保底（在表实例创建时，确保桌子上显示 swap_object 为 table_food_prefab） ----
-- local function EnsureTableNetvarsAndVisuals(inst, data)
--     -- call this in AddTable's fn after inst.entity:SetPristine() OR register globally with AddPrefabPostInit for tables
--     if not inst.has_table_food then
--         inst.has_table_food = net_bool(inst.GUID, "decortable.has_table_food")
--         inst.table_food_hunger = net_float(inst.GUID, "decortable.table_food_hunger")
--     end

--     local function UpdateVisual()
--         if not inst.AnimState then return end
--         if pref and pref ~= "" then
--             inst.AnimState:OverrideSymbol("swap_object", "cook_pot_food", pref)
--         else
--             -- attempt to clear override by restoring table's own symbol (best-effort)
--             inst.AnimState:ClearOverrideSymbol("swap_object")
--         end
--     end

--     inst:DoPeriodicTask(0.5, UpdateVisual) -- periodic refresh to keep client visuals in sync
--     inst:DoTaskInTime(0, UpdateVisual)
-- end

-- -- Optionally: call EnsureTableNetvarsAndVisuals for all table prefabs on prefab init:
-- AddPrefabPostInit("wood_table_round", function(inst) EnsureTableNetvarsAndVisuals(inst) end)
-- AddPrefabPostInit("wood_table_square", function(inst) EnsureTableNetvarsAndVisuals(inst) end)
-- AddPrefabPostInit("stone_table_round", function(inst) EnsureTableNetvarsAndVisuals(inst) end)
-- AddPrefabPostInit("stone_table_square", function(inst) EnsureTableNetvarsAndVisuals(inst) end)
