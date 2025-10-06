local ORDERS =
{
    {"eatalone",           { -214+18   , 176 + 30 }},
    {"clockmaker",         { -62       , 176 + 30 }},
    {"farmer",           { 66+18     , 176 + 30 }},
    {"allegiance",      { 204       , 176 + 30 }},
}

--------------------------------------------------------------------------------------------------

local function BuildSkillsData(SkillTreeFns)
    local skills = 
    {
        warly_bonesoup_buff = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_1_TITLE, 
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_1_DESC, 
            icon = "warly_bonesoup_buff",
            pos = {-63,176},
            --pos = {1,0},
            group = "eatalone",
            tags = {"eatalone", "eatalone1"},
            root = true,
        },
        warly_crepes_buff = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_GEM_1_TITLE, 
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_GEM_1_DESC, 
            icon = "warly_crepes_buff",
            pos = {-63,176-54},        
            --pos = {0,-1},
            group = "eatalone",
            tags = {"eatalone", "eatalone1"},
        },
        wilson_alchemy_gem_2 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_GEM_2_TITLE, 
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_GEM_2_DESC, 
            icon = "wilson_alchemy_gem_3",
            pos = {-63,176-54-38},        
            --pos = {0,-2},
            group = "horrorgranny",
            tags = {"alchemy", "alchemy1"},
        },

        wilson_alchemy_ore_1 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_ORE_1_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_ORE_1_DESC,
            icon = "wilson_alchemy_ore_2",
            pos = {-63-38,176-54},
            --pos = {1,-1},
            group = "horrorgranny",
            tags = {"alchemy", "alchemy1"},
            connects = {
                "wilson_alchemy_ore_2",
            },
        },
        wilson_alchemy_ore_2 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_ORE_2_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_ORE_2_DESC,
            icon = "wilson_alchemy_ore_3",
            pos = {-63-38,176-54-38},
            --pos = {1,-2},
            group = "horrorgranny",
            tags = {"alchemy", "alchemy1"},
        },

        wilson_alchemy_iky_1 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_IKY_1_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_IKY_1_DESC,
            icon = "wilson_alchemy_iky_2",
            pos = {-63+38,176-54},
            --pos = {2,-1},
            group = "horrorgranny",
            tags = {"alchemy", "alchemy1"},
            connects = {
                "wilson_alchemy_iky_2",
            },
        },
        wilson_alchemy_iky_2 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_IKY_2_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_IKY_2_DESC,
            icon = "wilson_alchemy_iky_3",
            pos = {-63+38,176-54-38},
            --pos = {2,-2},
            group = "horrorgranny",
            tags = {"alchemy", "alchemy1"},
        },
        ---- Uncompromising Mode
        wilson_alchemy_4 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_IKY_2_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_IKY_2_DESC,
            icon = "wilson_alchemy_iky_3",
            -- pos = {-63+38,176-54-38},
            pos = {3333333,333333},
            group = "horrorgranny",
            tags = {"alchemy", "alchemy1"},
        },
        wilson_alchemy_lock_1 = {
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_1_LOCK_DESC,
            pos = {-63-18,176-54-38-50},
            --pos = {2,0},
            group = "horrorgranny",
            tags = {"alchemy","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountTags(prefabname, "alchemy1", activatedskills) > 4
            end,
            connects = {
                "wilson_alchemy_reverse_1",
            },
        },
        wilson_alchemy_reverse_1 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_REVERSE_1_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_REVERSE_1_DESC,
            icon = "wilson_alchemy_reverse_1",
            pos = {-63+20,176-54-38-50},
            --pos = {1,0},
            group = "horrorgranny",
            tags = {"alchemy"},
            onactivate = function(inst, fromload)
                        wilsonvalueconfig.UpdateReverseRecipes()
                        inst:AddTag("alchemyreverser")
                    end,
        },

        wilson_torch_1 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_1_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_1_DESC,
            icon = "wilson_torch_time_1",
            pos = {-214,176},
            --pos = {0,0},
            group = "clockmaker",
            tags = {"torch", "torch1"},
            root = true,
            connects = {
                "wilson_torch_2",
            },
        },
        wilson_torch_2 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_2_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_2_DESC,
            icon = "wilson_torch_time_2",
            pos = {-214,176-38},
            --pos = {0,-1},
            group = "clockmaker",
            tags = {"torch", "torch1"},
            connects = {
                "wilson_torch_3",
            },
        },
        wilson_torch_3 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_3_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_3_DESC,
            icon = "wilson_torch_time_3",
            pos = {-214,176-38-38},
            --pos = {0,-2},
            group = "clockmaker",
            tags = {"torch", "torch1"},
        },
        wilson_torch_4 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_4_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_4_DESC,
            icon = "wilson_torch_brightness_1",
            pos = {-214+38,176},        
            --pos = {1,0},
            group = "clockmaker",
            tags = {"torch", "torch1"},
            root = true,
            connects = {
                "wilson_torch_5",
            },
            defaultfocus = true,
        },
        wilson_torch_5 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_5_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_5_DESC,
            icon = "wilson_torch_brightness_2",
            pos = {-214+38,176-38},
            --pos = {1,-1},
            group = "clockmaker",
            tags = {"torch", "torch1"},
            connects = {
                "wilson_torch_6",
            },
        },
        wilson_torch_6 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_6_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_6_DESC,
            icon = "wilson_torch_brightness_3",
            pos = {-214+38,176-38-38},
            --pos = {1,-2},
            group = "clockmaker",
            tags = {"torch", "torch1"},
        }, 

        wilson_torch_lock_1 = {
            desc = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_1_LOCK_DESC,
            pos = {-214+18,58},
            --pos = {2,0},
            group = "clockmaker",
            tags = {"torch","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountTags(prefabname, "torch1", activatedskills) > 2
            end,
            connects = {
                "wilson_torch_7",
            },
        },
        wilson_torch_7 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_7_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_7_DESC,
            icon = "wilson_torch_throw",
            pos = {-214+18,58-38},        
            --pos = {2,-1},
            group = "clockmaker",
            tags = {"torch"},
        },    

        wilson_beard_1 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_1_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_1_DESC,
            icon = "wilson_beard_insulation_1",        
            pos = {64,176},
            --pos = {0,0},
            group = "farmer",
            tags = {"beard", "beard1"},
            root = true,
            connects = {
                "wilson_beard_2",
            },
        },
        wilson_beard_2 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_2_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_2_DESC,
            icon = "wilson_beard_insulation_2",
            pos = {64,176-38},
            --pos = {0,-1},
            group = "farmer",
            tags = {"beard", "beard1"},
            connects = {
                "wilson_beard_3",
            },
        },
        wilson_beard_3 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_3_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_3_DESC,
            icon = "wilson_beard_insulation_3",
            pos = {64,176-38-38},
            --pos = {0,-2},
            group = "farmer",
            tags = {"beard", "beard1"},
        },

        wilson_beard_4 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_4_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_4_DESC,
            icon = "wilson_beard_speed_1",
            pos = {64+38,176},
            --pos = {1,0},
            group = "farmer",
            tags = {"beard", "beard1"},
            root = true,
            connects = {
                "wilson_beard_5",
            },
        },
        wilson_beard_5 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_5_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_5_DESC,
            icon = "wilson_beard_speed_2",
            pos = {64+38,176-38},
            --pos = {1,-1},
            group = "farmer",
            tags = {"beard", "beard1"},
            connects = {
                "wilson_beard_6",
            },
        },
        wilson_beard_6 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_6_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_6_DESC,
            icon = "wilson_beard_speed_3",
            pos = {64+38,176-38-38},
            --pos = {1,-2},
            group = "farmer",
            tags = {"beard", "beard1"},
        },

        wilson_beard_lock_1 = {
            desc = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_1_LOCK_DESC,
            pos = {64+18,58},
            --pos = {2,0},
            group = "farmer",
            tags = {"beard","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountTags(prefabname, "beard1", activatedskills) > 2
            end,
            connects = {
                "wilson_beard_7",
            },
        },
        wilson_beard_7 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_7_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_7_DESC,
            icon = "wilson_beard_inventory",
            pos = {64+18,58-38},
            --pos = {2,-1},
            onactivate = function(inst, fromload)
                    -- print("wilson_beard_7 onactivate")
                    if inst.components.beard then
                        inst.components.beard:UpdateBeardInventory()
                    end
                end,
            group = "farmer",
            tags = {"beard"},
        },

-- 兼容一些双修解锁的mod
        wilson_allegiance_lock_5 = {
            desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_5_DESC,
            pos = {333333,333333},  
            --pos = {0,-1},
            group = "allegiance",
            tags = {"allegiance","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                if SkillTreeFns.CountTags(prefabname, "shadow_favor", activatedskills) == 0 then
                    return true
                end
    
                return nil -- Important to return nil and not false.
            end,
            connects = {
                "wilson_allegiance_lunar",
            },
        },
        wilson_allegiance_lock_4 = {
            desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_4_DESC,
            pos = {333333,333333},  
            --pos = {0,-1},
            group = "allegiance",
            tags = {"allegiance","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                if SkillTreeFns.CountTags(prefabname, "lunar_favor", activatedskills) == 0 then
                    return true
                end
    
                return nil -- Important to return nil and not false.
            end,
            connects = {
                "wilson_allegiance_shadow",
            },
        },    
-- 兼容一些双修解锁的mod

        wilson_allegiance_lock_1 = {
           desc = STRINGS.SKILLTREE.WILSON.WILSON_ALLEGIANCE_LOCK_1_DESC,
            pos = {204,176},
            --pos = {0.5,0},
            group = "allegiance",
            tags = {"allegiance","lock"},
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
            pos = {204-22,176-50+2},  
            --pos = {0,-1},
            group = "allegiance",
            tags = {"allegiance","lock"},
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
            pos = {204-22,176-100+8},  
            -- pos = {204-22 ,176-110-38+10},  --  -22
            --pos = {0,-2},
            group = "allegiance",
            tags = {"allegiance","shadow","shadow_favor"},
            locks = {"wilson_allegiance_lock_1", "wilson_allegiance_lock_shadow"}, ----解锁了就图标发亮，但是还要判断connects
            onactivate = function(inst, fromload)
                inst:AddTag("player_shadow_aligned")
                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:AddResist("shadow_aligned", inst, TUNING.SKILLS.WILSON_ALLEGIANCE_SHADOW_RESIST, "wilson_allegiance_shadow")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.SKILLS.WILSON_ALLEGIANCE_VS_LUNAR_BONUS, "wilson_allegiance_shadow")
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
            pos = {204-22 ,176-110-38+10},  --  -22
            --pos = {0,-2},
            group = "allegiance",
            tags = {"allegiance","shadow","shadow_favor"},
            onactivate = function(inst, fromload)
                inst:AddTag(UPGRADETYPES.BEARD_HAIR.."_upgradeuser")
                inst:AddTag(SPELLTYPES.WURT_SHADOW.."_spelluser") ----官方写死了纯粹恐惧只能是小鱼人tag使用
                inst:AddTag("beard_master")
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag(UPGRADETYPES.BEARD_HAIR.."_upgradeuser")
                inst:RemoveTag(SPELLTYPES.WURT_SHADOW.."_spelluser")
                inst:RemoveTag("beard_master")
            end,
        },

        wilson_allegiance_lock_lunar = {
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALLEGIANCE_LOCK_LUNAR_DESC,
            pos = {204+22,176-50+2},
            --pos = {0,-1},
            group = "allegiance",
            tags = {"allegiance","lock"},
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
            pos = {204+22,176-100+8},
            -- pos = {204+22 ,176-110-38+10},
            --pos = {0,-2},
            group = "allegiance",
            tags = {"allegiance","lunar","lunar_favor"},
            locks = {"wilson_allegiance_lock_1", "wilson_allegiance_lock_lunar"},
            onactivate = function(inst, fromload)
                inst:AddTag("player_lunar_aligned")
                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:AddResist("lunar_aligned", inst, TUNING.SKILLS.WILSON_ALLEGIANCE_LUNAR_RESIST, "wilson_allegiance_lunar")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.SKILLS.WILSON_ALLEGIANCE_VS_SHADOW_BONUS, "wilson_allegiance_lunar")
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
            pos = {204+22 ,176-110-38+10},
            --pos = {0,-2},
            group = "allegiance",
            tags = {"allegiance","lunar","lunar_favor"},
            onactivate = function(inst, fromload)
                inst:AddTag(UPGRADETYPES.TORCH.."_upgradeuser")
                inst:AddTag(UPGRADETYPES.LUNAR_TORCH.."_upgradeuser")
                inst:AddTag(SPELLTYPES.WURT_LUNAR.."_spelluser") ----官方写死了纯粹辉煌只能是小鱼人tag使用
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag(UPGRADETYPES.TORCH.."_upgradeuser")
                inst:RemoveTag(UPGRADETYPES.LUNAR_TORCH.."_upgradeuser")
                inst:RemoveTag(SPELLTYPES.WURT_LUNAR.."_spelluser")
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