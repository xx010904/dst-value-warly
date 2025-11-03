require "prefabutil"

local cooking = require("cooking")

local function SetProductSymbol(inst, product, overridebuild)
    local recipe = cooking.GetRecipe("portablecookpot", product)
    local potlevel = recipe ~= nil and recipe.potlevel or nil
    local build = (recipe ~= nil and recipe.overridebuild) or overridebuild or "cook_pot_food"
    local overridesymbol = (recipe ~= nil and recipe.overridesymbolname) or product

    -- print("本次食物：recipe:", recipe, ",potlevel:", potlevel, ",build:", build, ",overridesymbol:", overridesymbol)

    if potlevel == "high" then
        inst.AnimState:Show("swap_high")
        inst.AnimState:Hide("swap_mid")
        inst.AnimState:Hide("swap_low")
    elseif potlevel == "low" then
        inst.AnimState:Hide("swap_high")
        inst.AnimState:Hide("swap_mid")
        inst.AnimState:Show("swap_low")
    else
        inst.AnimState:Hide("swap_high")
        inst.AnimState:Show("swap_mid")
        inst.AnimState:Hide("swap_low")
    end

    inst.AnimState:OverrideSymbol("swap_cooked", build, overridesymbol)
end

-- 🧩 即兴锅 prefab
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("portable_cook_pot")
    inst.AnimState:SetBuild("portable_cook_pot")
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:SetFinalOffset(2)
    inst.AnimState:SetMultColour(1, 1, 1, 0.9)

    MakeCharacterPhysics(inst, 1000, 0.75)

    inst:AddTag("improv_cookpot_fx")
    inst.persists = false

    if not TheWorld.ismastersim then
        inst:DoTaskInTime(1, function()
            local label = inst.entity:AddLabel()
            label:SetFont(TALKINGFONT)
            label:SetFontSize(21)
            label:SetWorldOffset(0, 2.2, 0)
            label:SetColour(204 / 255, 99 / 255, 78 / 255)
            local lines = STRINGS.MEAL_WORTH_ACTIONS
            local text = lines[math.random(#lines)]
            label:SetText(text)
            label:Enable(true)
        end)
        return inst
    end

    inst.doer = nil
    inst.meal = nil

    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = 1
    inst.components.locomotor.walkspeed = 1

    inst:ListenForEvent("animover", function()
        if inst.AnimState:IsCurrentAnimation("place") then
            --------------------------------------------------
            -- 🍳 开始煮饭阶段
            --------------------------------------------------
            -- local cook_time = math.random(10, 15)
            inst.components.locomotor:Stop()
            local cook_time = 4.4
            inst.AnimState:PlayAnimation("hit_cooking", true)
            inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "cookloop")

            inst:DoTaskInTime(cook_time, function()
                inst.SoundEmitter:KillSound("cookloop")

                --------------------------------------------------
                -- 🍲 煮好 → hit_full 显示食物
                --------------------------------------------------
                local product = nil
                if inst.meal then
                    product = inst.meal or "wetgoop"
                end
                local diaplay_product = inst.display_meal or product or "wetgoop"
                -- print("improv_cookpot_fx 煮好啦！产物=", product, ",展示食物=", diaplay_product)

                inst.AnimState:PlayAnimation("hit_full", true)
                SetProductSymbol(inst, diaplay_product) -- ✅ 展示食物

                --------------------------------------------------
                -- ⏳ 展示1秒后 → 弹出食物 & 播放 hit_empty
                --------------------------------------------------
                inst:DoTaskInTime(0.7, function()
                    inst.AnimState:PlayAnimation("hit_empty", false)

                    -- 🎁 扔出食物实体，技能树控制
                    local hasSkill = inst.doer and inst.doer.components.skilltreeupdater and inst.doer.components.skilltreeupdater:IsActivated("warly_funny_cook_spice")
                    local loot = SpawnPrefab(hasSkill and product or diaplay_product) -- 技能树控制：调味的料理
                    if loot then
                        local x, y, z = inst.Transform:GetWorldPosition()
                        loot.Transform:SetPosition(x, y + 1, z)
                        if loot.Physics then
                            local angle = math.random() * 2 * PI
                            local speed = 1 + math.random()
                            loot.Physics:SetVel(speed * math.cos(angle), 5, speed * math.sin(angle))
                        end
                    end

                    --------------------------------------------------
                    -- 💨 锅塌陷动画
                    --------------------------------------------------
                    inst:ListenForEvent("animover", function()
                        if inst.AnimState:IsCurrentAnimation("hit_empty") then
                            inst.AnimState:PlayAnimation("collapse", false)
                            inst:ListenForEvent("animover", function()
                                if inst.AnimState:IsCurrentAnimation("collapse") then
                                    SpawnPrefab("lucy_ground_transform_fx").Transform:SetPosition(inst.Transform
                                        :GetWorldPosition())
                                    inst:Remove()
                                end
                            end)
                        end
                    end)
                end)
            end)
        end
    end)

    return inst
end

return Prefab("improv_cookpot_fx", fn)
