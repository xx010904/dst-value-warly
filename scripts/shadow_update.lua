-- 暗影亲和 午夜屠猪男
-- 屠夫钩子

local HOOK_TARGET_MUST_TAGS = { "_health", "_combat", "locomotor" }
local HOOK_TARGET_CANT_TAGS = { "INLIMBO", "notarget", "noattack", "flight", "invisible", "wall" , "structure" }

local USESHADOWHOOK = Action({priority = 1, rmb = true, distance = 16, mount_valid = true})
USESHADOWHOOK.id = "USESHADOWHOOK"
USESHADOWHOOK.str = STRINGS.ACTIONS.USESHADOWHOOK
USESHADOWHOOK.fn = function(act)
    local doer = act.doer
    local start_pos = doer and doer:GetPosition()

    -- 安全检查
    if not start_pos then
        print("[ShadowHook] Error: start_pos is invalid or nil!")
        return false
    end

    if doer.is_using_shadow_hook then
        print("[ShadowHook] Error: Already using shadow_hook, cannot trigger another one!")
        return false
    end

    doer.is_using_shadow_hook = true

    if doer.prefab == "warly" then
        local shadow_hook_head_fx = SpawnPrefab("shadow_hook_head_fx")
        shadow_hook_head_fx.Transform:SetPosition(start_pos.x, start_pos.y, start_pos.z)

        -- 初始方向与速度
        local angle = doer.Transform:GetRotation()
        shadow_hook_head_fx.Transform:SetRotation(angle)
        local out_speed = 18
        local return_speed = -18
        shadow_hook_head_fx.Physics:SetMotorVel(out_speed, 0, 0)

        -- 配置
        local check_distance = 20          -- 最大射程
        local hook_radius = 2              -- 碰撞半径
        local has_reversed = false
        local target = nil
        local link_nodes = {}
        local spawn_interval = 0.011       -- 生成一个link的间隔
        local spawn_timer = 0              -- 计时器

        shadow_hook_head_fx:DoPeriodicTask(1 * FRAMES, function()
            if not shadow_hook_head_fx or not shadow_hook_head_fx:IsValid() then
                -- 如果 head 被移除了，清理残余 link 并重置标记
                for i = #link_nodes, 1, -1 do
                    if link_nodes[i] and link_nodes[i]:IsValid() then
                        link_nodes[i]:Remove()
                    end
                    table.remove(link_nodes, i)
                end
                if doer then doer.is_using_shadow_hook = false end
                return
            end

            -- 当前钩头位置与距离
            local hx, hy, hz = shadow_hook_head_fx.Transform:GetWorldPosition()
            local current_distance = math.sqrt((hx - start_pos.x)^2 + (hz - start_pos.z)^2)

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
                    end
                end

                -- 到达最大距离则回头
                if current_distance >= check_distance then
                    has_reversed = true
                    shadow_hook_head_fx.Physics:SetMotorVel(return_speed, 0, 0)
                else
                    -- 碰撞检测
                    local entities = TheSim:FindEntities(hx, hy, hz, hook_radius, HOOK_TARGET_MUST_TAGS, HOOK_TARGET_CANT_TAGS)
                    local found = nil
                    for i = 1, math.min(2, #entities) do
                        if entities[i] ~= doer then
                            found = entities[i]
                            break
                        end
                    end
                    if found then
                        target = found
                        has_reversed = true
                        shadow_hook_head_fx.Physics:SetMotorVel(return_speed - (-2), 0, 0)
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
                            shadow_hook_head_fx:DoTaskInTime(0.05, function ()
                                link:Remove()
                                table.remove(link_nodes, i)
                            end)
                        end
                    else
                        table.remove(link_nodes, i)
                    end
                end

                if target and target:IsValid() then
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
                doer.is_using_shadow_hook = false
            end
        end)
        return true
    end
    return false
end
-- 添加动作
AddAction(USESHADOWHOOK)


-- 定义动作选择器
AddComponentAction("POINT", "shadowlevel", function(inst, doer, pos, actions, right, target)
    if doer.prefab == "warly" and doer:HasTag("expertchef") then -- 技能树控制
        local x,y,z = pos:Get()
        if right and (TheWorld.Map:IsAboveGroundAtPoint(x,y,z) or TheWorld.Map:GetPlatformAtPoint(x,z) ~= nil)
            and not TheWorld.Map:IsGroundTargetBlocked(pos) 
            and not doer:HasTag("steeringboat") and not doer:HasTag("rotatingboat") then
            table.insert(actions, ACTIONS.USESHADOWHOOK)
        end
    end
end)


-- 定义 StateGraph 动作处理器
AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.USESHADOWHOOK, "throw"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.USESHADOWHOOK, "throw"))