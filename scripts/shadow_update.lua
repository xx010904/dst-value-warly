-- 暗影亲和 午夜屠猪男
-- 喂养暗影槌 因为能吸血，契合不能回血的沃利，其次是沃利可以给它加个喂养(会触发下饭操作)
-- 屠夫钩子，钩中人也记录进连杀可以蹭伤害

--========================================================
-- 暗影槌青春版配方
--========================================================
AddRecipe2("shadow_battleaxe_young",
    {
        Ingredient("axe", 1),
        Ingredient("batbat", 1),
        Ingredient("nightmarefuel", 1),
    },
    TECH.NONE,
    {
        product = "shadow_battleaxe_young", -- 唯一id
        atlas = "images/inventoryimages/shadow_battleaxe_young.xml",
        image = "shadow_battleaxe_young.tex",
        builder_tag = "masterchef",
        builder_skill = "warly_allegiance_shadow", -- 指定技能树才能做
        description = "shadow_battleaxe_young",    -- 描述的id，而非本身
        numtogive = 1,
    }
)
AddRecipeToFilter("shadow_battleaxe_young", "CHARACTER")

--========================================================
-- 屠夫钩子
--========================================================
AddPrefabPostInit("shadow_battleaxe", function(inst)
    inst:AddComponent("shadowhooktool")
end)

local HOOK_TARGET_MUST_TAGS = { "_health", "_combat", "locomotor" }
local HOOK_TARGET_CANT_TAGS = { "INLIMBO", "notarget", "noattack", "flight", "invisible", "wall", "structure" }

local USESHADOWHOOK = Action({ priority = 3, rmb = true, distance = 20, mount_valid = true })
USESHADOWHOOK.id = "USESHADOWHOOK"
USESHADOWHOOK.str = STRINGS.ACTIONS.USESHADOWHOOK
USESHADOWHOOK.fn = function(act)
    local doer = act.doer
    local start_pos = doer and doer:GetPosition()
    local inst = act.invobject -- 玩家使用的物品

    -- 安全检查
    if not start_pos then
        print("[ShadowHook] Error: start_pos is invalid or nil!")
        return false
    end

    if doer:HasTag("is_using_shadow_hook") then
        if inst._classified then
            local list2 = STRINGS.SHADOW_BATTLEAXE_TALK["hook_throwing"]
            inst._classified:Say(list2, math.random(#list2), "rifts4/nightmare_axe/lvl" .. inst.level .. "_talk_LP")
        end
        return false
    end

    doer:AddTag("is_using_shadow_hook")

    -- 耐久检查并消耗
    if inst and inst.components.finiteuses then
        inst.components.finiteuses:Use(8) -- 消耗耐久
    end

    if doer.prefab == "warly" then
        local shadow_hook_head_fx = SpawnPrefab("shadow_hook_head_fx")
        shadow_hook_head_fx.AnimState:PlayAnimation("swap_level" .. inst.level .. "_f1", true)
        shadow_hook_head_fx.Transform:SetPosition(start_pos.x, start_pos.y, start_pos.z)
        if inst._classified then
            local list2 = STRINGS.SHADOW_BATTLEAXE_TALK["hook_throw"]
            inst._classified:Say(list2, math.random(#list2), "rifts4/nightmare_axe/lvl" .. inst.level .. "_talk_LP")
        end

        -- 初始方向与速度
        local angle = doer.Transform:GetRotation()
        shadow_hook_head_fx.Transform:SetRotation(angle)
        local out_speed = 18
        local return_speed = -18
        shadow_hook_head_fx.Physics:SetMotorVel(out_speed, 0, 0)

        -- 配置
        local check_distance = 20 -- 最大射程
        local hook_radius = 2     -- 碰撞半径
        local has_reversed = false
        local target = nil
        local link_nodes = {}
        local spawn_interval = 0.011 -- 生成一个link的间隔
        local spawn_timer = 0        -- 计时器

        shadow_hook_head_fx:DoPeriodicTask(1 * FRAMES, function()
            if not shadow_hook_head_fx or not shadow_hook_head_fx:IsValid() then
                -- 如果 head 被移除了，清理残余 link 并重置标记
                for i = #link_nodes, 1, -1 do
                    if link_nodes[i] and link_nodes[i]:IsValid() then
                        link_nodes[i]:Remove()
                    end
                    table.remove(link_nodes, i)
                end
                if doer then doer:RemoveTag("is_using_shadow_hook") end
                return
            end

            -- 当前钩头位置与距离
            local hx, hy, hz = shadow_hook_head_fx.Transform:GetWorldPosition()
            local current_distance = math.sqrt((hx - start_pos.x) ^ 2 + (hz - start_pos.z) ^ 2)

            -- 发射阶段
            if not has_reversed then
                -- 每隔生成一个link节点
                spawn_timer = spawn_timer + FRAMES
                if spawn_timer >= spawn_interval then
                    spawn_timer = 0
                    local link_fx = SpawnPrefab("shadow_hook_link_fx")
                    if link_fx then
                        link_fx.Transform:SetPosition(hx, hy + 0.4, hz)
                        table.insert(link_nodes, link_fx)
                        shadow_hook_head_fx.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/chain")
                    end
                end

                -- 到达最大距离则回头
                if current_distance >= check_distance then
                    has_reversed = true
                    shadow_hook_head_fx.Physics:SetMotorVel(return_speed, 0, 0)
                else
                    -- 碰撞检测
                    local entities = TheSim:FindEntities(hx, hy, hz, hook_radius, HOOK_TARGET_MUST_TAGS,
                        HOOK_TARGET_CANT_TAGS)
                    local found = nil
                    for i = 1, #entities do
                        local ent = entities[i]
                        if ent ~= doer and ent.components.health and not ent.components.health:IsDead() then
                            found = ent
                            break
                        end
                    end
                    if found then
                        target = found
                        has_reversed = true
                        shadow_hook_head_fx.Physics:SetMotorVel(return_speed - (-2), 0, 0)
                        shadow_hook_head_fx.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/bell_idle")

                        -- ⚠️ 施加暗影钩减速与削弱 Buff
                        if target and target:IsValid() and target.components.health and not target.components.health:IsDead() then
                            if not target:HasTag("companion") and not (doer.components.leader and doer.components.leader:IsFollower(target)) then
                                if target:HasTag("shadow_hook_debuff") then
                                    target:RemoveDebuff("shadow_hook_debuff")
                                end
                                target:AddDebuff("shadow_hook_debuff", "shadow_hook_debuff")
                            end
                        end
                    end
                end
            end

            -- 回收阶段：碰撞删除link
            if has_reversed then
                local rr = 1
                for i = #link_nodes, 1, -1 do
                    local link = link_nodes[i]
                    if link and link:IsValid() then
                        local lx, ly, lz = link.Transform:GetWorldPosition()
                        local dx = hx - lx
                        local dz = hz - lz
                        if dx * dx + dz * dz <= rr then
                            shadow_hook_head_fx:DoTaskInTime(0.05, function()
                                link:Remove()
                                table.remove(link_nodes, i)
                                shadow_hook_head_fx.SoundEmitter:PlaySound(
                                    "dontstarve/creatures/together/deer/chain_idle")
                            end)
                        end
                    else
                        table.remove(link_nodes, i)
                    end
                end
                -- 目标跟随回来，剥皮长钩
                if target and target:IsValid() then
                    inst:DoAttackEffects(doer, target)
                    -- 只有非 companion 且非 leader 的目标才受伤害
                    if not target:HasTag("companion") and not (doer.components.leader and doer.components.leader:IsFollower(target)) then
                        target.components.health:DoDelta(-(inst.level * 12 - 11), nil, inst)

                        -- 吸血要2级才会(1到4级)
                        if inst.level > 1 and doer.components.health.currenthealth < doer.components.health.maxhealth then
                            local suck = 1.1
                            doer.components.health:DoDelta(suck, nil, inst)
                            doer.components.sanity:DoDelta(-suck / 2, nil, inst)
                        end
                    end
                    target.Transform:SetPosition(hx, hy, hz)
                end
            end

            -- 回到起点时清理
            if has_reversed and current_distance <= 1 then
                for i = #link_nodes, 1, -1 do
                    if link_nodes[i] and link_nodes[i]:IsValid() then
                        link_nodes[i]:Remove()
                    end
                    table.remove(link_nodes, i)
                end

                if shadow_hook_head_fx and shadow_hook_head_fx:IsValid() then
                    shadow_hook_head_fx:Remove()
                end
                doer:RemoveTag("is_using_shadow_hook")
                if target and doer then
                    -- ✅ 如果是物品，直接捡起来
                    if target.components.inventoryitem and not target.components.inventoryitem:IsHeld() and doer.components.inventory then
                        if target.components.health and not target.components.health:IsDead() then
                            doer.components.inventory:GiveItem(target)
                        end
                    else
                        -- 扣血逻辑（无论是不是Boss）
                        if target.components.health and not target.components.health:IsDead() then
                            -- 如果目标是 leader，且 doer 是其 follower，则跳过扣血
                            if doer.components.leader and doer.components.leader:IsFollower(target) then
                                -- leader的followers不会被扣血
                            else
                                if target:HasTag("companion") then
                                    if doer.components.rider and target.components.rideable then
                                        doer.components.rider:Mount(target, false)
                                    end
                                else
                                    target.components.health:DoDelta(-(inst.level * 11 + 38), nil, inst)
                                    doer.components.combat:DoAttack(target)

                                    -- 吸血要2级才会(1到4级)
                                    if inst.level > 1 and doer.components.health.currenthealth < doer.components.health.maxhealth then
                                        local suck = 2.2
                                        doer.components.health:DoDelta(inst.level * suck, nil, inst)
                                        doer.components.sanity:DoDelta(-inst.level * suck / 2, nil, inst)
                                    end
                                end

                                if inst.TrackTarget then
                                    inst:TrackTarget(target) -- 钩中人也记录进连杀
                                end
                            end
                        end
                    end
                end
            end
        end)
        return true
    end
    return false
end
-- 添加动作
AddAction(USESHADOWHOOK)


-- 定义动作选择器
AddComponentAction("EQUIPPED", "shadowhooktool", function(inst, doer, target, actions, right)               -- 兼容海上和对物品触发
    if doer.prefab == "warly" and doer:HasTag("masterchef") and doer:HasTag("warly_allegiance_shadow") then -- 技能树控制
        -- 先检查inst是否有 finiteuses 且耐久 > 0
        local has_uses = true
        if inst and inst.components.finiteuses then
            has_uses = inst.components.finiteuses:GetUses() > 0
        end

        if right and not (doer.components.playercontroller ~= nil and doer.components.playercontroller.isclientcontrollerattached) then
            if has_uses and not doer:HasTag("is_using_shadow_hook") then
                table.insert(actions, ACTIONS.USESHADOWHOOK)
            end
        end
    end
end)
AddComponentAction("POINT", "shadowhooktool", function(inst, doer, pos, actions, right, target)
    if doer.prefab == "warly" and doer:HasTag("masterchef") and doer:HasTag("warly_allegiance_shadow") then -- 技能树控制
        -- 先检查inst是否有 finiteuses 且耐久 > 0
        local has_uses = true
        if inst and inst.components.finiteuses then
            has_uses = inst.components.finiteuses:GetUses() > 0
        end

        if right and not (doer.components.playercontroller ~= nil and doer.components.playercontroller.isclientcontrollerattached) then
            if has_uses and not doer:HasTag("is_using_shadow_hook") then
                table.insert(actions, ACTIONS.USESHADOWHOOK)
            end
        end
    end
end)

-- 定义 StateGraph 动作处理器
AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.USESHADOWHOOK, "throw"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.USESHADOWHOOK, "throw"))


--========================================================
-- 大厨喂给 shadow_battleaxe 食物增加饥饿度的动作
--========================================================
-- 定义动作
AddAction("GIVEFOODTOBATTLEAXE", STRINGS.ACTIONS.GIVEFOODTOBATTLEAXE, function(act)
    local doer = act.doer
    local target = act.target
    local item = act.invobject

    if not doer or not target or not item then
        return false
    end

    if doer.prefab ~= "warly" or not doer:HasTag("warly_allegiance_shadow") then -- 技能树标签控制
        return false
    end

    if target.prefab ~= "shadow_battleaxe" then
        return false
    end

    if not item.components.edible then
        return false
    end

    -- ✅ 限制只能喂怪物肉
    -- if item.components.edible.foodtype ~= FOODTYPE.MEAT
    --     or item.components.edible.secondaryfoodtype ~= FOODTYPE.MONSTER
    -- then
    --     return false
    -- end

    local hunger = target.components.hunger
    if not hunger then
        return false
    end

    -- 每次只喂一个食物
    local hunger_gain = (item.components.edible and item.components.edible:GetHunger() / 4) or 0
    if hunger_gain <= 0 then
        return false
    end

    local prev = hunger.current
    local used_to_fill = math.max(0, hunger.max - prev)

    -- 移除食物
    if item.components.stackable then
        item.components.stackable:Get(1):Remove()
    else
        item:Remove()
    end

    -- 增加饥饿值
    hunger:DoDelta(hunger_gain)

    -- 如果吃饱了，计算溢出饱食度转为耐久
    if used_to_fill < hunger_gain then
        local overflow = math.max(0, hunger_gain - used_to_fill)

        if overflow > 0 and target.components.finiteuses then
            -- 多余饱食度 → 耐久
            local current = target.components.finiteuses:GetUses()
            local max_uses = target.components.finiteuses.total
            target.components.finiteuses:SetUses(math.min(max_uses, current + overflow))
        end
    end


    -- 显示饥饿度
    local hunger_percent = hunger:GetPercent() * 100

    if target._classified then
        local list = STRINGS.SHADOW_BATTLEAXE_TALK["feed_up"]
        target._classified:Say(list, math.random(#list), "rifts4/nightmare_axe/lvl" .. target.level .. "_talk_LP")
    end

    -- 最高喂到2级，可以开始吸血(1到4级，不是0到3)
    if hunger_percent >= 100 and target.level and target.level < 2 then
        target:SetLevel(2)
        if target._classified then
            local list2 = STRINGS.SHADOW_BATTLEAXE_TALK["eat_level_up"]
            target._classified:Say(list2, math.random(#list2), "rifts4/nightmare_axe/lvl" .. target.level .. "_talk_LP")
        end
    end

    return true
end)

ACTIONS.GIVEFOODTOBATTLEAXE.mount_valid = true

-- 设置动作组件使用条件
AddComponentAction("USEITEM", "edible", function(inst, doer, target, actions, right)
    if target and target.prefab == "shadow_battleaxe" and not target:HasTag("broken") and doer.prefab == "warly" and doer:HasTag("warly_allegiance_shadow") then -- 技能树标签控制
        table.insert(actions, ACTIONS.GIVEFOODTOBATTLEAXE)
    end
end)

-- 定义 StateGraph 动作处理器
AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.GIVEFOODTOBATTLEAXE, "dolongaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.GIVEFOODTOBATTLEAXE, "dolongaction"))
