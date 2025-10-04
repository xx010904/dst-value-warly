local BUFF_DURATION = 300      -- buff 持续时间（秒）
local UPDATE_INTERVAL = 1      -- 每秒检测一次饥饿变化

local function UpdateDamage(inst, target)
    if target.components.combat and target.components.hunger then
        local hunger_percent = target.components.hunger:GetPercent()
        -- 线性映射：20%以下为1倍，80%以上为2倍
        local mult = 1 + math.clamp((hunger_percent - 0.2) / 0.6, 0, 1)
        -- 结果范围：1.0 ~ 2.0

        target.components.combat.externaldamagemultipliers:SetModifier(inst, mult, "potatotorte_buff")
        -- print(string.format("[Potato Buff] Hunger %.1f%% => Damage x%.2f", hunger_percent * 100, mult))
    end
end

local function OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    target:AddTag("warly_potato_buff")

    -- 启动定时更新任务
    inst._update_task = inst:DoPeriodicTask(UPDATE_INTERVAL, function()
        if target and target:IsValid() then
            UpdateDamage(inst, target)
        end
    end)

    if target.components.talker then
        target.components.talker:Say("I feel mighty and fluffy!")
    end

    inst.components.timer:StartTimer("expire", BUFF_DURATION)
end

local function OnDetached(inst, target)
    if target then
        target:RemoveTag("warly_potato_buff")
        if target.components.combat then
            target.components.combat.externaldamagemultipliers:RemoveModifier(inst)
        end
        if target.components.talker then
            target.components.talker:Say("The fluffiness fades...")
        end
    end

    if inst._update_task then
        inst._update_task:Cancel()
        inst._update_task = nil
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

return Prefab("warly_potato_buff", fn)
