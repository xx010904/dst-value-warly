GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})--GLOBAL 相关照抄

Assets = {
    Asset("ANIM", "anim/armor_crockpot.zip"),
    Asset("ANIM", "anim/warly_question_mark.zip"),
    Asset("ANIM", "anim/warly_sky_pie.zip"),
    Asset("ANIM", "anim/warly_sky_pie_inspire_buff.zip"),
    Asset("ANIM", "anim/warly_sky_pie_baked.zip"),
    Asset("ANIM", "anim/warly_sky_pie_boomerang.zip"),
	-- Asset("ANIM", "anim/ui_beard_3x1.zip"),
    Asset("IMAGE", "images/inventoryimages/armor_crockpot.tex"),
	Asset("ATLAS", "images/inventoryimages/armor_crockpot.xml"),
    Asset("IMAGE", "images/inventoryimages/shadow_battleaxe_young.tex"),
	Asset("ATLAS", "images/inventoryimages/shadow_battleaxe_young.xml"),
    Asset("IMAGE", "images/inventoryimages/warly_sky_pie.tex"),
	Asset("ATLAS", "images/inventoryimages/warly_sky_pie.xml"),
    Asset("IMAGE", "images/inventoryimages/warly_sky_pie_baked.tex"),
	Asset("ATLAS", "images/inventoryimages/warly_sky_pie_baked.xml"),
    Asset("IMAGE", "images/inventoryimages/warly_sky_pie_boomerang.tex"),
	Asset("ATLAS", "images/inventoryimages/warly_sky_pie_boomerang.xml"),
    Asset("IMAGE", "images/inventoryimages/portablecookpot_item_actived.tex"),
	Asset("ATLAS", "images/inventoryimages/portablecookpot_item_actived.xml"),
}

PrefabFiles = {

	"warly_bonesoup_buff",
	"warly_crepes_buff",
	"warly_potato_buff",
	"warly_seafood_buff",
	"armor_crockpot",
	"bomb_crockpot",
	"shadow_hook_head_fx",
	"shadow_hook_link_fx",
	"shadow_hook_debuff",
	"shadow_battleaxe_young",
	"improv_cookpot_fx",
	"improv_cookpot_projectile_fx",
	"improv_question_mark_fx",
	"warly_sky_pie",
	"warly_sky_pie_baked",
	"warly_sky_pie_buff",
	"warly_sky_pie_inspire_buff",
	"warly_sky_pie_cook_fx",
	"warly_sky_pie_boomerang",
	"spice_sack",
    -- 其他 prefab 名称...
}

RegisterInventoryItemAtlas("images/inventoryimages/armor_crockpot.xml", "armor_crockpot.tex")
RegisterInventoryItemAtlas("images/inventoryimages/shadow_battleaxe_young.xml", "shadow_battleaxe_young.tex")
RegisterInventoryItemAtlas("images/inventoryimages/warly_sky_pie.xml", "warly_sky_pie.tex")
RegisterInventoryItemAtlas("images/inventoryimages/portablecookpot_item_actived.xml", "portablecookpot_item_actived.tex")


--Make Global
local require = GLOBAL.require
local Vector3 = GLOBAL.Vector3
local net_entity = GLOBAL.net_entity


GLOBAL.global("warlyvalueconfig")
if GLOBAL.warlyvalueconfig == nil then GLOBAL.warlyvalueconfig = {} end

-- 本地化
local lan = (_G.LanguageTranslator.defaultlang == "zh") and "zh" or "en"
if GetModConfigData("LanguageSetting") == "default" then
    if lan == "zh" then
        modimport("languages/chs")
    else
        modimport("languages/en")
    end
elseif GetModConfigData("LanguageSetting") == "chinese" then
    modimport("languages/chs")
elseif GetModConfigData("LanguageSetting") == "english" then
    modimport("languages/en")
end

-- 这将执行 xxx.lua 中的所有代码
local function import_if_enabled(config_key, script_path)
    if GetModConfigData(config_key) then
        modimport(script_path)
    end
end
import_if_enabled("lonely_eater_switch",     "scripts/lonely_eater_update.lua")
import_if_enabled("funny_cooker_switch",     "scripts/funny_cooker_update.lua")
import_if_enabled("crockpot_carrier_switch", "scripts/crockpot_carrier_update.lua")
import_if_enabled("lunar_switch",            "scripts/lunar_update.lua")
import_if_enabled("shadow_switch",           "scripts/shadow_update.lua")

-- 技能树
modimport("scripts/skilltree_update.lua")