local BUFF_DURATION = 300 -- buff 持续时间（秒）

local function UpdateDamage(inst, target)
    if target.components.combat and target.components.hunger then
        local hunger_percent = target.components.hunger:GetPercent()
        -- 普通伤害倍率：20%以下为1倍，80%以上为2倍
        local mult = 1 + math.clamp((hunger_percent - 0.2) / 0.6, 0, 1)
        target.components.combat.externaldamagemultipliers:SetModifier(inst, mult, "potatotorte_buff")

        -- 位面伤害加成
        local item = target.components.inventory and target.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if item and item.components.planardamage and item.components.planardamage:GetDamage() > 0 and not item:HasTag("magicweapon") then
            -- 位面伤害映射：20%以下为0，80%以上为25，中间线性映射5~25
            local planar_bonus
            if hunger_percent <= 0.2 then
                planar_bonus = 0
            elseif hunger_percent >= 0.8 then
                planar_bonus = 25
            else
                -- 线性映射 0.2~0.8 -> 5~25
                planar_bonus = 5 + (hunger_percent - 0.2) / (0.8 - 0.2) * (25 - 5)
            end
            item.components.planardamage:AddBonus(target, planar_bonus, "potatotorte_buff")
            -- 保存当前附加的位面武器，方便移除
            if target._potato_planar_weapon ~= item then
                if target._potato_planar_weapon and target._potato_planar_weapon.components.planardamage then
                    target._potato_planar_weapon.components.planardamage:RemoveBonus(target, "potatotorte_buff")
                end
                target._potato_planar_weapon = item
            end
        end
    end
end

local function OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    target:AddTag("warly_potato_buff")

    -- 失去思考能力
    if target.components.sanity then
        target.components.sanity:AddSanityPenalty("warly_potato_buff", 0.5)
    end

    -- 每帧更新攻击力
    inst._update_task = inst:DoPeriodicTask(FRAMES, function()
        if target and target:IsValid() then
            UpdateDamage(inst, target)
        end
    end)

    if target.components.talker then
        target.components.talker:Say(GetString(target, "ANNOUNCE_POTATO_BUFF_ATTACHED"))
    end

    inst.components.timer:StartTimer("expire", BUFF_DURATION)
end

local function OnDetached(inst, target)
    if target then
        target:RemoveTag("warly_potato_buff")
        if target.components.sanity then
            target.components.sanity:RemoveSanityPenalty("warly_potato_buff")
        end

        -- 移除普通伤害倍数
        if target.components.combat then
            target.components.combat.externaldamagemultipliers:RemoveModifier(inst)
        end
        -- 移除武器的位面伤害加成
        if target._potato_planar_weapon and target._potato_planar_weapon.components.planardamage then
            target._potato_planar_weapon.components.planardamage:RemoveBonus(target, "potatotorte_buff")
        end

        if target.components.talker then
            target.components.talker:Say(GetString(target, "ANNOUNCE_POTATO_BUFF_DETACHED"))
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
    inst.components.debuff.keepondespawn = true

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", function(inst, data)
        if data.name == "expire" then
            inst.components.debuff:Stop()
        end
    end)

    return inst
end

return Prefab("warly_potato_buff", fn)
