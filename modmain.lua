GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})--GLOBAL 相关照抄

Assets = {
	-- Asset("ANIM", "anim/ui_beard_3x1.zip"),

}

PrefabFiles = {

	"warly_bonesoup_buff",
	"warly_crepes_buff",
	"warly_potato_buff",
	"warly_seafood_buff",
	"armor_crockpot",
	"bomb_crockpot",
    -- 其他 prefab 名称...
}

RegisterInventoryItemAtlas("images/inventoryimages/shadow_beardhair.xml", "shadow_beardhair.tex")
RegisterInventoryItemAtlas("images/inventoryimages/shadow_beardhair_open.xml", "shadow_beardhair_open.tex")
RegisterInventoryItemAtlas("images/inventoryimages/lunar_torch.xml", "lunar_torch.tex")


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