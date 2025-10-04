-- 背锅侠 Crockpot Carrier
-- 1 制作黑锅：100%承受伤害，648耐久，额外受到25%精神损失25%饥饿损失，100%伤害转移
-- 2 消耗减少到15%
-- 3.1 概率产生替罪羊 3.2 替罪羊带电 3.3 残忍杀替罪羊
-- 4.1 6个方向甩锅 4.2 甩锅二段跳 4.3 破锅返回材料

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
                if data and data.attacker and data.attacker:HasTag("player") then
                    if goat.components.health and not goat.components.health:IsDead() then
                        local dmg = data.damage or 0
                        local weapon = data.weapon
                        goat.components.health:DoDelta(dmg * 2)
                        -- print(string.format("[Scapegoat] 玩家攻击替罪羊，伤害加倍 %.2f", dmg*2))
                    end
                end
            end)

            -- 2.5天后快速死亡
            local seconds = 16 * 60 * 2.5
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



