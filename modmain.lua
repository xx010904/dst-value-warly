GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})--GLOBAL 相关照抄

Assets = {
	-- Asset("ANIM", "anim/ui_beard_3x1.zip"),
   
}

PrefabFiles = {
   
	-- "shadow_lord_bunny_projectile_hit",
    -- 其他 prefab 名称...
}

RegisterInventoryItemAtlas("images/inventoryimages/shadow_beardhair.xml", "shadow_beardhair.tex")
RegisterInventoryItemAtlas("images/inventoryimages/shadow_beardhair_open.xml", "shadow_beardhair_open.tex")
RegisterInventoryItemAtlas("images/inventoryimages/lunar_torch.xml", "lunar_torch.tex")


--Make Global
local require = GLOBAL.require
local Vector3 = GLOBAL.Vector3
local net_entity = GLOBAL.net_entity


GLOBAL.global("wandavalueconfig")
if GLOBAL.wandavalueconfig == nil then GLOBAL.wandavalueconfig = {} end

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
if GetModConfigData("ClockMakerSetting") then
    modimport("scripts/clockmaker_update.lua")
end
if GetModConfigData("FarmerSetting") then
    modimport("scripts/famer_update.lua")
end
if GetModConfigData("LunarSetting") then
    modimport("scripts/lunar_update.lua")
end
if GetModConfigData("ShadowSetting") then
    modimport("scripts/shadow_update.lua")
end
modimport("scripts/skilltree_update.lua")