-- 沃利最大的缺点是不能及时回血，加了几个东西
-- 饿的快，不吃食材，吃重复料理效果消减
-- 这三缺点加上便携红锅就发生了化学反应，爆炸般产生了一堆毛病。
-- 1.红锅硬占一格子，做饭硬控十几秒。 -- 分锅解决，一次6份烹饪
-- 2.为了丰富菜谱，各种食材又占格子。
-- 3.不能吃食材导致廉价的回血回san也做不到。  -- 摆盘消除debuff
-- 4.有用的特色料理，不是种地就是找羊，获取困难。 -- 替罪羊解决羊角问题，挖地研磨器解决
-- 5.调料也麻烦的一批，哪怕可以批发辣椒大蒜，还要磨粉，盯着调味盘一个一个上调料

-- 大厨技能估计还是不会增加自己属性让自己作战，大概率是走辅助或者驯服，比如制作低成本专属料理永久收买猪人兔人，
-- 然后料理效果对雇佣对象生效，甚至特殊料理让猪人兔人变异。
-- 毕竟哪有让厨师自己打架的说法

-- 沃利不管加多少新料理，都是做饭打包下线的玩法，所以我给它加了本体才能触发的全新的buff、全新的战斗机制、全新的做饭机制
-- 所以干脆做成一个自带buff，然后用有自己战斗方法的三体人，放弃调料煮饭的玩法
-- 战斗：专武飞饼，专属背锅AOE，肉钩吸血
-- 主线：寄居蟹花沙拉
-- 新buff：位面攻击，完全防御，移速，锁san
-- 做饭：下饭操作，烤梦想料理，摆盘
-- 生产：替罪羊 雇佣猪
-- 生活质量：摆盘持续恢复消除记忆 厨师袋保暖移速保鲜防雨回san 画大饼 san转饥饿
-- 保鲜：摆盘 厨师袋
-- 雇佣：刷食材 新战斗

-- 定义全局表来存储所有调料
local cooking = require("cooking")
_G.ALL_SPICES = {}
_G.ALL_COOKALBE_FOODS = {}
_G.ALL_SPICES = {}
_G.TOP_HEALTH_FOODS = {}
_G.TOP_SANITY_FOODS = {}
_G.TOP_HUNGER_FOODS = {}

-- 获取所有可烹饪食物和调味料
local function GetAllCookableFoodsAndSpices()


    local food_stats = {}

    -- 遍历所有烹饪食谱
    for cooker, recipes in pairs(cooking.recipes) do
        if type(recipes) == "table" then
            for product, recipe in pairs(recipes) do
                if product ~= nil and product ~= "" and type(recipe) == "table" then
                    -- 记录食物
                    _G.ALL_COOKALBE_FOODS[product] = true

                    -- 记录调味料
                    if string.match(product, "_spice_") then
                        local spiceName = string.match(product, "spice_.*")
                        _G.ALL_SPICES[spiceName] = true
                    end

                    -- 提取血量/饥饿/理智数值（若为空则为0）
                    local health = recipe.health or 0
                    local hunger = recipe.hunger or 0
                    local sanity = recipe.sanity or 0

                    table.insert(food_stats, {
                        name = product,
                        health = health,
                        hunger = hunger,
                        sanity = sanity,
                    })
                end
            end
        end
    end

    -- 按血量、理智、饥饿分别排序
    local function sort_by_key(tbl, key)
        table.sort(tbl, function(a, b)
            return (a[key] or 0) > (b[key] or 0)
        end)
    end

    sort_by_key(food_stats, "health")
    local half_index = math.ceil(#food_stats / 2)
    for i = 1, half_index do
        local f = food_stats[i]
        _G.TOP_HEALTH_FOODS[f.name] = f.health
    end

    sort_by_key(food_stats, "sanity")
    for i = 1, half_index do
        local f = food_stats[i]
        _G.TOP_SANITY_FOODS[f.name] = f.sanity
    end

    sort_by_key(food_stats, "hunger")
    for i = 1, half_index do
        local f = food_stats[i]
        _G.TOP_HUNGER_FOODS[f.name] = f.hunger
    end

    -- 输出结果日志
    -- print("========== All Cookable Foods ==========")
    -- for food, _ in pairs(_G.ALL_COOKALBE_FOODS) do
    --     print(food)
    -- end

    -- print("========== All Spices ==========")
    -- for spice, _ in pairs(_G.ALL_SPICES) do
    --     print(spice)
    -- end

    -- print("========== Top 50% Health Foods ==========")
    -- for k, v in pairs(_G.TOP_HEALTH_FOODS) do
    --     print(string.format("%s (+%.1f HP)", k, v))
    -- end

    -- print("========== Top 50% Sanity Foods ==========")
    -- for k, v in pairs(_G.TOP_SANITY_FOODS) do
    --     print(string.format("%s (+%.1f Sanity)", k, v))
    -- end

    -- print("========== Top 50% Hunger Foods ==========")
    -- for k, v in pairs(_G.TOP_HUNGER_FOODS) do
    --     print(string.format("%s (+%.1f Hunger)", k, v))
    -- end
end

-- 监听游戏中的初始化，确保游戏进入模拟状态后执行
AddSimPostInit(function()
    GetAllCookableFoodsAndSpices()
end)
