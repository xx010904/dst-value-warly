-- 炊具改装 (解决回血困难)
-- Section 1：背锅侠 Crockpot Carrier
-- 1 制作黑锅：100%承受伤害，648耐久，额外受到10%精神损失10%饥饿损失，
-- 2 100%附近队友伤害转移
-- 3.1 概率产生替罪羊 3.2 解羊：屠杀额外掉落
-- 4.1 6个方向甩锅 4.2 二段跳炸锅（摔坏了就没有二段炸了啊）

-- Section 2：改造厨师包
-- 1 制作厨师袋，因为背包位置被占了
-- 2 舒适的厨师袋，料理越多越多回san


--========================================================
-- 背锅锅制作配方
--========================================================
AddRecipe2("armor_crockpot",
    {
        Ingredient("portablecookpot_item", 6),
        Ingredient("charcoal", 13),
    },
    TECH.NONE,
    {
        product = "armor_crockpot", -- 唯一id
        atlas = "images/inventoryimages/armor_crockpot.xml",
        image = "armor_crockpot.tex",
        builder_tag = "masterchef",
        builder_skill= nil, -- 可选：指定技能树才能做（技能树指定标签）
        description = "armor_crockpot", -- 描述的id，而非本身
        numtogive = 1,
    }
)
AddRecipeToFilter("armor_crockpot", "CHARACTER")

--========================================================
-- 统一给所有电羊添加替罪羊逻辑
--========================================================
AddPrefabPostInit("lightninggoat", function(goat)
    if not TheWorld.ismastersim then return end

    goat:DoTaskInTime(0, function()
        if goat:HasTag("scapegoat") then
            -- 移除 herd 组件和 herd 标签
            if goat.components.herdmember then
                goat:RemoveComponent("herdmember")
            end
            goat:RemoveTag("herdmember")

            -- 玩家攻击加倍伤害 + 死亡额外掉落羊角
            goat:ListenForEvent("attacked", function(goat, data)
                if data and data.attacker and data.attacker:HasTag("player") then
                    if goat.components.health and not goat.components.health:IsDead() then
                        local dmg = data.damage or 0
                        goat.components.health:DoDelta(-dmg * 3) -- 额外扣除3倍
                    end
                end
            end)

            -- 替罪羊被击杀后可能掉落羊角
            goat:ListenForEvent("death", function(goat, data)
                if math.random() > 0.5 then --技能树控制
                    return
                end
                -- 查找附近玩家
                local x, y, z = goat.Transform:GetWorldPosition()
                local players = TheSim:FindEntities(x, y, z, 10, {"player"})
                for _, player in ipairs(players) do
                    -- 检查是否为沃利并且有技能树
                    if player.prefab == "warly" then
                        -- 掉落一个羊角
                        local horn = SpawnPrefab("lightninggoathorn")
                        if horn then
                            horn.Transform:SetPosition(x, y, z)
                        end
                        break
                    end
                end
            end)

            -- 替罪羊每秒掉血
            goat.components.health:StartRegen(-3, 1)
        end
    end)

    -- 保存替罪羊状态
    local old_OnSave = goat.OnSave
    goat.OnSave = function(goat, data)
        if old_OnSave then old_OnSave(goat, data) end
        if goat:HasTag("scapegoat") then
            data.is_scapegoat = true
        end
    end

    -- 加载替罪羊状态
    local old_OnLoad = goat.OnLoad
    goat.OnLoad = function(goat, data)
        if old_OnLoad then old_OnLoad(goat, data) end
        if data and data.is_scapegoat then
            goat:AddTag("scapegoat")
            if goat.components.herdmember then
                goat:RemoveComponent("herdmember")
            end
            goat:RemoveTag("herdmember")
        end
    end
end)


--========================================================
-- SECTION2: 改造厨师包
--========================================================
-- 定义格子
local containers = require("containers")
local params = containers.params
params.spice_sack =
{
    widget =
    {
        slotpos = {},
        slotbg  = {},
        animbank = "ui_fish_box_5x4",
        animbuild = "ui_fish_box_5x4",
        pos = Vector3(0, 220, 0),
        side_align_tip = 160,
    },
    type = "chest",
    lowpriorityselection = true,
}

for y = 2.5, -0.5, -1 do
    for x = -1, 3 do
        table.insert(params.spice_sack.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
        table.insert(params.spice_sack.widget.slotbg, { image = "preparedfood_slot.tex", atlas = "images/hud2.xml" })
    end
end

function params.spice_sack.itemtestfn(container, item, slot)
    -- Prepared food.
    return item:HasTag("preparedfood") and string.find(item.prefab, "_spice_")
end


-- 用齿轮升级
local function UpgradeSpicePack(inst, doer)
    if doer == nil or doer.prefab ~= "warly" then
        return
    end

    local backpack = inst
    local x, y, z = backpack.Transform:GetWorldPosition()
    if backpack and backpack.prefab == "spicepack" then
        if backpack.components.container ~= nil then
            backpack.components.container:DropEverything()
        end

        -- 最后再安全删除背包本体
        backpack:Remove()
        local newbag = SpawnPrefab("spice_sack")
        if newbag ~= nil then
            newbag.Transform:SetPosition(x, y, z)
            local fx = SpawnPrefab("small_puff")
            if fx then
                fx.Transform:SetPosition(x, y, z)
            end
            doer.SoundEmitter:PlaySound("summerevent/plaza/upgrade_1to2")
            if doer.components.talker then
                doer.components.talker:Say(GetString(doer, "ANNOUNCE_SPICEPACK_UPGRADE"))
            end
        end
    end
end

-- 注册动作
local SPICEPACK_UPGRADE = Action({priority=1, rmb=true, distance=1, mount_valid=true })
SPICEPACK_UPGRADE.id = "SPICEPACK_UPGRADE"
SPICEPACK_UPGRADE.str = STRINGS.ACTIONS.SPICEPACK_UPGRADE
SPICEPACK_UPGRADE.fn = function(act)
    if act.invobject and act.target and act.doer then
        if act.invobject.prefab == "gears" then
            act.invobject.components.stackable:Get():Remove()
            UpgradeSpicePack(act.target, act.doer)
            return true
        end
    end
end
AddAction(SPICEPACK_UPGRADE)

-- 添加使用动作：右键用齿轮升级 技能树控制
AddComponentAction("USEITEM", "spicesacktool", function(inst, doer, target, actions, right)
    if inst.prefab == "gears" and target and target.prefab == "spicepack" and doer.prefab == "warly" then
        table.insert(actions, ACTIONS.SPICEPACK_UPGRADE)
    end
end)

-- 动作动画（修理动作）
AddStategraphActionHandler("wilson", ActionHandler(SPICEPACK_UPGRADE, "dolongaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(SPICEPACK_UPGRADE, "dolongaction"))


-- 安全性：避免非沃利使用
AddPrefabPostInit("gears", function(inst)
    if not TheWorld.ismastersim then
        return
    end
    inst:AddComponent("spicesacktool")
end)
