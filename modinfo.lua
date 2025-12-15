local isCh = locale == "zh" or locale == "zhr"
version = "1.0.8"
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
        label = isCh and "吃独食BUFF持续时间" or "Selfish Buff Duration",
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
    {
        name = "boneBouillonShieldChance",
        label = isCh and "骨头汤护盾概率" or "Bone Shield Chance",
        hover = isCh and "设置食用骨头汤时触发无敌护盾的概率"
            or "Set the chance to trigger an invincibility shield when eating Bone Bouillon",
        options =
        {
            {
                description = isCh and "较低" or "Low",
                data = 0.15,
                hover = isCh and "只有 15% 的概率触发无敌护盾"
                    or "Only a 15% chance to trigger the invincibility shield"
            },

            {
                description = isCh and "正常" or "Normal",
                data = 0.25,
                hover = isCh and "有 25% 的概率触发无敌护盾（默认）"
                    or "A 25% chance to trigger the invincibility shield (default)"
            },

            {
                description = isCh and "较高" or "High",
                data = 0.35,
                hover = isCh and "有 35% 的概率触发无敌护盾"
                    or "A 35% chance to trigger the invincibility shield"
            },

            {
                description = isCh and "离谱" or "Absurd",
                data = 0.45,
                hover = isCh and "有 45% 的概率触发无敌护盾"
                    or "An absurd 45% chance to trigger the invincibility shield"
            },
        },
        default = 0.25,
    },
    {
        name = "fruitCrepeMaxSan",
        label = isCh and "可丽饼最高理智" or "Crepe Max SAN",
        hover = isCh and "设置食用鲜果可丽饼时能回的最大理智比例"
            or "Set the maximum SAN restored by eating a Fruit Crepe",
        options =
        {
            {
                description = isCh and "较低" or "Low",
                data = 0.85,
                hover = isCh and "理智只回到最大值的85%"
                    or "SAN is restored only up to 85% of the maximum"
            },

            {
                description = isCh and "正常" or "Normal",
                data = 0.9,
                hover = isCh and "理智只回到最大值的90%"
                    or "SAN is restored only up to 90% of the maximum "
            },

            {
                description = isCh and "较高" or "High",
                data = 0.95,
                hover = isCh and "理智只回到最大值的95%"
                    or "SAN is restored only up to 95% of the maximum "
            },

            {
                description = isCh and "离谱" or "Absurd",
                data = 1,
                hover = isCh and "理智可完全回满"
                    or "SAN can be fully restored"
            },
        },
        default = 0.9,
    },
    {
        name = "potatoMaxDamage",
        label = isCh and "土豆最高攻击倍率" or "Potato Max ATK",
        hover = isCh and "设置食用蓬松土豆蛋奶酥时能获得的最高攻击倍率"
            or "Set the maximum attack multiplier granted by consuming Fluffy Potato Soufflé",
        options =
        {
            {
                description = isCh and "较低" or "Low",
                data = 1.5,
                hover = isCh and "攻击倍率1.5倍"
                    or "ATK multiplier 1.5x"
            },

            {
                description = isCh and "正常" or "Normal",
                data = 2.0,
                hover = isCh and "攻击倍率2.0倍"
                    or "ATK multiplier 2.0x"
            },

            {
                description = isCh and "较高" or "High",
                data = 2.5,
                hover = isCh and "攻击倍率2.5倍"
                    or "ATK multiplier 2.5x"
            },

            {
                description = isCh and "离谱" or "Absurd",
                data = 3.0,
                hover = isCh and "攻击倍率3.0倍"
                    or "ATK multiplier 3.0x"
            },
        },
        default = 2.0,
    },
    {
        name = "moquecaTorrentDamage",
        label = isCh and "海鲜杂烩洪流伤害" or "Moqueca Torrent Damage",
        hover = isCh and "设置海鲜杂烩召唤洪流的伤害"
            or "Set the damage of the torrent summoned by Moqueca",
        options =
        {
            {
                description = isCh and "较低" or "Low",
                data = 5,
                hover = isCh and "洪流伤害为5"
                    or "Torrent damage is 5"
            },

            {
                description = isCh and "正常" or "Normal",
                data = 10,
                hover = isCh and "洪流伤害为10"
                    or "Torrent damage is 10"
            },

            {
                description = isCh and "较高" or "High",
                data = 15,
                hover = isCh and "洪流伤害为15"
                    or "Torrent damage is 15"
            },

            {
                description = isCh and "离谱" or "Absurd",
                data = 20,
                hover = isCh and "洪流伤害为20"
                    or "Torrent damage is 20"
            },
        },
        default = 10,
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
    {
        name = "flyingPieMaxCount",
        label = isCh and "飞饼最大同时数量" or "Max Flying Pies",
        hover = isCh and "设置飞饼技能同时能飞出的最大数量"
            or "Set the maximum number of Flying Pies that can be active at the same time",
        options =
        {
            {
                description = isCh and "较少" or "Few",
                data = 2,
                hover = isCh and "最多同时飞出 2 个飞饼"
                    or "Allows up to 2 Flying Pies at the same time",
            },
            {
                description = isCh and "正常" or "Normal",
                data = 3,
                hover = isCh and "最多同时飞出 3 个飞饼（默认）"
                    or "Allows up to 3 Flying Pies at the same time (default)",
            },
            {
                description = isCh and "较多" or "Many",
                data = 4,
                hover = isCh and "最多同时飞出 4 个飞饼"
                    or "Allows up to 4 Flying Pies at the same time",
            },
            {
                description = isCh and "离谱" or "Absurd",
                data = 5,
                hover = isCh and "最多同时飞出 5 个飞饼"
                    or "Allows up to 5 Flying Pies at the same time",
            },
        },
        default = 3,
    },

    Subtitle(isCh and "真香警告" or "True Duration Warning"),
    {
        name = "lingeringFlavorBuffRange",
        label = isCh and "余香犹在持续时间" or "Lingering Taste Duration",
        hover = isCh and "设置余香犹在buff的持续时间上下限，实际时间会根据吃摆盘料理时的饥饿度计算，越饿持续时间越长"
            or "Set the Lingering Taste' min and max duration, actual will be calculated based on hunger, the hungrier the longer",
        options =
        {
            {
                description = isCh and "较低" or "Low",
                data = 300,
                hover = isCh and "持续时间在 300 到 600 秒之间"
                    or "Duration will range from 300 to 600 seconds"
            },

            {
                description = isCh and "正常" or "Normal",
                data = 400,
                hover = isCh and "持续时间在 400 到 800 秒之间"
                    or "Duration will range from 400 to 800 seconds"
            },

            {
                description = isCh and "较高" or "High",
                data = 500,
                hover = isCh and "持续时间在 500 到 1000 秒之间"
                    or "Duration will range from 500 to 1000 seconds"
            },

            {
                description = isCh and "离谱" or "Absurd",
                data = 600,
                hover = isCh and "持续时间在 600 到 1200 秒之间"
                    or "Duration will range from 600 to 1200 seconds"
            },
        },
        default = 400
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
    {
        name = "warlyNoobSlow",
        label = isCh and "菜鸡减速效果" or "Noob Slow Effect",
        hover = isCh and "设置被菜鸡诅咒减速的速度倍率"
            or "Set the speed multiplier for the Noob Chicken curse",
        options =
        {
            {
                description = isCh and "较低" or "Low",
                data = 0.1333,
                hover = isCh and "速度为正常速度的 13.33%"
                    or "Speed is 13.33% of normal"
            },
            {
                description = isCh and "正常" or "Normal",
                data = 0.2333,
                hover = isCh and "速度为正常速度的 23.33%"
                    or "Speed is 23.33% of normal"
            },
            {
                description = isCh and "较高" or "High",
                data = 0.3333,
                hover = isCh and "速度为正常速度的 33.33%"
                    or "Speed is 33.33% of normal"
            },
            {
                description = isCh and "离谱" or "Absurd",
                data = 0.4333,
                hover = isCh and "速度为正常速度的 43.33%"
                    or "Speed is 43.33% of normal"
            },
        },
        default = 0.2333,
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
        name = "burdenPotDamageLoss",
        label = isCh and "背锅锅受击损失比例" or "Burdened Pot Hit Loss Ratio",
        hover = isCh and "设置穿戴背锅锅时，免疫生命伤害后会损失多少比例的饥饿与理智"
            or "Set the percentage of prevented damage converted into Hunger and Sanity loss while wearing the Burdened Pot",
        options =
        {
            {
                description = isCh and "较弱" or "Weak",
                data = 0.16,
                hover = isCh and "受到攻击时损失相当于伤害 16% 的饥饿与理智"
                    or "Lose Hunger and Sanity equal to 16% of the prevented damage",
            },
            {
                description = isCh and "正常" or "Normal",
                data = 0.13,
                hover = isCh and "受到攻击时损失相当于伤害 13% 的饥饿与理智"
                    or "Lose Hunger and Sanity equal to 13% of the prevented damage",
            },
            {
                description = isCh and "较强" or "Strong",
                data = 0.10,
                hover = isCh and "受到攻击时损失相当于伤害 10% 的饥饿与理智"
                    or "Lose Hunger and Sanity equal to 10% of the prevented damage",
            },
            {
                description = isCh and "离谱" or "Absurd",
                data = 0.07,
                hover = isCh and "受到攻击时损失相当于伤害 7% 的饥饿与理智"
                    or "Lose Hunger and Sanity equal to 7% of the prevented damage",
            },
        },
        default = 0.13,
    },
    {
        name = "flungPotImpactDamage",
        label = isCh and "甩锅中心震点伤害" or "Flung Pot Impact Damage",
        hover = isCh and "设置甩锅时每个锅中心震点的伤害值，越靠近中心伤害越高"
            or "Set the damage dealt at the center of each Burdened Pot when thrown; damage is higher near the center",
        options =
        {
            {
                description = isCh and "较弱" or "Weak",
                data = 150,
                hover = isCh and "每个锅中心震点伤害为 150"
                    or "Each pot's central impact deals 150 damage"
            },
            {
                description = isCh and "正常" or "Normal",
                data = 225,
                hover = isCh and "每个锅中心震点伤害为 225"
                    or "Each pot's central impact deals 225 damage"
            },
            {
                description = isCh and "较强" or "Strong",
                data = 300,
                hover = isCh and "每个锅中心震点伤害为 300"
                    or "Each pot's central impact deals 300 damage"
            },
            {
                description = isCh and "离谱" or "Absurd",
                data = 375,
                hover = isCh and "每个锅中心震点伤害为 375"
                    or "Each pot's central impact deals 375 damage"
            },
        },
        default = 225,
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
                hover = isCh and "有 55% 的概率额外掉落羊角"
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
                hover = isCh and "厨师袋的调味效果可持续 20 天"
                    or "Seasoning on the Chef Pouch lasts an absurd 20 days"
            },
        },
        default = 10,
    },
    {
        name = "chefPouchSpiceSanMultiplier",
        label = isCh and "厨师袋回理智值" or "Chef Pouch SAN",
        hover = isCh and "设置厨师袋内每组（最多40个）调味料理每天提供的回理智值"
            or "Set the daily SAN provided per seasoned food stack (up to 40 items) in the Chef Pouch",
        options =
        {
            {
                description = isCh and "较低" or "Low",
                data = 0.5,
                hover = isCh and "每组调味料理每天约提供 9.8 点理智"
                    or "Each seasoned food stack provides ~9.8 SAN per day"
            },
            {
                description = isCh and "正常" or "Normal",
                data = 1,
                hover = isCh and "每组调味料理每天约提供 19.7 点理智"
                    or "Each seasoned food stack provides ~19.7 SAN per day"
            },
            {
                description = isCh and "较高" or "High",
                data = 1.5,
                hover = isCh and "每组调味料理每天约提供 29.6 点理智"
                    or "Each seasoned food stack provides ~29.6 SAN per day"
            },
            {
                description = isCh and "离谱" or "Absurd",
                data = 2,
                hover = isCh and "每组调味料理每天约提供 39.4 点理智"
                    or "Each seasoned food stack provides ~39.4 SAN per day"
            },
        },
        default = 1,
    },
    {
        name = "chefPouchSlotCount",
        label = isCh and "厨师袋格子数量" or "Chef Pouch Slots",
        hover = isCh and "设置调味的厨师袋内格子的数量"
            or "Set the number of slots in the Spiced Chef Pouch",
        options =
        {
            {
                description = isCh and "较少" or "Few",
                data = 6,
                hover = isCh and "调味的厨师袋有 6 个格子"
                    or "Spiced Chef Pouch has 6 slots"
            },
            {
                description = isCh and "正常" or "Normal",
                data = 8,
                hover = isCh and "调味的厨师袋有 8 个格子"
                    or "Spiced Chef Pouch has 8 slots"
            },
            {
                description = isCh and "较多" or "Many",
                data = 10,
                hover = isCh and "调味的厨师袋有 10 个格子"
                    or "Spiced Chef Pouch has 10 slots"
            },
            {
                description = isCh and "离谱" or "Absurd",
                data = 12,
                hover = isCh and "调味的厨师袋有 12 个格子"
                    or "Spiced Chef Pouch has 12 slots"
            },
        },
        default = 8,
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
