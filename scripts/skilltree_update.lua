-- 登记技能树
local BuildSkillsData = require("prefabs/skilltree_warly_new") -- 角色的技能树文件
local defs = require("prefabs/skilltree_defs")

local data = BuildSkillsData(defs.FN)

-- =============================================================================
--  技能树用到的图标
-- =============================================================================
-- 吃独食
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_bonesoup_buff.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_bonesoup_buff.xml", "warly_bonesoup_buff.tex")
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_crepes_buff.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_crepes_buff.xml", "warly_crepes_buff.tex")
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_potato_buff.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_potato_buff.xml", "warly_potato_buff.tex")
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_seafood_buff.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_seafood_buff.xml", "warly_seafood_buff.tex")
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_monstertartare_buff.xml"))

-- 分享食物
RegisterSkilltreeIconsAtlas("images/skilltree/warly_monstertartare_buff.xml", "warly_monstertartare_buff.tex")
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_share_buff.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_share_buff.xml", "warly_share_buff.tex")

-- 下饭操作
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_funny_cook_base.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_funny_cook_base.xml", "warly_funny_cook_base.tex")
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_crockpot_transfer.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_crockpot_transfer.xml", "warly_crockpot_transfer.tex")
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_funny_cook_feast.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_funny_cook_feast.xml", "warly_funny_cook_feast.tex")
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_funny_cook_spice.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_funny_cook_spice.xml", "warly_funny_cook_spice.tex")

-- 真香警告
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_true_delicious_desk.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_true_delicious_desk.xml", "warly_true_delicious_desk.tex")
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_true_delicious_restore.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_true_delicious_restore.xml", "warly_true_delicious_restore.tex")
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_true_delicious_memory.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_true_delicious_memory.xml", "warly_true_delicious_memory.tex")

-- 画饼饼
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_sky_pie_pot.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_sky_pie_pot.xml", "warly_sky_pie_pot.tex")
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_sky_pie_make.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_sky_pie_make.xml", "warly_sky_pie_make.tex")
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_sky_pie_baked.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_sky_pie_baked.xml", "warly_sky_pie_baked.tex")
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_sky_pie_favorite.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_sky_pie_favorite.xml", "warly_sky_pie_favorite.tex")

-- 背锅锅
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_crockpot_make.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_crockpot_make.xml", "warly_crockpot_make.tex")
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_crockpot_transfer.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_crockpot_transfer.xml", "warly_crockpot_transfer.tex")
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_crockpot_flung.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_crockpot_flung.xml", "warly_crockpot_flung.tex")
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_crockpot_scapegoat.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_crockpot_scapegoat.xml", "warly_crockpot_scapegoat.tex")

-- 研磨器
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_crockpot_jump.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_crockpot_jump.xml", "warly_crockpot_jump.tex")
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_crockpot_looter.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_crockpot_looter.xml", "warly_crockpot_looter.tex")

-- 厨师袋
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_spickpack_upgrade.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_spickpack_upgrade.xml", "warly_spickpack_upgrade.tex")
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_spickpack_cozy.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_spickpack_cozy.xml", "warly_spickpack_cozy.tex")

-- 亲和
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_favor_shadow.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_favor_shadow.xml", "warly_favor_shadow.tex")
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_favor_lunar.xml"))
RegisterSkilltreeIconsAtlas("images/skilltree/warly_favor_lunar.xml", "warly_favor_lunar.tex")

defs.CreateSkillTreeFor("warly", data.SKILLS)
defs.SKILLTREE_ORDERS["warly"] = data.ORDERS

-- 技能树用到的背景图
table.insert(Assets, Asset("ATLAS", "images/skilltree/warly_background.xml"))
RegisterSkilltreeBGForCharacter("images/skilltree/warly_background.xml", "warly")

