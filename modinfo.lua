local isCh = locale == "zh" or locale == "zhr"
version = "1.0.3"
name = isCh and "数值怪沃利" or "The Value Monster: Warly"
description = isCh and
    "大厨有三弱，一是食物buff共享，因此我不加新料理，而是加了很多自己才能用的食物buff和战斗生活技能" ..
    "\n二是回复能力弱，因此我加了很多特别的直接间接回复方式、消除食物记忆方式和防御方式" ..
    "\n三是获取料理和调味料困难，因此我加了很多特别的料理原材料和调味料的获取方式" ..
    "\n󰀐感谢赏玩！" ..
    "\n\n〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓" ..
    "\n󰀅完整更新日志可以在创意工坊查看" ..
    "\n"
    or
    "The chef has three weaknesses. First, shared food buffs, so instead of new recipes, I added buffs and skills only for the chef." ..
    "\nSecond, weak healing, so I added special healing methods, food memory removal, and defense mechanisms." ..
    "\nThird, difficulty in obtaining recipes and seasonings, so I added unique ways to gather ingredients and seasonings." ..
    "\n󰀐Thanks to enjoy!" ..
    "\n\n〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓" ..
    "\n󰀅Full changelog available on the Workshop" ..
    "\n"

author = "XJS"
forumthread = ""
api_version = 10
icon_atlas = "images/modicon.xml"
icon = "modicon.tex"
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false
dst_compatible = true
server_only_mod = true
client_only_mod = false
all_clients_require_mod = true

priority = -11

local function Subtitle(name)
    return {
        name = name,
        label = name,
        options = { { description = "", data = false }, },
        default = false,
    }
end
configuration_options =
{
    Subtitle(isCh and "设置" or "Settings"),
    {
        name = "LanguageSetting",
        label = isCh and "语言" or "Language",
        hover = isCh and "选择语言" or "Select Language",
        options =
        {
            { description = "中文", data = "chinese", hover = "中文" },
            { description = "English", data = "english", hover = "English" },
            { description = "default", data = "default", hover = "default" },
        },
        default = "default",
    },

    Subtitle(isCh and "吃独食" or "Selfish Eater"),
    {
        name = "selfishEaterBuffDuration",
        label = isCh and "吃独食BUFF持续时间" or "Selfish Eater Buff Duration",
        hover = isCh and "设置吃独食BUFF的持续时间（秒）"
            or "Set the duration (in seconds) of the Selfish Eater Buff",
        options =
        {
            {
                description = isCh and "较短" or "Short",
                data = 200,
                hover = isCh and "吃独食BUFF持续 200 秒"
                    or "The Selfish Eater Buff lasts 200 seconds"
            },

            {
                description = isCh and "正常" or "Normal",
                data = 300,
                hover = isCh and "吃独食BUFF持续 300 秒"
                    or "The Selfish Eater Buff lasts 300 seconds"
            },

            {
                description = isCh and "较长" or "Long",
                data = 400,
                hover = isCh and "吃独食BUFF持续 400 秒"
                    or "The Selfish Eater Buff lasts 400 seconds"
            },

            {
                description = isCh and "离谱" or "Absurd",
                data = 500,
                hover = isCh and "吃独食BUFF持续 500 秒"
                    or "The Selfish Eater Buff lasts 500 seconds"
            },
        },
        default = 300,
    },

    Subtitle(isCh and "画饼饼" or "Pie In the Sky"),
    {
        name = "dreamDishChance",
        label = isCh and "梦想料理触发概率" or "Dream Dish Trigger Chance",
        hover = isCh and "设置梦想料理的平均触发概率"
            or "Set the average trigger chance for Dream Dish",
        options =
        {
            {
                description = isCh and "较低" or "Low",
                data = 0.03,
                hover = isCh and "梦想料理平均触发概率约 3%"
                    or "Dream Dish triggers at an average chance of about 3%"
            },
            {
                description = isCh and "正常" or "Normal",
                data = 0.05,
                hover = isCh and "梦想料理平均触发概率约 5%"
                    or "Dream Dish triggers at an average chance of about 5%"
            },
            {
                description = isCh and "较高" or "High",
                data = 0.07,
                hover = isCh and "梦想料理平均触发概率约 7%"
                    or "Dream Dish triggers at an average chance of about 7%"
            },
            {
                description = isCh and "离谱" or "Absurd",
                data = 0.09,
                hover = isCh and "梦想料理平均触发概率约 9%"
                    or "Dream Dish triggers at an absurdly high 9% average chance"
            },
        },
        default = 0.05,
    },

    Subtitle(isCh and "下饭操作" or "Meal-Worth Play"),
    {
        name = "shockReoveryMultiplier",
        label = isCh and "震惊的回复比率" or "Shock Reovery Multiplier",
        hover = isCh and "设置下饭操作时震惊的回复倍率"
            or "Set the shock reovery multiplier during Meal-Worth Play",
        options =
        {
            {
                description = isCh and "较低" or "Low",
                data = 0.5,
                hover = isCh and "下饭操作震惊的回复倍率为0.5"
                    or "Shock response at 0.5× during Meal-Worth Play"
            },
            {
                description = isCh and "正常" or "Normal",
                data = 1,
                hover = isCh and "下饭操作震惊的回复倍率为1"
                    or "Shock response at normal 1× during Meal-Worth Play"
            },
            {
                description = isCh and "较高" or "High",
                data = 1.5,
                hover = isCh and "下饭操作震惊的回复倍率为1.5"
                    or "Shock response at 1.5× during Meal-Worth Play"
            },
            {
                description = isCh and "离谱" or "Absurd",
                data = 2,
                hover = isCh and "下饭操作震惊的回复倍率为2"
                    or "Shock response at an absurdly high 2× during Meal-Worth Play"
            },
        },
        default = 1,
    },

    {
        name = "cookingPowerChanceMultiplier",
        label = isCh and "获得厨力获取概率的倍率" or " Cooking Power Chance Multiplier",
        hover = isCh and "设置下饭操作时获得厨力的平均触发概率的倍率"
            or "Set the average chance to gain Cooking Power during  Meal-Worth Play",
        options =
        {
            {
                description = isCh and "较低" or "Low",
                data = 0.5,
                hover = isCh and "下饭操作厨力获取概率的倍率为0.5"
                    or "Shock response at 0.5× during Meal-Worth Play"
            },
            {
                description = isCh and "正常" or "Normal",
                data = 1,
                hover = isCh and "下饭操作厨力获取概率的倍率为1"
                    or "Shock response at normal 1× during Meal-Worth Play"
            },
            {
                description = isCh and "较高" or "High",
                data = 1.5,
                hover = isCh and "下饭操作厨力获取概率的倍率为1.5"
                    or "Shock response at 1.5× during Meal-Worth Play"
            },
            {
                description = isCh and "离谱" or "Absurd",
                data = 2,
                hover = isCh and "下饭操作厨力获取概率的倍率为2倍"
                    or "Shock response at an absurdly high 2× during Meal-Worth Play"
            },
        },
        default = 1,
    },

    Subtitle(isCh and "背锅锅" or "Burdened Pot"),
    {
        name = "burdenPotDurability",
        label = isCh and "背锅锅的耐久度" or "Burdened Pot Durability",
        hover = isCh and "设置背锅锅的耐久度数值"
            or "Set the durability value of the Burdened Pot",
        options =
        {
            {
                description = isCh and "较低" or "Low",
                data = 333,
                hover = isCh and "背锅锅只有 333 点耐久"
                    or "Burdened Pot has only 333 durability"
            },
            {
                description = isCh and "正常" or "Normal",
                data = 666,
                hover = isCh and "背锅锅有 666 点耐久"
                    or "Burdened Pot has 666 durability"
            },
            {
                description = isCh and "较高" or "High",
                data = 999,
                hover = isCh and "背锅锅有 999 点耐久"
                    or "Burdened Pot has 999 durability"
            },
            {
                description = isCh and "离谱" or "Absurd",
                data = 1332,
                hover = isCh and "背锅锅有 1332 点耐久"
                    or "Burdened Pot has 1332 durability"
            }
        },
        default = 666,
    },
    {
        name = "scapegoatHornDropChance",
        label = isCh and "替罪羊额外掉落羊角概率" or "Scapegoat Extra Horn Drop Chance",
        hover = isCh and "设置替罪羊死亡时额外掉落羊角的概率"
            or "Set the chance for Scapegoat to drop an extra horn on death",
        options =
        {
            {
                description = isCh and "较低" or "Low",
                data = 0.10,
                hover = isCh and "只有 10% 的概率额外掉落羊角"
                    or "Only 10% chance to drop an extra horn"
            },
            {
                description = isCh and "正常" or "Normal",
                data = 0.25,
                hover = isCh and "有 25% 的概率额外掉落羊角"
                    or "25% chance to drop an extra horn"
            },
            {
                description = isCh and "较高" or "High",
                data = 0.40,
                hover = isCh and "有 40% 的概率额外掉落羊角"
                    or "40% chance to drop an extra horn"
            },
            {
                description = isCh and "离谱" or "Absurd",
                data = 0.55,
                hover = isCh and "高达 55% 的概率额外掉落羊角"
                    or "A whopping 55% chance to drop an extra horn"
            },
        },
        default = 0.25,
    },

    Subtitle(isCh and "入味厨具" or "Spice Cookware"),
    {
        name = "chefPouchBuffDuration",
        label = isCh and "厨师袋调味持续天数" or "Chef Pouch Seasoning Duration",
        hover = isCh and "设置厨师袋本体在被调味后，其调味效果能保持的天数"
            or "Set how many days the Chef Pouch keeps its seasoning effect after being seasoned",
        options =
        {
            {
                description = isCh and "较短" or "Short",
                data = 5,
                hover = isCh and "厨师袋的调味效果可持续 5 天"
                    or "Seasoning on the Chef Pouch lasts 5 days"
            },

            {
                description = isCh and "正常" or "Normal",
                data = 10,
                hover = isCh and "厨师袋的调味效果可持续 10 天"
                    or "Seasoning on the Chef Pouch lasts 10 days"
            },

            {
                description = isCh and "较长" or "Long",
                data = 15,
                hover = isCh and "厨师袋的调味效果可持续 15 天"
                    or "Seasoning on the Chef Pouch lasts 15 days"
            },

            {
                description = isCh and "离谱" or "Absurd",
                data = 20,
                hover = isCh and "调味效果荒谬地持续 20 天"
                    or "Seasoning on the Chef Pouch lasts an absurd 20 days"
            },
        },
        default = 10,
    },
    {
        name = "chefPouchSpiceSanMultiplier",
        label = isCh and "厨师袋回理智值" or "Chef Pouch SAN",
        hover = isCh and "设置厨师袋内装的每个调味的料理的基础回理智值值"
            or "Set the base daily sanity gained per seasoned food in the Chef Pouch",
        options =
        {
            {
                description = isCh and "较低" or "Low",
                data = 0.5,
                hover = isCh and "每个调味的料理提供每天13.3基础回理智值"
                    or "Each seasoned food provides 13.3 base SAN per day"
            },

            {
                description = isCh and "正常" or "Normal",
                data = 1,
                hover = isCh and "每个调味的料理提供每天26.6基础回理智值"
                    or "Each seasoned food provides 26.6 base SAN per day (default)"
            },

            {
                description = isCh and "较高" or "High",
                data = 1.5,
                hover = isCh and "每个调味的料理提供每天39.9基础回理智值"
                    or "Each seasoned food provides 39.9 base SAN per day"
            },

            {
                description = isCh and "离谱" or "Absurd",
                data = 2,
                hover = isCh and "每个调味的料理提供每天53.3基础回理智值"
                    or "Each seasoned food provides 53.3 base SAN per day"
            },
        },
        default = 1,
    },
    {
        name = "grinderDigCooldown",
        label = isCh and "挖地获取调味料冷却" or "Grinding Spice Dig Cooldown",
        hover = isCh and "设置便携研磨器挖地获取调味料的冷却时间"
            or "Set the cooldown for digging spices with the Portable Grinder",
        options =
        {
            {
                description = isCh and "较慢" or "Slow",
                data = 1.5,
                hover = isCh and "冷却时间仅 1.5 天"
                    or "Cooldown is only 1.5 day"
            },

            {
                description = isCh and "正常" or "Normal",
                data = 1,
                hover = isCh and "冷却时间为 1 天"
                    or "Cooldown is 1 day"
            },

            {
                description = isCh and "较快" or "Fast",
                data = 0.8,
                hover = isCh and "冷却时间为 0.8 天"
                    or "Cooldown is 0.8 days"
            },

            {
                description = isCh and "离谱" or "Absurd",
                data = 0.6,
                hover = isCh and "冷却时间为 0.6 天"
                    or "Cooldown is 0.6 days"
            },

        },
        default = 1,
    },


    Subtitle(isCh and "屠夫" or "Butcher"),
    {
        name = "youthShadowMaceDurability",
        label = isCh and "青春版暗影槌的耐久度" or "Youth Shadow Maul Durability",
        hover = isCh and "设置青春版暗影槌的使用耐久次数"
            or "Set the durability of the Youth Shadow Maul",
        options =
        {
            {
                description = isCh and "较低" or "Low",
                data = 75,
                hover = isCh and "青春版暗影槌只有 75 次使用次数"
                    or "Youth Shadow Maul has only 75 uses"
            },

            {
                description = isCh and "正常" or "Normal",
                data = 150,
                hover = isCh and "青春版暗影槌有 150 次使用次数"
                    or "Youth Shadow Maul has 150 uses"
            },

            {
                description = isCh and "较高" or "High",
                data = 225,
                hover = isCh and "青春版暗影槌有 225 次使用次数"
                    or "Youth Shadow Maul has 225 uses"
            },

            {
                description = isCh and "离谱" or "Absurd",
                data = 300,
                hover = isCh and "青春版暗影槌拥有荒谬的 300 次使用次数"
                    or "Youth Shadow Maul has an absurd 300 uses"
            },
        },
        default = 150,
    },

    {
        name = "rottenCloudDurationPerRot",
        label = isCh and "每个腐烂物提供的腐烂云雾持续时间" or "Rotten Cloud Duration per Rot",
        hover = isCh and "设置每个腐烂物能产生的腐烂云雾持续时间"
            or "Set how long each rot contributes to the rotten cloud duration",
        options =
        {

            {
                description = isCh and "较短" or "Short",
                data = 2,
                hover = isCh and "每个腐烂物提供 2 秒的腐烂云雾"
                    or "Each rot provides 2 seconds of rotten cloud"
            },

            {
                description = isCh and "正常" or "Normal",
                data = 2.5,
                hover = isCh and "每个腐烂物提供 2.5 秒的腐烂云雾"
                    or "Each rot provides 2.5 seconds of rotten cloud"
            },

            {
                description = isCh and "长" or "Long",
                data = 3.5,
                hover = isCh and "每个腐烂物提供 3.5 秒的腐烂云雾"
                    or "Each rot provides 3.5 seconds of rotten cloud"
            },

            {
                description = isCh and "离谱" or "Absurd",
                data = 4,
                hover = isCh and "每个腐烂物提供夸张的 4 秒腐烂云雾"
                    or "Each rot provides an absurd 4 seconds of rotten cloud"
            },
        },
        default = 2.5,
    },

    {
        name = "pigmanRotCloudFX",
        label = isCh and "视觉增强版腐烂云雾" or "Enhanced Rot Cloud FX",
        hover = isCh and "启用更逼真的腐烂云雾视觉效果"
            or "Enable a more realistic visual effect for rot cloud.",
        options =
        {
            {
                description = isCh and "开启" or "On",
                data = 1,
                hover = isCh and "看起来像强壮的战士一样的腐烂云雾效果"
                    or "Looks like a strongman rot cloud effect"
            },
            {
                description = isCh and "关闭" or "Off",
                data = 0,
                hover = isCh and "平平无奇的腐烂云雾效果"
                    or "Just a plain rot cloud effect"
            },
        },
        default = 1,
    },

}
