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

-- 获取所有可烹饪食物和调味料
local function GetAllCookableFoodsAndSpices()
    -- 遍历所有烹饪食谱
    for cooker, recipes in pairs(cooking.recipes) do
        if type(recipes) == "table" then
            for product, _ in pairs(recipes) do
                if product ~= nil and product ~= "" then
                    -- 记录食物
                    ALL_COOKALBE_FOODS[product] = true

                    -- 检查是否为调味料
                    if string.match(product, "_spice_") then
                        -- 截取调味料的名字，保留"spice_"后面的部分
                        local spiceName = string.match(product, "spice_.*")  -- 匹配"spice_"及其后面的内容
                        -- 去重并记录调味料
                        ALL_SPICES[spiceName] = true
                    end
                end
            end
        end
    end
    -- print("All Cookable Foods:")
    -- for food, _ in pairs(_G.ALL_COOKALBE_FOODS) do
    --     print(food)
    -- end

    -- print("All Spices:")
    -- for spice, _ in pairs(_G.ALL_SPICES) do
    --     print(spice)
    -- end
end

-- 监听游戏中的初始化，确保游戏进入模拟状态后执行
AddSimPostInit(function()
    GetAllCookableFoodsAndSpices()
end)
