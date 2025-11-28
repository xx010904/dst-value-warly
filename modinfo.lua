local isCh = locale == "zh" or locale == "zhr"
version = "1.0.2"
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
                data = 1333,
                hover = isCh and "背锅锅有 1333 点耐久"
                    or "Burdened Pot has 1333 durability"
            }
        },
        default = 666,
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
                hover = isCh and "梦想料理平均触发概率约 9%，十分荒谬"
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
                hover = isCh and "下饭操作震惊的回复倍率为 0.5 倍"
                    or "Shock response at 0.5× during Meal-Worth Play"
            },
            {
                description = isCh and "正常" or "Normal",
                data = 1,
                hover = isCh and "下饭操作震惊的回复倍率为 1 倍"
                    or "Shock response at normal 1× during Meal-Worth Play"
            },
            {
                description = isCh and "较高" or "High",
                data = 1.5,
                hover = isCh and "下饭操作震惊的回复倍率为 1.5 倍"
                    or "Shock response at 1.5× during Meal-Worth Play"
            },
            {
                description = isCh and "离谱" or "Absurd",
                data = 2,
                hover = isCh and "下饭操作震惊的回复倍率为 2 倍，非常夸张"
                    or "Shock response at an absurdly high 2× during Meal-Worth Play"
            },
        },
        default = 1,
    },

    {
        name = "cookingPowerChanceMultiplier",
        label = isCh and "获得厨力获取概率比率" or " Cooking Power Chance Multiplier",
        hover = isCh and "设置下饭操作时获得厨力的平均触发概率比率"
            or "Set the average chance to gain Cooking Power during  Meal-Worth Play",
        options =
        {
            {
                description = isCh and "较低" or "Low",
                data = 0.5,
                hover = isCh and "下饭操作厨力获取概率倍率为 0.5 倍"
                    or "Shock response at 0.5× during Meal-Worth Play"
            },
            {
                description = isCh and "正常" or "Normal",
                data = 1,
                hover = isCh and "下饭操作厨力获取概率倍率为 1 倍"
                    or "Shock response at normal 1× during Meal-Worth Play"
            },
            {
                description = isCh and "较高" or "High",
                data = 1.5,
                hover = isCh and "下饭操作厨力获取概率倍率为 1.5 倍"
                    or "Shock response at 1.5× during Meal-Worth Play"
            },
            {
                description = isCh and "离谱" or "Absurd",
                data = 2,
                hover = isCh and "下饭操作厨力获取概率倍率为 2 倍，非常夸张"
                    or "Shock response at an absurdly high 2× during Meal-Worth Play"
            },
        },
        default = 1,
    },

    Subtitle(isCh and "调味厨具" or "Seasoning Utensile"),
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

}
