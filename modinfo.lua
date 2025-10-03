local isCh = locale == "zh" or locale == "zhr"
version = "1.0.0"
name = isCh and "数值怪沃利" or "The Value Monster: Warly"
description = isCh and 
"科雷行，我也行。希望科雷不要剽窃我的创意~"..
"\n󰀐感谢赏玩！"..
"\n\n〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓"..
"\n󰀅完整更新日志可以在创意工坊查看"..
"\n"
or
"Klei can, I can. Hope that Klei won't plagiarize my ideas~ "..
"\n󰀐Thanks to enjoy!"..
"\n\n〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓"..
"\n󰀅Full changelog available on the Workshop"..
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
		options = { {description = "", data = false}, },
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
            {description = "中文", data = "chinese", hover = "中文"},
            {description = "English", data = "english", hover = "English"},
            {description = "default", data = "default", hover = "default"},
        },
        default = "default",
    },
    Subtitle(isCh and "火炬设置" or "Torch Settings"),
    {
        name = "TorchFuelConsumption",
        label = isCh and "火炬耐久时间" or "Torch Time",
        hover = isCh and "火炬技能树的持续时长的倍率" or "Torch Fuel Time Multiplier",
        options =
        {
            { description = "1", data = 1, hover = isCh and "原本" or "Original" },
            { description = "2", data = 2, hover = isCh and "2倍" or "2 times" },
            { description = "3", data = 3, hover = isCh and "3倍" or "3 times" },
        },
        default = 3,
    },
    
    {
        name = "TorchRadius",
        label = isCh and "火炬光照范围" or "Torch Radius",
        hover = isCh and "火炬技能树的照明范围的倍率" or "Torch Radius Multiplier",
        options =
        {
            { description = "1", data = 1, hover = isCh and "原本" or "Original" },
            { description = "2", data = 2, hover = isCh and "2倍" or "2 times" },
            { description = "3", data = 3, hover = isCh and "3倍" or "3 times" },
        },
        default = 3,
    },
    
    {
        name = "TorchToss",
        label = isCh and "火炬投掷距离" or "Torch Toss Distance",
        hover = isCh and "火炬投掷的最大距离" or "Torch Toss Distance Multiplier",
        options =
        {
            { description = "1", data = 1, hover = isCh and "原本" or "Original" },
            { description = "2", data = 2, hover = isCh and "2倍" or "2 times" },
            { description = "3", data = 3, hover = isCh and "3倍" or "3 times" },
        },
        default = 3,
    },
    
    Subtitle(isCh and "胡须设置" or "Beard Settings"),
    {
		name = "BeardDropBit",
		label = isCh and "胡须掉落" or "Beard Drop",
		hover = isCh and "刮胡须的时候掉落倍率" or "Beard Drop Multiplier", --原版是1/2/3级1/3/9个胡须
		options =
		{
			{ description = "1", data = 1, hover = isCh and "原本" or "Original" },
            { description = "2", data = 2, hover = isCh and "2倍" or "2 times" },
            { description = "3", data = 3, hover = isCh and "3倍" or "3 times" },
		},
		default = 3,
	},

    {
        name = "BeardInsulation",
        label = isCh and "胡须保暖" or "Beard Insulation",
        hover = isCh and "胡须保暖技能树的倍率" or "Beard Insulation Multiplier",
        options =
        {
            { description = "1", data = 1, hover = isCh and "原本" or "Original" },
            { description = "2", data = 2, hover = isCh and "2倍" or "2 times" },
            { description = "3", data = 3, hover = isCh and "3倍" or "3 times" },
        },
        default = 3,
    },

    {
        name = "BeardGrowth",
        label = isCh and "胡须生长" or "Beard Growth",
        hover = isCh and "胡须生长速度的倍率" or "Beard Growth Accumulation Multiplier",
        options =
        {
            { description = "1", data = 1, hover = isCh and "原本" or "Original" },
            { description = "2", data = 2, hover = isCh and "2倍" or "2 times" },
            { description = "3", data = 3, hover = isCh and "3倍" or "3 times" },
        },
        default = 3,
    },

    {
        name = "BeardSlots",
        label = isCh and "胡须格子" or "Beard Slots",
        hover = isCh and "胡须格子的倍率" or "Beard Slots Multiplier",
        options =
        {
            { description = "1", data = 1, hover = isCh and "原本" or "Original" },
            { description = "2", data = 2, hover = isCh and "2倍" or "2 times" },
            { description = "3", data = 3, hover = isCh and "3倍" or "3 times" },
        },
        default = 3,
    },

    Subtitle(isCh and "炼金术设置" or "Alchemy Settings"),
    {
        name = "TransmuteNumber",
        label = isCh and "转换数量" or "Transmute Number",
        hover = isCh and "炼金术一次性转换的数量的倍率" or "Alchemy transmute quantity multiplier",
        options =
        {
            { description = "1", data = 1, hover = isCh and "原本" or "Original" },
            { description = "2", data = 2, hover = isCh and "2倍" or "2 times" },
            { description = "3", data = 3, hover = isCh and "3倍" or "3 times" },
        },
        default = 3,
    },

    Subtitle(isCh and "新机制" or "New Mechanism"),
    {
        name = "IsNewTree",
        label = isCh and "新技能树" or "New Skill Tree",
        hover = isCh and "每种炼金术少消耗1级，可学习炼金术的终极技能可逆转换。月亮亲和强化火炬，暗影亲和强化胡须。" or "Each type of alchemy consumes one less level, and the ultimate skill of alchemy allows for reverse transformation.Lunar affinity enhances torches, shadow affinity enhances beards",
        options =
        {
            { description = isCh and "真" or "True", data = true, hover = isCh and "真" or "True" },
            { description = isCh and "假" or "False", data = false, hover = isCh and "假" or "False" },
        },
        default = true,
    },
}
