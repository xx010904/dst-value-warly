local ORDERS =
{
    { "gourmet",     { -214 + 18, 176 + 30 } },
    { "chef",        { -62, 176 + 30 } },
    { "multicooker", { 66 + 18, 176 + 30 } },
    { "allegiance",  { 204, 176 + 30 } },
}

--------------------------------------------------------------------------------------------------

local function BuildSkillsData(SkillTreeFns)
    local skills =
    {
        -- =============================================================================
        -- 吃独食
        -- =============================================================================
        warly_bonesoup_buff = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_BONESOUP_BUFF_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_BONESOUP_BUFF_DESC,
            icon = "warly_bonesoup_buff",
            pos = { -216, 176 },
            group = "gourmet",
            tags = { "gourmet", "gourmet1" },
            root = true,
        },
        warly_crepes_buff = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_CREPES_BUFF_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_CREPES_BUFF_DESC,
            icon = "warly_crepes_buff",
            pos = { -216, 176 - 48 },
            group = "gourmet",
            tags = { "gourmet", "gourmet1" },
            root = true,
        },
        warly_potato_buff = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_POTATO_BUFF_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_POTATO_BUFF_DESC,
            icon = "warly_potato_buff",
            pos = { -216, 176 - 92 },
            group = "gourmet",
            tags = { "gourmet", "gourmet1" },
            root = true,
        },
        warly_seafood_buff = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_SEAFOOD_BUFF_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_SEAFOOD_BUFF_DESC,
            icon = "warly_seafood_buff",
            pos = { -216, 176 - 138 },
            group = "gourmet",
            tags = { "gourmet", "gourmet1" },
            root = true,
        },

        -- =============================================================================
        -- 分享食物
        -- =============================================================================
        warly_share_lock_1 = {
            desc = STRINGS.SKILLTREE.WARLY.WARLY_GOURMET_1_LOCK_DESC,
            pos = { -216 + 44, 176 - 20 },
            group = "gourmet",
            tags = { "gourmet", "lock" },
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountTags(prefabname, "gourmet", activatedskills) >= 2
            end,
            connects = {
                "warly_monstertartare_buff",
            },
        },
        warly_monstertartare_buff = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_MONSTERTARTARE_BUFF_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_MONSTERTARTARE_BUFF_DESC,
            icon = "warly_monstertartare_buff",
            pos = { -216 + 44, 176 - 70 },
            group = "gourmet",
            tags = { "gourmet", "gourmet1" },
            locks = { "warly_share_lock_1" },
            connects = {
                "warly_share_buff",
            },
        },
        warly_share_buff = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_SHARE_BUFF_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_SHARE_BUFF_DESC,
            icon = "warly_share_buff",
            pos = { -216 + 44, 176 - 120 },
            group = "gourmet",
            tags = { "gourmet", "gourmet1" },
        },

        -- =============================================================================
        -- 下饭操作
        -- =============================================================================
        warly_funny_cook_base = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_FUNNY_COOK_BASE_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_FUNNY_COOK_BASE_DESC,
            icon = "warly_funny_cook_base",
            pos = { -84, 176 },
            group = "chef",
            tags = { "chef", "chef1" },
            root = true,
            connects = {
                "warly_funny_cook_feast", "warly_funny_cook_memory",
            },
        },
        warly_funny_cook_feast = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_FUNNY_COOK_FEAST_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_FUNNY_COOK_FEAST_DESC,
            icon = "warly_funny_cook_feast",
            pos = { -84 + 19, 176 - 43 },
            group = "chef",
            tags = { "chef", "chef1" },
            connects = {
                "warly_funny_cook_revive",
            },
        },
        warly_funny_cook_revive = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_FUNNY_COOK_REVIVE_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_FUNNY_COOK_REVIVE_DESC,
            icon = "warly_funny_cook_revive",
            pos = { -84 + 19, 176 - 86 },
            group = "chef",
            tags = { "chef", "chef1" },
            connects = {
                "warly_funny_cook_spice",
            },
        },
        warly_funny_cook_memory = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_FUNNY_COOK_MEMORY_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_FUNNY_COOK_MEMORY_DESC,
            icon = "warly_funny_cook_memory",
            pos = { -84 - 19, 176 - 43 },
            group = "chef",
            tags = { "chef", "chef1" },
            connects = {
                "warly_funny_cook_restore",
            },
        },
        warly_funny_cook_restore = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_FUNNY_COOK_RESTORE_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_FUNNY_COOK_RESTORE_DESC,
            icon = "warly_funny_cook_restore",
            pos = { -84 - 19, 176 - 86 },
            group = "chef",
            tags = { "chef", "chef1" },
            connects = {
                "warly_funny_cook_spice",
            },
        },
        warly_funny_cook_spice = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_FUNNY_COOK_SPICE_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_FUNNY_COOK_SPICE_DESC,
            icon = "warly_funny_cook_spice",
            pos = { -84, 176 - 130 },
            group = "chef",
            tags = { "chef", "chef1" },
        },
        -- =============================================================================
        -- 画饼饼
        -- =============================================================================
        warly_sky_pie_pot = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_SKY_PIE_POT_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_SKY_PIE_POT_DESC,
            icon = "warly_sky_pie_pot",
            pos = { -20, 176 },
            group = "chef",
            tags = { "chef", "chef2" },
            root = true,
            connects = {
                "warly_sky_pie_make",
            },
            onactivate = function(inst, fromload)
                inst:AddTag("warly_sky_pie_pot")
            end,
            ondeactivate = function(inst)
                inst:RemoveTag("warly_sky_pie_pot")
            end,
        },
        warly_sky_pie_make = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_SKY_PIE_MAKE_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_SKY_PIE_MAKE_DESC,
            icon = "warly_sky_pie_make",
            pos = { -20, 176 - 43 },
            group = "chef",
            tags = { "chef", "chef2" },
            connects = {
                "warly_sky_pie_baked",
            },
        },
        warly_sky_pie_baked = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_SKY_PIE_BAKED_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_SKY_PIE_BAKED_DESC,
            icon = "warly_sky_pie_baked",
            pos = { -20, 176 - 86 },
            group = "chef",
            tags = { "chef", "chef2" },
            connects = {
                "warly_sky_pie_favorite",
            },
        },
        warly_sky_pie_favorite = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_SKY_PIE_FAVORITE_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_SKY_PIE_FAVORITE_DESC,
            icon = "warly_sky_pie_favorite",
            pos = { -20, 176 - 130 },
            group = "chef",
            tags = { "chef", "chef2" },
        },

        -- =============================================================================
        -- 背锅锅
        -- =============================================================================
        warly_crockpot_make = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_CROCKPOT_MAKE_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_CROCKPOT_MAKE_DESC,
            icon = "warly_crockpot_make",
            pos = { 60, 176 },
            group = "multicooker",
            tags = { "multicooker", "multicooker1" },
            root = true,
            connects = {
                "warly_crockpot_transfer",
            },
        },
        warly_crockpot_transfer = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_CROCKPOT_TRANSFER_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_CROCKPOT_TRANSFER_DESC,
            icon = "warly_crockpot_transfer",
            pos = { 60, 176 - 48 },
            group = "multicooker",
            tags = { "multicooker", "multicooker1" },
            connects = {
                "warly_crockpot_scapegoat",
                "warly_crockpot_flung",
            },
        },
        warly_crockpot_flung = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_CROCKPOT_FLUNG_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_CROCKPOT_FLUNG_DESC,
            icon = "warly_crockpot_flung",
            pos = { 60, 176 - 92 - 16 },
            group = "multicooker",
            tags = { "multicooker", "multicooker1" },
            connects = {
                "warly_crockpot_jump",
            },
        },
        warly_crockpot_jump = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_CROCKPOT_JUMP_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_CROCKPOT_JUMP_DESC,
            icon = "warly_crockpot_jump",
            pos = { 60, 176 - 138 - 16 },
            group = "multicooker",
            tags = { "multicooker", "multicooker1" },
        },
        warly_crockpot_scapegoat = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_CROCKPOT_SCAPEGOAT_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_CROCKPOT_SCAPEGOAT_DESC,
            icon = "warly_crockpot_scapegoat",
            pos = { 60 + 48, 176 - 92 - 16 },
            group = "multicooker",
            tags = { "multicooker", "multicooker1" },
            connects = {
                "warly_crockpot_looter",
            },
        },
        warly_crockpot_looter = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_CROCKPOT_LOOTER_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_CROCKPOT_LOOTER_DESC,
            icon = "warly_crockpot_looter",
            pos = { 60 + 48, 176 - 138 - 16 },
            group = "multicooker",
            tags = { "multicooker", "multicooker1" },
        },
        -- =============================================================================
        -- 改造厨师袋
        -- =============================================================================
        warly_spickpack_upgrade = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_SPICKPACK_UPGRADE_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_SPICKPACK_UPGRADE_DESC,
            icon = "warly_spickpack_upgrade",
            pos = { 60 + 48, 176 },
            group = "multicooker",
            tags = { "multicooker", "multicooker2" },
            root = true,
            connects = {
                "warly_spickpack_cozy",
            },
            onactivate = function(inst, fromload)
                inst:AddTag("warly_spickpack_upgrade")
            end,
            ondeactivate = function(inst)
                inst:RemoveTag("warly_spickpack_upgrade")
            end,
        },
        warly_spickpack_cozy = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_SPICKPACK_COZY_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_SPICKPACK_COZY_DESC,
            icon = "warly_spickpack_cozy",
            pos = { 60 + 48, 176 - 48 },
            group = "multicooker",
            tags = { "multicooker", "multicooker2" },
        },

        -- =============================================================================
        -- 亲和
        -- =============================================================================
        warly_allegiance_lock_1 = {
            desc = STRINGS.SKILLTREE.WARLY.WARLY_ALLEGIANCE_LOCK_1_DESC,
            pos = { 204 + 2, 176 },
            group = "allegiance",
            tags = { "allegiance", "lock" },
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountSkills(prefabname, activatedskills) >= 12
            end,
            connects = {
                "warly_allegiance_shadow",
            },
        },

        warly_allegiance_lock_2 = {
            desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_2_DESC,
            pos = { 204 - 22 + 2, 176 - 50 + 2 },
            group = "allegiance",
            tags = { "allegiance", "lock" },
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                if readonly then
                    return "question"
                end
                return TheGenericKV:GetKV("fuelweaver_killed") == "1"
            end,
            connects = {
                "warly_allegiance_shadow",
            },
        },

        warly_allegiance_lock_4 = {
            desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_4_DESC,
            pos = { 204 - 22 + 2, 176 - 100 + 8 },
            group = "allegiance",
            tags = { "allegiance", "lock" },
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                if SkillTreeFns.CountTags(prefabname, "lunar_favor", activatedskills) == 0 then
                    return true
                end
                return nil
            end,
            connects = {
                "warly_allegiance_shadow",
            },
        },

        warly_allegiance_shadow = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_ALLEGIANCE_SHADOW_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_ALLEGIANCE_SHADOW_DESC,
            icon = "warly_favor_shadow",
            pos = { 204 - 22 + 2, 176 - 110 - 38 + 10 },
            group = "allegiance",
            tags = { "allegiance", "shadow", "shadow_favor" },
            locks = { "warly_allegiance_lock_1", "warly_allegiance_lock_2", "warly_allegiance_lock_4" },
            onactivate = function(inst, fromload)
                inst:AddTag("warly_allegiance_shadow")
                inst:AddTag("player_shadow_aligned")
                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:AddResist("shadow_aligned", inst, TUNING.SKILLS.WARLY_ALLEGIANCE_SHADOW_RESIST,
                        "warly_allegiance_shadow")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.SKILLS.WARLY_ALLEGIANCE_VS_LUNAR_BONUS,
                        "warly_allegiance_shadow")
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("warly_allegiance_shadow")
                inst:RemoveTag("player_shadow_aligned")
                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:RemoveResist("shadow_aligned", inst, "warly_allegiance_shadow")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:RemoveBonus("lunar_aligned", inst, "warly_allegiance_shadow")
                end
            end,
        },

        warly_allegiance_lock_3 = {
            desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_3_DESC,
            pos = { 204 + 22 + 2, 176 - 50 + 2 },
            group = "allegiance",
            tags = { "allegiance", "lock" },
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                if readonly then
                    return "question"
                end
                return TheGenericKV:GetKV("celestialchampion_killed") == "1"
            end,
            connects = {
                "warly_allegiance_lunar",
            },
        },

        warly_allegiance_lock_5 = {
            desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_5_DESC,
            pos = { 204 + 22 + 2, 176 - 100 + 8 },
            group = "allegiance",
            tags = { "allegiance", "lock" },
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                if SkillTreeFns.CountTags(prefabname, "shadow_favor", activatedskills) == 0 then
                    return true
                end
                return nil
            end,
            connects = {
                "warly_allegiance_lunar",
            },
        },

        warly_allegiance_lunar = {
            title = STRINGS.SKILLTREE.WARLY.WARLY_ALLEGIANCE_LUNAR_TITLE,
            desc = STRINGS.SKILLTREE.WARLY.WARLY_ALLEGIANCE_LUNAR_DESC,
            icon = "warly_favor_lunar",
            pos = { 204 + 22 + 2, 176 - 110 - 38 + 10 },
            group = "allegiance",
            tags = { "allegiance", "lunar", "lunar_favor" },
            locks = { "warly_allegiance_lock_1", "warly_allegiance_lock_3", "warly_allegiance_lock_5" },
            onactivate = function(inst, fromload)
                inst:AddTag("player_lunar_aligned")
                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:AddResist("lunar_aligned", inst, TUNING.SKILLS.WARLY_ALLEGIANCE_LUNAR_RESIST,
                        "warly_allegiance_lunar")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.SKILLS.WARLY_ALLEGIANCE_VS_SHADOW_BONUS,
                        "warly_allegiance_lunar")
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("player_lunar_aligned")
                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:RemoveResist("lunar_aligned", inst, "warly_allegiance_lunar")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:RemoveBonus("shadow_aligned", inst, "warly_allegiance_lunar")
                end
            end,
        }
    }

    return {
        SKILLS = skills,
        ORDERS = ORDERS,
    }
end



--------------------------------------------------------------------------------------------------

return BuildSkillsData
