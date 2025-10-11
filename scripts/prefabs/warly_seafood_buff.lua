local function UpdateSpeed(inst)
    if inst.components.locomotor then
        local x, y, z = inst.Transform:GetWorldPosition()
        local entities = TheSim:FindEntities(x, y, z, 25, { "_combat" }, { "player", "INLIMBO" })
        local count = 0
        -- local enemy_names = {}

        for i, e in ipairs(entities) do
            -- 1. 攻击目标是自己
            if e.components.combat and e.components.combat.target == inst then
                count = count + 1
                -- table.insert(enemy_names, (e.prefab or "unknown").."[target_me]")
            end
            -- 2. hostile 标签
            if e:HasTag("hostile") then
                count = count + 1
                -- table.insert(enemy_names, (e.prefab or "unknown").."[hostile]")
            end
            -- 3. epic 标签
            if e:HasTag("epic") then
                count = count + 3
                -- table.insert(enemy_names, (e.prefab or "unknown").."[epic]")
            end
        end

        count = math.min(count, 25)

        -- 平方根非线性加速
        local mult = 1 + 0.25 * math.sqrt(count)

        inst.components.locomotor:SetExternalSpeedMultiplier(inst, "warly_seafood_buff", mult)

        -- 日志输出
        -- print("[Seafood Buff] Counted enemies:", count, "Speed Mult:", string.format("%.2f", mult), "Entities:", table.concat(enemy_names, ", "))
    end
end


local function OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    target:AddTag("warly_seafood_buff")

    inst._updatetask = target:DoPeriodicTask(0.5, function() UpdateSpeed(target) end)
    target.components.talker:Say("The more foes, the faster I flow!")

    inst.components.timer:StartTimer("expire", 300)
end

local function OnDetached(inst, target)
    if target and target.components.locomotor then
        target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "warly_seafood_buff")
        target:RemoveTag("warly_seafood_buff")
        target.components.talker:Say("The tide of speed recedes...")
    end
    if inst._updatetask then
        inst._updatetask:Cancel()
        inst._updatetask = nil
    end
    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddFollower()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("debuff")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(OnDetached)

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", function(inst, data)
        if data.name == "expire" then
            inst.components.debuff:Stop()
        end
    end)

    return inst
end

return Prefab("warly_seafood_buff", fn)
