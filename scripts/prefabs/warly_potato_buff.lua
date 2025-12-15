local selfishEaterBuffDuration = warlyvalueconfig.selfishEaterBuffDuration or 300
local potatoMaxDamage = warlyvalueconfig.potatoMaxDamage or 2.0

local function UpdateDamage(inst, target)
    if not (target and target:IsValid()) then return end
    if not (target.components.combat and target.components.hunger) then return end

    local hunger_percent = target.components.hunger:GetPercent()
    hunger_percent = math.clamp(hunger_percent, 0, 1) -- 保证在 0~1 之间

    -- -----------------------------
    -- 1️⃣ 设置普通伤害倍数
    -- -----------------------------
    local mult
    if hunger_percent >= 0.9 then
        mult = potatoMaxDamage
    else
        mult = 0.5 + (hunger_percent / 0.9) * (potatoMaxDamage - 0.5)
    end
    target.components.combat.externaldamagemultipliers:SetModifier(inst, mult, "potatotorte_buff")

    -- -----------------------------
    -- 2️⃣ 位面伤害加成
    -- -----------------------------
    local item = target.components.inventory and target.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    local planar_bonus = 0

    if item
        and item:IsValid()
        and item.components.planardamage
        and item.components.planardamage:GetDamage() > 0
        and not item:HasTag("magicweapon") then
        if hunger_percent >= 0.9 then
            planar_bonus = 25
        else
            planar_bonus = (hunger_percent / 0.9) * 25
        end

        -- 添加 bonus
        item.components.planardamage:AddBonus(target, planar_bonus, "potatotorte_buff")

        -- 移除旧武器 bonus
        if target._potato_planar_weapon and target._potato_planar_weapon:IsValid()
            and target._potato_planar_weapon ~= item
            and target._potato_planar_weapon.components.planardamage then
            target._potato_planar_weapon.components.planardamage:RemoveBonus(target, "potatotorte_buff")
        end

        target._potato_planar_weapon = item
    else
        -- 如果当前没有有效武器，移除旧 bonus
        if target._potato_planar_weapon and target._potato_planar_weapon:IsValid()
            and target._potato_planar_weapon.components.planardamage then
            target._potato_planar_weapon.components.planardamage:RemoveBonus(target, "potatotorte_buff")
        end
        target._potato_planar_weapon = nil
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

    inst.components.timer:StartTimer("expire", selfishEaterBuffDuration)
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
