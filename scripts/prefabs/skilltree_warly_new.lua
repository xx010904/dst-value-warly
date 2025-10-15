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
            title = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_1_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_1_DESC,
            icon = "warly_bonesoup_buff",
            pos = { -216, 176 },
            --pos = {0,0},
            group = "gourmet",
            tags = { "gourmet", "gourmet1" },
            root = true,
        },
        warly_crepes_buff = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_2_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_2_DESC,
            icon = "warly_crepes_buff",
            pos = { -216, 176 - 48 },
            --pos = {0,-1},
            group = "gourmet",
            tags = { "gourmet", "gourmet1" },
            root = true,
        },
        warly_potato_buff = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_3_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_3_DESC,
            icon = "warly_potato_buff",
            pos = { -216, 176 - 92 },
            --pos = {0,-2},
            group = "gourmet",
            tags = { "gourmet", "gourmet1" },
            root = true,
        },
        warly_seafood_buff = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_4_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_4_DESC,
            icon = "warly_seafood_buff",
            pos = { -216, 176 - 138 },
            --pos = {1,0},
            group = "gourmet",
            tags = { "gourmet", "gourmet1" },
            root = true,
        },
        -- =============================================================================
        -- 分享食物
        -- =============================================================================
        warly_share_lock_1 = {
            desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_4_DESC,
            pos = { -216 + 44, 176 - 20 },
            --pos = {0,-1},
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
            title = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_5_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_5_DESC,
            icon = "warly_monstertartare_buff",
            pos = { -216 + 44, 176 - 70 },
            --pos = {1,-1},
            group = "gourmet",
            tags = { "gourmet", "gourmet1" },
            locks = { "warly_share_lock_1" },
            connects = {
                "warly_share_buff",
            },
        },
        warly_share_buff = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_6_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_6_DESC,
            icon = "wilson_torch_brightness_3",
            pos = { -216 + 44, 176 - 120 },
            --pos = {1,-2},
            group = "gourmet",
            tags = { "gourmet", "gourmet1" },
        },

        -- =============================================================================
        -- 下饭操作
        -- =============================================================================
        warly_funny_cook_base = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_1_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_1_DESC,
            icon = "warly_bonesoup_buff",
            pos = { -84, 176 },
            group = "chef",
            tags = { "chef", "chef1" },
            root = true,
            connects = {
                "warly_funny_cook_team_1", "warly_funny_cook_individual_1",
            },
        },
        warly_funny_cook_team_1 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_GEM_1_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_GEM_1_DESC,
            icon = "warly_crepes_buff",
            pos = { -84 + 19, 176 - 43 },
            group = "chef",
            tags = { "chef", "chef1" },
            connects = {
                "warly_funny_cook_team_2",
            },
        },
        warly_funny_cook_team_2 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_GEM_2_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_GEM_2_DESC,
            icon = "wilson_alchemy_gem_3",
            pos = { -84 + 19, 176 - 86 },
            group = "chef",
            tags = { "chef", "chef1" },
            connects = {
                "warly_funny_cook_spice",
            },
        },
        warly_funny_cook_individual_1 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_ORE_1_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_ORE_1_DESC,
            icon = "wilson_alchemy_ore_2",
            pos = { -84 - 19, 176 - 43 },
            group = "chef",
            tags = { "chef", "chef1" },
            connects = {
                "warly_funny_cook_individual_2",
            },
        },
        warly_funny_cook_individual_2 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_ORE_2_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_ORE_2_DESC,
            icon = "wilson_alchemy_ore_3",
            pos = { -84 - 19, 176 - 86 },
            group = "chef",
            tags = { "chef", "chef1" },
            connects = {
                "warly_funny_cook_spice",
            },
        },
        warly_funny_cook_spice = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_IKY_1_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_IKY_1_DESC,
            icon = "wilson_alchemy_iky_2",
            pos = { -84, 176 - 130 },
            --pos = {2,-1},
            group = "chef",
            tags = { "chef", "chef1" },
        },
        -- =============================================================================
        -- 画饼饼
        -- =============================================================================
        warly_sky_pie_pot = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_IKY_2_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_IKY_2_DESC,
            icon = "wilson_alchemy_iky_3",
            pos = { -20, 176 },
            group = "chef",
            tags = { "chef", "chef2" },
            root = true,
            connects = {
                "warly_sky_pie_make",
            },
        },
        warly_sky_pie_make = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_IKY_2_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_IKY_2_DESC,
            icon = "wilson_alchemy_iky_3",
            pos = { -20, 176 - 43 },
            group = "chef",
            tags = { "chef", "chef2" },
            connects = {
                "warly_sky_pie_shoot",
            },
        },
        warly_sky_pie_shoot = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_IKY_2_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_IKY_2_DESC,
            icon = "wilson_alchemy_iky_3",
            pos = { -20, 176 - 86 },
            group = "chef",
            tags = { "chef", "chef2" },
            connects = {
                "warly_sky_pie_favorite",
            },
        },
        warly_sky_pie_favorite = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_IKY_2_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_IKY_2_DESC,
            icon = "wilson_alchemy_iky_3",
            pos = { -20, 176 - 130 },
            group = "chef",
            tags = { "chef", "chef2" },
            onactivate = function(inst, fromload)

            end,
        },

        -- =============================================================================
        -- 背锅锅 + 改造背包
        -- =============================================================================
        warly_crockpot_make = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_1_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_1_DESC,
            icon = "wilson_beard_insulation_1",
            pos = { 60, 176 },
            group = "multicooker",
            tags = { "multicooker", "multicooker1" },
            root = true,
            connects = {
                "warly_crockpot_transfer",
                "warly_spice_sack_upgrade",
            },
        },
        warly_crockpot_transfer = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_2_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_2_DESC,
            icon = "wilson_beard_insulation_2",
            pos = { 60, 176 - 48 },
            group = "multicooker",
            tags = { "multicooker", "multicooker1" },
            connects = {
                "warly_crockpot_team_1",
                "warly_crockpot_individual_1",
            },
        },
        warly_crockpot_team_1 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_3_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_3_DESC,
            icon = "wilson_beard_insulation_3",
            pos = { 60, 176 - 92 },
            group = "multicooker",
            tags = { "multicooker", "multicooker1" },
            connects = {
                "warly_crockpot_team_2",
            },
        },
        warly_crockpot_team_2 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_4_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_4_DESC,
            icon = "wilson_beard_speed_1",
            pos = { 60, 176 - 138 },
            group = "multicooker",
            tags = { "multicooker", "multicooker1" },
        },
        warly_crockpot_individual_1 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_5_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_5_DESC,
            icon = "wilson_beard_speed_2",
            pos = { 60 + 48, 176 - 92 },
            group = "multicooker",
            tags = { "multicooker", "multicooker1" },
            connects = {
                "warly_crockpot_individual_2",
            },
        },
        warly_crockpot_individual_2 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_6_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_6_DESC,
            icon = "wilson_beard_speed_3",
            pos = { 60 + 48, 176 - 138 },
            group = "multicooker",
            tags = { "multicooker", "multicooker1" },
        },
        -- =============================================================================
        -- 改造背包
        -- =============================================================================
        warly_spice_sack_upgrade = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_2_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_2_DESC,
            icon = "wilson_beard_insulation_2",
            pos = { 60 + 48, 176 },
            group = "multicooker",
            tags = { "multicooker", "multicooker2" },
            connects = {
                "warly_spice_sack_cozy",
            },
        },
        warly_spice_sack_cozy = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_2_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_2_DESC,
            icon = "wilson_beard_insulation_2",
            pos = { 60 + 48, 176 - 48 },
            group = "multicooker",
            tags = { "multicooker", "multicooker2" },
        },

        -- =============================================================================
        -- 亲和
        -- =============================================================================
        wilson_allegiance_lock_1 = {
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALLEGIANCE_LOCK_1_DESC,
            pos = { 204, 176 },
            --pos = {0.5,0},
            group = "allegiance",
            tags = { "allegiance", "lock" },
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountSkills(prefabname, activatedskills) >= 12
            end,
            connects = {
                "wilson_allegiance_shadow",
            },
        },

        wilson_allegiance_lock_shadow = {
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALLEGIANCE_LOCK_SHADOW_DESC,
            pos = { 204 - 22, 176 - 50 + 2 },
            --pos = {0,-1},
            group = "allegiance",
            tags = { "allegiance", "lock" },
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                local lunar_skills = SkillTreeFns.CountTags(prefabname, "lunar_favor", activatedskills)
                if lunar_skills > 0 then
                    return false
                end

                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("fuelweaver_killed") == "1"
            end,
            connects = {
                "wilson_allegiance_shadow",
            },
        },

        wilson_allegiance_shadow = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALLEGIANCE_SHADOW_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALLEGIANCE_SHADOW_DESC,
            icon = "wilson_favor_shadow",
            pos = { 204 - 22, 176 - 100 + 8 },
            -- pos = {204-22 ,176-110-38+10},  --  -22
            --pos = {0,-2},
            group = "allegiance",
            tags = { "allegiance", "shadow", "shadow_favor" },
            locks = { "wilson_allegiance_lock_1", "wilson_allegiance_lock_shadow" }, ----解锁了就图标发亮，但是还要判断connects
            onactivate = function(inst, fromload)
                inst:AddTag("player_shadow_aligned")
                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:AddResist("shadow_aligned", inst, TUNING.SKILLS.WILSON_ALLEGIANCE_SHADOW_RESIST,
                        "wilson_allegiance_shadow")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.SKILLS.WILSON_ALLEGIANCE_VS_LUNAR_BONUS,
                        "wilson_allegiance_shadow")
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("player_shadow_aligned")
                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:RemoveResist("shadow_aligned", inst, "wilson_allegiance_shadow")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:RemoveBonus("lunar_aligned", inst, "wilson_allegiance_shadow")
                end
            end,
            connects = {
                "wilson_allegiance_shadow_beard",
            },
        },

        wilson_allegiance_shadow_beard = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALLEGIANCE_SHADOW_BEARD_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALLEGIANCE_SHADOW_BEARD_DESC,
            icon = "wilson_allegiance_shadow_beard",
            -- pos = {204-22,176-100+8},
            pos = { 204 - 22, 176 - 110 - 38 + 10 }, --  -22
            --pos = {0,-2},
            group = "allegiance",
            tags = { "allegiance", "shadow", "shadow_favor" },
            onactivate = function(inst, fromload)
                inst:AddTag(UPGRADETYPES.BEARD_HAIR .. "_upgradeuser")
                inst:AddTag(SPELLTYPES.WURT_SHADOW .. "_spelluser") ----官方写死了纯粹恐惧只能是小鱼人tag使用
                inst:AddTag("beard_master")
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag(UPGRADETYPES.BEARD_HAIR .. "_upgradeuser")
                inst:RemoveTag(SPELLTYPES.WURT_SHADOW .. "_spelluser")
                inst:RemoveTag("beard_master")
            end,
        },

        wilson_allegiance_lock_lunar = {
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALLEGIANCE_LOCK_LUNAR_DESC,
            pos = { 204 + 22, 176 - 50 + 2 },
            --pos = {0,-1},
            group = "allegiance",
            tags = { "allegiance", "lock" },
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                local shadow_skills = SkillTreeFns.CountTags(prefabname, "shadow_favor", activatedskills)
                if shadow_skills > 0 then
                    return false
                end

                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("celestialchampion_killed") == "1"
            end,
            connects = {
                "wilson_allegiance_lunar",
            },
        },

        wilson_allegiance_lunar = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALLEGIANCE_LUNAR_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALLEGIANCE_LUNAR_DESC,
            icon = "wilson_favor_lunar",
            pos = { 204 + 22, 176 - 100 + 8 },
            -- pos = {204+22 ,176-110-38+10},
            --pos = {0,-2},
            group = "allegiance",
            tags = { "allegiance", "lunar", "lunar_favor" },
            locks = { "wilson_allegiance_lock_1", "wilson_allegiance_lock_lunar" },
            onactivate = function(inst, fromload)
                inst:AddTag("player_lunar_aligned")
                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:AddResist("lunar_aligned", inst, TUNING.SKILLS.WILSON_ALLEGIANCE_LUNAR_RESIST,
                        "wilson_allegiance_lunar")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.SKILLS.WILSON_ALLEGIANCE_VS_SHADOW_BONUS,
                        "wilson_allegiance_lunar")
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("player_lunar_aligned")
                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:RemoveResist("lunar_aligned", inst, "wilson_allegiance_lunar")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:RemoveBonus("shadow_aligned", inst, "wilson_allegiance_lunar")
                end
            end,
            connects = {
                "wilson_allegiance_lunar_torch",
            },
        },

        wilson_allegiance_lunar_torch = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALLEGIANCE_LUNAR_TORCH_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALLEGIANCE_LUNAR_TORCH_DESC,
            icon = "wilson_allegiance_lunar_torch",
            -- pos = {204+22,176-100+8},
            pos = { 204 + 22, 176 - 110 - 38 + 10 },
            --pos = {0,-2},
            group = "allegiance",
            tags = { "allegiance", "lunar", "lunar_favor" },
            onactivate = function(inst, fromload)
                inst:AddTag(UPGRADETYPES.TORCH .. "_upgradeuser")
                inst:AddTag(UPGRADETYPES.LUNAR_TORCH .. "_upgradeuser")
                inst:AddTag(SPELLTYPES.WURT_LUNAR .. "_spelluser") ----官方写死了纯粹辉煌只能是小鱼人tag使用
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag(UPGRADETYPES.TORCH .. "_upgradeuser")
                inst:RemoveTag(UPGRADETYPES.LUNAR_TORCH .. "_upgradeuser")
                inst:RemoveTag(SPELLTYPES.WURT_LUNAR .. "_spelluser")
            end,
        },
    }

    return {
        SKILLS = skills,
        ORDERS = ORDERS,
    }
end



--------------------------------------------------------------------------------------------------

return BuildSkillsData
