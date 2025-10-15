-- 登记技能树
local BuildSkillsData = require("prefabs/skilltree_warly_new") -- 角色的技能树文件
local defs = require("prefabs/skilltree_defs")

local data = BuildSkillsData(defs.FN)

-- 技能树用到的图标
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_bonesoup_buff.xml"))
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_crepes_buff.xml"))
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_potato_buff.xml"))
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_seafood_buff.xml"))
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_seafood_buff.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_bonesoup_buff.xml", "warly_bonesoup_buff.tex")
RegisterSkilltreeIconsAtlas("images/skilltree/warly_crepes_buff.xml", "warly_crepes_buff.tex")
RegisterSkilltreeIconsAtlas("images/skilltree/warly_potato_buff.xml", "warly_potato_buff.tex")
RegisterSkilltreeIconsAtlas("images/skilltree/warly_seafood_buff.xml", "warly_seafood_buff.tex")
RegisterSkilltreeIconsAtlas("images/skilltree/warly_seafood_buff.xml", "warly_seafood_buff.tex")

defs.CreateSkillTreeFor("warly", data.SKILLS)
defs.SKILLTREE_ORDERS["warly"] = data.ORDERS

-- 技能树用到的背景图
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_background.xml"))
RegisterSkilltreeBGForCharacter("images/skilltree/warly_background.xml", "warly")

