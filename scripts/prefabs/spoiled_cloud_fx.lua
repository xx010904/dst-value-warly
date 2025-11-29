local pigmanRotCloudFX = warlyvalueconfig.pigmanRotCloudFX or 1

local function ontimerdone(inst, data)
    if data.name == "lifetime" then
        if pigmanRotCloudFX == 1 then
            inst.AnimState:PlayAnimation("death")
            inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt", nil, .4)
            inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
            inst:ListenForEvent("animover", function (inst)
                inst:Remove()
            end)
        else
            inst.AnimState:PlayAnimation("sporecloud_overlay_pst")
            inst:ListenForEvent("animover", function (inst)
                inst:Remove()
            end)
        end

    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddFollower()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.Transform:SetFourFaced()

    if pigmanRotCloudFX == 1 then
        inst.AnimState:SetBank("pigman")
        inst.AnimState:SetBuild("pig_guard_build")
        inst.AnimState:AddOverrideBuild("slide_puff")
        local variation = tostring(math.random(1, 3))
        inst.AnimState:PlayAnimation(variation == "3" and "side_lob" or "front_lob")
        inst.AnimState:PushAnimation("pose"..variation.."_pre", false)
        inst.AnimState:PushAnimation("pose"..variation.."_pst", false)
        inst.AnimState:PushAnimation("idle_loop")
        inst.AnimState:PlayAnimation("atk_combo", true)
        inst.AnimState:SetDeltaTimeMultiplier(6)
        local s = 0.95
        inst.Transform:SetScale(s, s, s)
    else
        inst.AnimState:SetBank("sporecloud")
        inst.AnimState:SetBuild("sporecloud")
        inst.AnimState:PlayAnimation("sporecloud_overlay_pre")
        inst.AnimState:PushAnimation("sporecloud_overlay_loop", true)
        -- inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        -- inst.AnimState:SetLayer(LAYER_BACKGROUND)
        -- inst.AnimState:SetSortOrder(-1)
        -- inst.AnimState:SetFinalOffset(-1)
        inst.AnimState:SetMultColour(1, 1, 1, 0.47)
        local s = 0.87
        inst.Transform:SetScale(s, s, s)
        inst.AnimState:SetLightOverride(.3)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        -- inst.AnimState:SetDeltaTimeMultiplier(math.random() + 1)
    end
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    if pigmanRotCloudFX == 1 then
        inst:DoPeriodicTask(0.1 + math.random(), function()
            inst.Transform:SetRotation(math.random() * 360)
            inst.SoundEmitter:PlaySound("dontstarve/pig/attack")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
        end)
        inst.flies = inst:SpawnChild("flies")
    end

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)

    return inst
end

return Prefab("spoiled_cloud_fx", fn)
