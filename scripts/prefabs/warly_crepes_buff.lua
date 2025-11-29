local selfishEaterBuffDuration = warlyvalueconfig.selfishEaterBuffDuration or 300
-- print("Warly Mod: selfishEaterBuffDuration", selfishEaterBuffDuration)
local UPDATE_PERIOD = 0.5
local AURA_RANGE = 20

-- 每个敌人每秒回复精神量
local SANITY_PER_ENEMY = 1
local TARGET_SAN_PERCENT = 0.9


-------------------------------------------------------------------
-- 计算附近敌人数量
-------------------------------------------------------------------
local function CountNearbyEnemies(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, AURA_RANGE, { "_combat" }, { "player", "INLIMBO" })

    local n = 0

    for _, e in ipairs(ents) do
        if e.components.combat and e.components.combat.target == inst then
            n = n + 1
        end
        if e:HasTag("hostile") then
            n = n + 1
        end
        if e:HasTag("epic") then
            n = n + 3
        end
    end

    return math.min(n, 25)
end

-------------------------------------------------------------------
-- 启动 buff
-------------------------------------------------------------------
local function StartBuff(inst, target)
    if not target.components.sanity or not target.components.locomotor then
        return
    end

    inst._task = target:DoPeriodicTask(UPDATE_PERIOD, function()
        local count = CountNearbyEnemies(target)

        ---------------------------------------------------------
        -- ① 根据敌人数回复精神
        ---------------------------------------------------------
        local san = target.components.sanity
        local max_san = san.max * TARGET_SAN_PERCENT
        local cur = san.current

        if cur < max_san and count > 0 then
            local delta = SANITY_PER_ENEMY * count * UPDATE_PERIOD
            san.current = math.min(cur + delta, max_san)
        end

        ---------------------------------------------------------
        -- ② 根据敌人数提升移动速度
        --     原公式：1 + 0.2 * sqrt(count)
        ---------------------------------------------------------
        local mult = 1 + 0.2 * math.sqrt(count)
        target.components.locomotor:SetExternalSpeedMultiplier(
            inst, "warly_crepes_buff", mult
        )
    end)
end

-------------------------------------------------------------------
-- 停止 buff
-------------------------------------------------------------------
local function StopBuff(inst, target)
    if inst._task then
        inst._task:Cancel()
        inst._task = nil
    end

    if target.components.locomotor then
        target.components.locomotor:RemoveExternalSpeedMultiplier(
            inst, "warly_crepes_buff"
        )
    end
end


-------------------------------------------------------------------
-- Debuff 生命周期
-------------------------------------------------------------------
local function OnAttached(inst, target)
    inst.entity:SetParent(target.entity)

    StartBuff(inst, target)

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("expire", selfishEaterBuffDuration)
end

local function OnDetached(inst, target)
    StopBuff(inst, target)
    inst:Remove()
end


-------------------------------------------------------------------
-- Prefab
-------------------------------------------------------------------
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddFollower()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("CLASSIFIED")
    inst:AddTag("debuff")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(OnDetached)
    inst.components.debuff.keepondespawn = true

    inst:ListenForEvent("timerdone", function(inst, data)
        if data.name == "expire" then
            inst.components.debuff:Stop()
        end
    end)

    return inst
end

return Prefab("warly_crepes_buff", fn)
