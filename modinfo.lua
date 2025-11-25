local isCh = locale == "zh" or locale == "zhr"
version = "1.0.0"
name = isCh and "数值怪沃利" or "The Value Monster: Warly"
description = isCh and 
"大厨有三弱，一是食物buff共享，因此我不加新料理，而是加了很多自己才能用的食物buff和战斗生活技能"..
"\n二是回复能力弱，因此我加了很多特别的直接间接回复方式、消除食物记忆方式和防御方式"..
"\n三是获取料理和调味料困难，因此我加了很多特别的料理原材料和调味料的获取方式"..
"\n󰀐感谢赏玩！"..
"\n\n〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓"..
"\n󰀅完整更新日志可以在创意工坊查看"..
"\n"
or
"The chef has three weaknesses. First, shared food buffs, so instead of new recipes, I added buffs and skills only for the chef."..
"\nSecond, weak healing, so I added special healing methods, food memory removal, and defense mechanisms."..
"\nThird, difficulty in obtaining recipes and seasonings, so I added unique ways to gather ingredients and seasonings."..
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
}
