local selfishEaterBuffDuration = warlyvalueconfig.selfishEaterBuffDuration or 300

-- 小型爆炸参数
local AOE_RADIUS = 2.4
local AOE_DAMAGE = 10

-- 排除查找时的 tags
local AREAATTACK_MUST_TAGS = { "_combat", "_health" }
local AREA_EXCLUDE_TAGS = {
    "playerghost", "FX", "DECOR", "INLIMBO", "wall", "notarget",
    "player", "companion", "invisible", "noattack", "hiding", "shadowminion",
    "playingcard", "deckcontainer"
}

local function AddWet(victim)
    -- 如果已经有本函数添加的 wet 任务，则刷新时间
    if victim._custom_wet_task then
        victim._custom_wettime = 10  -- 刷新持续时间
        return
    end

    -- 如果目标天生就带 wet 标签（但不是我们添加的），不触发
    if victim:HasTag("wet") then
        return
    end

    -- 初始化专用的 wet 时间变量
    victim._custom_wettime = 10

    -- 添加 wet 标签
    victim:AddTag("wet")

    -- 启动定时任务
    victim._custom_wet_task = victim:DoPeriodicTask(1, function(inst)
        victim._custom_wettime = victim._custom_wettime - 1
        if victim._custom_wettime <= 0 then
            -- 移除自己添加的 wet 标签
            if victim:HasTag("wet") then
                victim:RemoveTag("wet")
            end
            victim._custom_wet_task:Cancel()
            victim._custom_wet_task = nil
            victim._custom_wettime = nil
        end
    end)
end

-- 灭火方法
local FIRE_CANT_TAGS = { "INLIMBO", "lighter" }
local FIRE_ONEOF_TAGS = { "fire", "smolder" }
local function ExtinguishFire(victim)
    local x, y, z = victim.Transform:GetWorldPosition()
    local fires = TheSim:FindEntities(x, y, z, AOE_RADIUS * 2, nil, FIRE_CANT_TAGS, FIRE_ONEOF_TAGS)

    if #fires > 0 then
        for i, fire in ipairs(fires) do
            if fire.components.burnable then
                fire.components.burnable:Extinguish(true, 0)
            end
        end
    end
end

-- 是否是海面点判断快捷函数
local function IsOceanPoint(x, y, z)
    -- TheWorld.Map:IsOceanTileAtPoint expects x,z
    return TheWorld.Map ~= nil and TheWorld.Map:IsOceanTileAtPoint(x, y, z)
end

-- AOE 造成伤害
local function DoAOEDamageAtPoint(inst, owner, px, py, pz, radius, damage)
    -- 找到附近可受影响的 entities（排除玩家和无血组件对象）
    local ents = TheSim:FindEntities(px, py, pz, radius, AREAATTACK_MUST_TAGS, AREA_EXCLUDE_TAGS)
    for _, v in ipairs(ents) do
        if v and v:IsValid() and v.components.health and not v:HasTag("player") then
            -- 伤害：使用 DoDelta，source 名称可以写成 inst 或 owner
            v.components.health:DoDelta(-damage, nil, inst or owner)
            AddWet(v)
            ExtinguishFire(v)
        end
    end
end

-- 在点上生成单个 waterspout 并造成 AOE 伤害
local function SpawnWaterspoutAndExplode(inst, owner, px, py, pz, radius, damage)
    -- spawn fx if not over a platform at that point
    local fx = SpawnPrefab("crab_king_waterspout")
    if fx then
        fx.Transform:SetPosition(px, py, pz)
    end

    -- 造成 aoe 伤害
    DoAOEDamageAtPoint(inst, owner, px, py, pz, radius, damage)
end

-- 当被 buff 的角色发起攻击时可能触发的处理函数
local function OnBuffedAttacked(inst, attacker, data)
    -- attacker is the buffed player (we listened on target, so 'attacker' param is target)
    -- data.target 是被攻击的实体
    if not data or not data.target or not data.target:IsValid() then
        return
    end

    local owner = attacker -- buff 的持有者
    local target = data.target

    local tx, ty, tz = target.Transform:GetWorldPosition()
    target:DoTaskInTime(0.1, function(target)
        if target then
            -- 单个中心水柱
            target:DoTaskInTime(0.12, function()
                SpawnWaterspoutAndExplode(inst, owner, tx + math.random() * 1.5 - 0.75, ty, tz + math.random() * 1.5 - 0.75, AOE_RADIUS, AOE_DAMAGE)
            end)
            -- 如果在海面上：共 5 个，中心 1 个 + 周围 4 个
            if IsOceanPoint(tx, ty, tz) then
                local NUM_SPOUTS = 5       -- 水柱数量
                local RADIUS = 1.7         -- 偏移半径范围

                -- 随机起始角度
                local start_angle = math.random() * 2 * math.pi

                for i = 1, NUM_SPOUTS do
                    local angle = start_angle + (i-1) * (2 * math.pi / NUM_SPOUTS)  -- 均匀分布角度
                    local distance = math.random() * RADIUS                          -- 随机半径 [0,RADIUS)
                    local ox = tx + math.cos(angle) * distance
                    local oz = tz + math.sin(angle) * distance

                    target:DoTaskInTime((i - 1) * 0.12, function()
                        SpawnWaterspoutAndExplode(inst, owner, ox, ty, oz, AOE_RADIUS, AOE_DAMAGE / 3)
                    end)
                end
            end
        end
    end)
end

-- OnAttached / OnDetached
local function OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    target:AddTag("warly_seafood_buff")

    if target.components.talker then
        target.components.talker:Say(GetString(target, "ANNOUNCE_SEAFOOD_BUFF_ATTACHED"))
    end

    -- 监听攻击事件：当 buff 的持有者攻击时触发（data.target 为被攻击对象）
    local func = function(attacker, data) OnBuffedAttacked(inst, attacker, data) end
    -- 保存以便移除
    inst._onattack_cb = func
    target:ListenForEvent("onattackother", func, target)

    -- buff 持续时间
    inst.components.timer:StartTimer("expire", selfishEaterBuffDuration)
end

local function OnDetached(inst, target)
    if target then
        target:RemoveTag("warly_seafood_buff")
        if target.components.talker then
            target.components.talker:Say(GetString(target, "ANNOUNCE_SEAFOOD_BUFF_DETACHED"))
        end

        if inst._onattack_cb then
            target:RemoveEventCallback("onattackother", inst._onattack_cb, target)
            inst._onattack_cb = nil
        end
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

return Prefab("warly_seafood_buff", fn)
