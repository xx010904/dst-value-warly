local isCh = locale == "zh" or locale == "zhr"
version = "1.0.0"
name = isCh and "数值怪沃利" or "The Value Monster: Warly"
description = isCh and 
"大厨有三弱。一弱是能力可以被他人共享，因此我设计了一些必须大厨出场才能触发的技能点；二弱是回血能力有限，因此我增加了一些防御相关的技能点；三弱是获取buff料理不易，所以我加入了一些新的buff料理。当然啦，数值增强技能点也是很重要的，比如直接加buff时长的..."..
"\n󰀐感谢赏玩！"..
"\n\n〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓"..
"\n󰀅完整更新日志可以在创意工坊查看"..
"\n"
or
"Warly has 3 weaknesses. First, his abilities can be shared, so I added skill points that only trigger when he’s present. Second, his healing is limited, so I included defense-focused skill points. Third, buff dishes are hard to get, so I added some new ones. Of course, Direct buff-duration boosts are important too..."..
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

    Subtitle(isCh and "机制开关" or "Mechanism Switches"),
    {
        name = "lonely_eater_switch",
        label = isCh and "吃独食" or "Eat Alone",
        hover = isCh and "启用沃利的吃独食技能树" or "Enable Warly's 'Eat Alone'  Skill Tree",
        options =
        {
            { description = isCh and "开" or "On", data = true,  hover = isCh and "启用" or "Enable" },
            { description = isCh and "关" or "Off", data = false, hover = isCh and "关闭" or "Disable" },
        },
        default = true,
    },

    {
        name = "funny_cooker_switch",
        label = isCh and "下饭操作" or "Meal-worthy Play",
        hover = isCh and "启用沃利的下饭操作技能树" or "Enable Warly's 'Meal-worthy Play' Skill Tree",
        options =
        {
            { description = isCh and "开" or "On", data = true,  hover = isCh and "启用" or "Enable" },
            { description = isCh and "关" or "Off", data = false, hover = isCh and "关闭" or "Disable" },
        },
        default = true,
    },

    {
        name = "crockpot_carrier_switch",
        label = isCh and "背锅侠" or "Crockpot Carrier",
        hover = isCh and "启用沃利的背锅侠技能树" or "Enable Warly's 'Crockpot Carrier' Skill Tree",
        options =
        {
            { description = isCh and "开" or "On", data = true,  hover = isCh and "启用" or "Enable" },
            { description = isCh and "关" or "Off", data = false, hover = isCh and "关闭" or "Disable" },
        },
        default = true,
    },

    {
        name = "lunar_switch",
        label = isCh and "月亮机制" or "Lunar System",
        hover = isCh and "启用月亮主题的强化机制" or "Enable lunar-themed enhancement system",
        options =
        {
            { description = isCh and "开" or "On", data = true,  hover = isCh and "启用" or "Enable" },
            { description = isCh and "关" or "Off", data = false, hover = isCh and "关闭" or "Disable" },
        },
        default = true,
    },

    {
        name = "shadow_switch",
        label = isCh and "暗影机制" or "Shadow System",
        hover = isCh and "启用暗影主题的强化机制" or "Enable shadow-themed enhancement system",
        options =
        {
            { description = isCh and "开" or "On", data = true,  hover = isCh and "启用" or "Enable" },
            { description = isCh and "关" or "Off", data = false, hover = isCh and "关闭" or "Disable" },
        },
        default = true,
    },
}
