-- 背锅侠 Crockpot Carrier
-- 1 制作黑锅：100%承受伤害，648耐久，额外受到15%精神损失15%饥饿损失，
-- 2 100%附近队友伤害转移
-- 3.1 概率产生替罪羊 3.2 替罪羊带电 3.3 对替罪羊致命一击
-- 4.1 6个方向甩锅 4.2 摔不坏的锅 4.3 二段跳炸锅（摔坏了就没有二段炸了啊）


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
        builder_tag = "expertchef",
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

    -- 延迟执行确保标签已经加上
    goat:DoTaskInTime(0, function()
        if goat:HasTag("scapegoat") then
            -- 移除 herd 组件和 herd 标签
            if goat.components.herdmember then
                goat:RemoveComponent("herdmember")
            end
            goat:RemoveTag("herdmember")
            -- print("[Scapegoat] 已移除 herd 组件和标签")

            -- 玩家攻击加倍伤害
            goat:ListenForEvent("attacked", function(goat, data)
                if true then -- 技能树控制4倍伤害
                    if data and data.attacker and data.attacker:HasTag("player") then
                        if goat.components.health and not goat.components.health:IsDead() then
                            local dmg = data.damage or 0
                            goat.components.health:DoDelta(-dmg * 3) -- 额外扣除3倍
                        end
                        -- print(string.format("[Scapegoat] 玩家攻击替罪羊，伤害加倍 %.2f", dmg*2))
                    end
                end
            end)

            -- 1.2天后快速死亡
            local seconds = 16 * 60 * 1.2
            goat._scapegoat_killtime = GetTime() + seconds
            goat._scapegoat_task = goat:DoTaskInTime(seconds, function()
                if goat.components.health and not goat.components.health:IsDead() then
                    goat.components.health:Kill()
                    -- print("[Scapegoat] 替罪羊时间到，自动死亡")
                end
            end)
        end
    end)

    -- 保存替罪羊状态
    local old_OnSave = goat.OnSave
    goat.OnSave = function(goat, data)
        if old_OnSave then old_OnSave(goat, data) end
        if goat:HasTag("scapegoat") then
            data.is_scapegoat = true
            if goat._scapegoat_killtime then
                data.scapegoat_killtime = goat._scapegoat_killtime - GetTime()
            end
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

            if data.scapegoat_killtime then
                local seconds = data.scapegoat_killtime
                goat._scapegoat_killtime = GetTime() + seconds
                goat._scapegoat_task = goat:DoTaskInTime(seconds, function()
                    if goat.components.health and not goat.components.health:IsDead() then
                        goat.components.health:Kill()
                        -- print("[Scapegoat] 替罪羊时间到，自动死亡")
                    end
                end)
            end
        end
    end
end)



