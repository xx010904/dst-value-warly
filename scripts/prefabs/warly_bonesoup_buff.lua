local selfishEaterBuffDuration = warlyvalueconfig.selfishEaterBuffDuration or 300
local boneBouillonShieldChance = warlyvalueconfig.boneBouillonShieldChance or 0.25
local SHIELD_VARIATIONS = 3
local INVINCIBLE_TIME = 0.33
local DODGE_CHANCE = boneBouillonShieldChance -- 每次被攻击有25%几率触发闪避

local function PickShield()
    return "shadow_shield"..tostring(math.random(1, SHIELD_VARIATIONS))
end

local function OnAttached(inst, target)
    if not target then
        inst:Remove()
        return
    end

    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0,0,0)
    inst.target = target

    target:AddTag("warly_bonesoup_buff")

    -- 添加闪避组件
    if not target.components.attackdodger then
        local attackdodger = target:AddComponent("attackdodger")
        attackdodger.candodgefn = function(inst, attacker)
            -- 随机闪避判定
            if math.random() < DODGE_CHANCE then
                -- 创建盾特效
                local fx = SpawnPrefab(PickShield())
                fx.entity:SetParent(inst.entity)

                -- 短暂无敌
                if inst.components.health then
                    inst.components.health:SetInvincible(true)
                    inst:DoTaskInTime(INVINCIBLE_TIME, function()
                        if inst.components.health then
                            inst.components.health:SetInvincible(false)
                        end
                    end)
                end

                -- 提示
                -- if inst.components.talker then
                --     inst.components.talker:Say("I dodged it!")
                -- end

                return true  -- 返回 true 表示本次攻击被闪避，不受伤
            end
            -- 返回 nil/false 表示正常受伤
        end
    end

    -- 提示
    if target.components.talker then
        target.components.talker:Say(GetString(target, "ANNOUNCE_BONESOUP_BUFF_ATTACHED"))
    end

    -- buff持续时间
    inst.components.timer:StartTimer("expire", selfishEaterBuffDuration)
end

local function OnDetached(inst, target)
    if target then
        target:RemoveTag("warly_bonesoup_buff")
        if target.components.talker then
            target.components.talker:Say(GetString(target, "ANNOUNCE_BONESOUP_BUFF_DETACHED"))
        end
        if target.components.attackdodger then
            target:RemoveComponent("attackdodger")
        end
    end
    inst:Remove()
end

local function OnTimerDone(inst, data)
    if data.name == "expire" then
        inst.components.debuff:Stop()
    end
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
    inst:ListenForEvent("timerdone", OnTimerDone)

    return inst
end

return Prefab("warly_bonesoup_buff", fn, {})
