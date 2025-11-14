
local function onhammered(inst, worker)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("loop1", true)
    end
end

local function ShootTrash(inst, doer, targetpos)
    if not targetpos then return end

    local x, y, z = inst.Transform:GetWorldPosition()
    local proj = SpawnPrefab("warly_trash_projectile")
    if proj then
        proj.Transform:SetPosition(x, y + 1.5, z)
        local dx = targetpos.x - x
        local dz = targetpos.z - z
        local dist = math.sqrt(dx * dx + dz * dz)
        local speed = 15
        local vel = Vector3(dx / dist * speed, 10, dz / dist * speed)
        proj.components.complexprojectile:Launch(targetpos, inst)
    end

    inst.SoundEmitter:PlaySound("dontstarve/common/launch")
end

-- 鼠标点击逻辑：左键或右键点地板扔垃圾，右键点自己解除状态
local function OnMouseClick(inst, doer, target)
    if target == doer then
        inst:Remove() -- 解除垃圾堆状态
        return
    end

    local pt = target:GetPosition() or target
    ShootTrash(inst, doer, pt)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.3)

    inst.AnimState:SetBank("scrappile")
    inst.AnimState:SetBuild("scrappile")
    inst.AnimState:PlayAnimation("loop1", true)

    inst:AddTag("structure")
    inst:AddTag("notarget")
    inst:AddTag("warly_junk_pile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    -- 特殊鼠标行为
    inst.OnMouseClick = OnMouseClick

    return inst
end

return Prefab("warly_junk_pile", fn)
