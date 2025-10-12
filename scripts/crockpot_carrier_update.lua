-- 炊具改装
-- 背锅侠 Crockpot Carrier
-- 1 制作黑锅：100%承受伤害，648耐久，额外受到15%精神损失15%饥饿损失，
-- 2 100%附近队友伤害转移
-- 3.1 概率产生替罪羊 3.2 屠杀额外掉落
-- 4.1 6个方向甩锅 4.2 二段跳炸锅（摔坏了就没有二段炸了啊）


--========================================================
-- 背锅锅制作配方
--========================================================
AddRecipe2("armor_crockpot",
    {
        Ingredient("portablecookpot_item", 6),
        Ingredient("charcoal", 13),
    },
    TECH.NONE,
    {
        product = "armor_crockpot", -- 唯一id
        atlas = "images/inventoryimages/armor_crockpot.xml",
        image = "armor_crockpot.tex",
        builder_tag = "masterchef",
        builder_skill= nil, -- 可选：指定技能树才能做（技能树指定标签）
        description = "armor_crockpot", -- 描述的id，而非本身
        numtogive = 1,
    }
)
AddRecipeToFilter("armor_crockpot", "CHARACTER")

--========================================================
-- 统一给所有电羊添加替罪羊逻辑
--========================================================
AddPrefabPostInit("lightninggoat", function(goat)
    if not TheWorld.ismastersim then return end

    goat:DoTaskInTime(0, function()
        if goat:HasTag("scapegoat") then
            -- 移除 herd 组件和 herd 标签
            if goat.components.herdmember then
                goat:RemoveComponent("herdmember")
            end
            goat:RemoveTag("herdmember")

            -- 玩家攻击加倍伤害 + 死亡额外掉落羊角
            goat:ListenForEvent("attacked", function(goat, data)
                if data and data.attacker and data.attacker:HasTag("player") then
                    if goat.components.health and not goat.components.health:IsDead() then
                        local dmg = data.damage or 0
                        goat.components.health:DoDelta(-dmg * 3) -- 额外扣除3倍
                    end
                end
            end)

            -- 替罪羊被击杀后可能掉落羊角
            goat:ListenForEvent("death", function(goat, data)
                if math.random() > 0.5 then --技能树控制
                    return
                end
                -- 查找附近玩家
                local x, y, z = goat.Transform:GetWorldPosition()
                local players = TheSim:FindEntities(x, y, z, 10, {"player"})
                for _, player in ipairs(players) do
                    -- 检查是否为沃利并且有技能树
                    if player.prefab == "warly" then
                        -- 掉落一个羊角
                        local horn = SpawnPrefab("lightninggoathorn")
                        if horn then
                            horn.Transform:SetPosition(x, y, z)
                        end
                        break
                    end
                end
            end)

            -- 替罪羊每秒掉血
            goat.components.health:StartRegen(-3, 1)
        end
    end)

    -- 保存替罪羊状态
    local old_OnSave = goat.OnSave
    goat.OnSave = function(goat, data)
        if old_OnSave then old_OnSave(goat, data) end
        if goat:HasTag("scapegoat") then
            data.is_scapegoat = true
        end
    end

    -- 加载替罪羊状态
    local old_OnLoad = goat.OnLoad
    goat.OnLoad = function(goat, data)
        if old_OnLoad then old_OnLoad(goat, data) end
        if data and data.is_scapegoat then
            goat:AddTag("scapegoat")
            if goat.components.herdmember then
                goat:RemoveComponent("herdmember")
            end
            goat:RemoveTag("herdmember")
        end
    end
end)



