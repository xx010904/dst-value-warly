-- 登记技能树
local BuildSkillsData = require("prefabs/skilltree_wanda_new") -- 角色的技能树文件
local defs = require("prefabs/skilltree_defs")

local data = BuildSkillsData(defs.FN)

-- 技能树用到的图标
table.insert(Assets, Asset("ATLAS", "images/skilltree/wilson_alchemy_reverse_1.xml"))
table.insert(Assets, Asset("ATLAS", "images/skilltree/wilson_allegiance_shadow_beard.xml"))
table.insert(Assets, Asset("ATLAS", "images/skilltree/wilson_allegiance_lunar_torch.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/wilson_alchemy_reverse_1.xml", "wilson_alchemy_reverse_1.tex")
RegisterSkilltreeIconsAtlas("images/skilltree/wilson_allegiance_shadow_beard.xml", "wilson_allegiance_shadow_beard.tex")
RegisterSkilltreeIconsAtlas("images/skilltree/wilson_allegiance_lunar_torch.xml", "wilson_allegiance_lunar_torch.tex")

defs.CreateSkillTreeFor("wanda", data.SKILLS)
defs.SKILLTREE_ORDERS["wanda"] = data.ORDERS

-- 技能树用到的背景图
table.insert(Assets, Asset("ATLAS", "images/skilltree/wanda_background.xml"))
RegisterSkilltreeBGForCharacter("images/skilltree/wanda_background.xml", "wanda")

