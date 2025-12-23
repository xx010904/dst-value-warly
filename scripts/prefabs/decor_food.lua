local function CloneDecorFoodAppearance(src)
    if not (src and src.mimic_food) then
        print("[DecorFoodClone] 没有 mimic_food，复制失败")
        src.mimic_food = "meatballs"
    end

    local restore_skill = src.restore_skill
    local foodname = src.mimic_food
    local food_symbol_build = src.food_symbol_build or "cook_pot_food"
    local food_basename = src.food_basename or foodname
    local spicename = src.spicename
    local uses_left = src.uses_left

    -- print("[DecorFoodClone] 拷贝外观:", foodname, food_symbol_build, food_basename, "spice:", spicename)

    -- 生成一个新的 decor_food
    local decor = SpawnPrefab("decor_food")
    if not decor then
        print("[DecorFoodClone] SpawnPrefab 失败")
        return nil
    end

    -- 复制 build/bank/调料
    if spicename ~= nil then
        decor.AnimState:SetBuild("plate_food")
        decor.AnimState:SetBank("plate_food")
        decor.AnimState:OverrideSymbol("swap_garnish", "spices", spicename)
        decor:AddTag("spicedfood")
    else
        decor.AnimState:SetBuild(food_symbol_build or "cook_pot_food")
        decor.AnimState:SetBank("cook_pot_food")
    end

    -- 复制食物符号
    decor.AnimState:OverrideSymbol("swap_food", food_symbol_build or "cook_pot_food", food_basename or foodname)

    -- 保留 mimic 信息（方便下次克隆或下线还原）
    decor.restore_skill = restore_skill
    decor.mimic_food = foodname
    decor.food_symbol_build = food_symbol_build
    decor.food_basename = food_basename
    decor.spicename = spicename
    decor.uses_left = uses_left

    -- 拷贝颜色、缩放（如果原 decor 有这些属性）
    -- if src.AnimState then
    --     local r, g, b, a = src.AnimState:GetMultColour()
    --     decor.AnimState:SetMultColour(r, g, b, a)
    --     decor.Transform:SetScale(src.Transform:GetScale())
    -- end

    return decor
end

local function TryFindNearbyTable(inst, doer)
    local link_table = inst.link_table
    -- print("有绑定的桌子，放回去")
    if link_table == nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        local tables = TheSim:FindEntities(x, y, z, 3.5, { "decortable", "structure" }, { "hasfurnituredecoritem" })
        -- print("找到空桌子", #tables)
        for _, table in ipairs(tables) do
            if table and table.components.furnituredecortaker then
                link_table = table
            end
        end
    end
    -- 补充逻辑：有桌子在附近
    if link_table then
        local newDecor = CloneDecorFoodAppearance(inst)
        if newDecor then
            link_table.components.furnituredecortaker:AcceptDecor(newDecor, doer)
            if newDecor.Follower then newDecor.Follower:FollowSymbol(link_table.GUID, "swap_object") end
            -- print("接受回decor食物", newDecor.prefab, doer.prefab)
            return true
        end
    end
    return false
end

local function ApplyFoodDirectly(owner, food)
    if not (owner and food and food.components and food.components.edible) then
        return
    end

    local edible = food.components.edible

    -- 饥饿
    local hunger = edible.hungervalue or 0
    if owner.components.hunger then
        owner.components.hunger:DoDelta(hunger, true) -- true = ignore modifiers
    end

    -- 生命
    local health = edible.healthvalue or 0
    if owner.components.health then
        owner.components.health:DoDelta(health)
    end

    -- 理智
    local sanity = edible.sanityvalue or 0
    if owner.components.sanity then
        owner.components.sanity:DoDelta(sanity)
    end
end

local function EatMimicFood(inst, owner)
    if not (owner and owner.components and owner.components.eater) then
        return
    end

    if not inst or not inst:IsValid() then
        return
    end

    local foodname = inst.mimic_food or "meatballs"
    local food = SpawnPrefab(foodname)
    if not food then
        -- 如果没有对应prefab，生成一个空壳dummy防报错
        food = SpawnPrefab("meatballs")
    end

    if not food.components.edible then
        return
    end

    local veryStarve = false
    if owner and owner.components.hunger then
        local hunger_percent = owner.components.hunger:GetPercent()
        local threshold = 0.33 -- 饿到说话
        -- 技能树控制，沃利随时享受这个持续buff，但是只点1级，他放的食物没有buff
        -- if owner:HasTag("warly_true_delicious_desk") then
        --     threshold = 1.1
        -- end
        if hunger_percent < threshold then
            -- print(string.format("饥饿触发：%s 当前%.2f%% < %.0f%%阈值", owner.prefab, hunger_percent * 100, threshold * 100))
            veryStarve = true
            if food and food.components.edible then
                food.components.edible.foodtype = FOODTYPE.GOODIES
            end
        end
    end

    -- 防止被吃完前触发掉落
    food.persists = false

    local success = owner.components.eater:PrefersToEat(food)
    if success then
        -- 直接加属性，而不是吃，解决一切挑食问题
        ApplyFoodDirectly(owner, food)
        food.components.edible.healthvalue = 0
        food.components.edible.hungervalue = 0
        food.components.edible.sanityvalue = 0
        -- 吃一个为了触发buff
        owner.components.eater:Eat(food)
        -- print("餐桌模拟食物使用成功", owner.prefab, food.prefab)
        -- 太饿的时候吃会有额外动作和台词
        SpawnPrefab("winters_feast_depletefood").Transform:SetPosition(owner.Transform:GetWorldPosition())
        if veryStarve then
            owner:DoTaskInTime(0, function()
                if owner.components.talker then
                    owner.components.talker:Say(GetString(owner, "ANNOUNCE_TRUE_DELICIOUS"))
                end
                owner.AnimState:PlayAnimation("feast_eat_pre_pre")
                owner.AnimState:PushAnimation("feast_eat_pre", false)
                owner.AnimState:PushAnimation("feast_eat_loop", false)
                owner.AnimState:PushAnimation("feast_eat_loop", false)
                owner.AnimState:PushAnimation("feast_eat_pst", false)
            end)
        else
            owner.AnimState:PlayAnimation("eat_pre")
            owner.AnimState:PushAnimation("eat", false)
        end
        -- 技能树控制食物是否有持续buff
        if inst.restore_skill then
            local hasSkill = owner.components.skilltreeupdater and
                owner.components.skilltreeupdater:IsActivated("warly_true_delicious_restore")
            if hasSkill then
                local buff_food = inst.food_basename or inst.mimic_food
                local buff_name = buff_food .. "warly_truedelicious_buff"
                owner:AddDebuff(buff_name, "warly_truedelicious_buff")
                local truedelicious_buff = owner:GetDebuff(buff_name)
                if truedelicious_buff then
                    truedelicious_buff.foodPrefab = buff_food
                end
                SpawnPrefab("spider_heal_target_fx").entity:SetParent(owner.entity)
            end
        end
        inst.uses_left = inst.uses_left - 1
    else
        -- print("餐桌模拟食物使用失败", owner.prefab, food.prefab)
        if owner.components.talker then
            owner.components.talker:Say(GetString(owner, "ANNOUNCE_FALSE_DELICIOUS"))
        end
        owner.sg:GoToState("refuseeat")
    end
    -- 尝试放回桌子
    if inst.uses_left > 0 then
        local isback = TryFindNearbyTable(inst, owner)
        -- if not isback then
        --     local newDecor = CloneDecorFoodAppearance(inst)
        --     if newDecor then
        --         -- print("没找到桌子，重新生成一个丢地上", newDecor.mimic_food)
        --         newDecor.Transform:SetPosition(owner.Transform:GetWorldPosition())
        --         Launch(newDecor, owner)
        --     end
        -- end
    end
    if food then
        food:Remove()
    end
    -- 安全删除，延迟一点给客户端感知的机会
    if inst and inst:IsValid() then
        inst:DoTaskInTime(FRAMES, function()
            if inst:IsValid() then
                inst:Remove()
            end
        end)
    end
end

local function OnPutInInventory(inst, owner)
    if inst._already_consumed then
        return
    end
    inst._already_consumed = true
    inst:DoTaskInTime(0, function()
        EatMimicFood(inst, owner)
    end)
end

local function OnDropped(inst)
    inst._already_consumed = false
    -- 安全删除，延迟一点给客户端感知的机会
    if inst and inst:IsValid() then
        inst:DoTaskInTime(1, function()
            if inst:IsValid() then
                local rot = SpawnPrefab("spoiled_food")
                rot.Transform:SetPosition(inst.Transform:GetWorldPosition())
                if inst.uses_left and inst.uses_left > 0 and rot.components.stackable then
                    rot.components.stackable:SetStackSize(inst.uses_left or 1)
                end
                Launch(rot, inst, 1)
                inst:Remove()
            end
        end)
    end
end

local function OnSave(inst, data)
    data.restore_skill = inst.restore_skill
    data.mimic_food = inst.mimic_food
    data.food_symbol_build = inst.food_symbol_build
    data.spicename = inst.spicename
    data.food_basename = inst.food_basename
    if inst.uses_left then
        data.uses_left = inst.uses_left
    end
end

local function OnLoad(inst, data)
    if data then
        inst.restore_skill = data.restore_skill
        inst.mimic_food = data.mimic_food
        inst.food_symbol_build = data.food_symbol_build
        inst.spicename = data.spicename
        inst.food_basename = data.food_basename
        inst.uses_left = data.uses_left or 1
    end
end

local function InitName(inst)
    local realName = STRINGS.NAMES.DECOR_FOOD or "Food Decoration"

    if inst.mimic_food then
        if inst.spicename then
            local spice_key = string.upper(inst.spicename .. "_FOOD")
            local food_key = string.upper(inst.food_basename or inst.mimic_food)

            local spice_str = STRINGS.NAMES[spice_key]
            local food_str = STRINGS.NAMES[food_key]

            -- 防止 nil
            if not spice_str then
                -- print("[SetName] 警告: 找不到调料字符串", spice_key)
                spice_str = spice_key
            end
            if not food_str then
                -- print("[SetName] 警告: 找不到食物字符串", food_key)
                food_str = food_key
            end

            realName = subfmt(spice_str, { food = food_str })
            -- print("[SetName] 设置自定义名字（有调料）", realName)
        else
            local food_key = string.upper(inst.mimic_food)
            local food_str = STRINGS.NAMES[food_key] or inst.mimic_food
            realName = food_str
            -- print("[SetName] 设置自定义名字（无调料）", realName)
        end
        -- 补上次数
        if inst.uses_left and inst.uses_left > 1 then
            realName = realName .. "(" .. inst.uses_left .. ")"
        end
    else
        print("[SetName] mimic_food 为 nil，使用默认名字", realName)
    end

    if inst.components.named then
        inst.components.named:SetName(realName)
    end
end

local function Initial(inst)
    -- ✅初始化绑定的桌子
    local x, y, z = inst.Transform:GetWorldPosition()
    local tables = TheSim:FindEntities(x, y, z, 2, { "decortable", "structure" })

    if #tables > 0 then
        local found = false
        for _, tbl in ipairs(tables) do
            if tbl.components.furnituredecortaker and tbl.components.furnituredecortaker.decor_item then
                if tbl.components.furnituredecortaker.decor_item == inst then
                    inst.link_table = tbl
                    found = true
                    -- print(string.format("[DecorLink] 成功绑定到桌子: %s, 位置(%.2f, %.2f, %.2f)", tostring(tbl.prefab), tbl.Transform:GetWorldPosition()))
                    break
                end
            end
        end
        if not found then
            -- print("[DecorLink] 找到桌子但没有匹配的 decor_item，准备删除")
            inst:Remove()
            return
        end
    else
        -- print("[DecorLink] 附近没有桌子，删除 decor_food")
        inst:Remove()
        return
    end

    -- ✅初始化名字
    InitName(inst)

    -- ✅同时设置外观
    if inst.mimic_food then
        if inst.spicename then
            inst.AnimState:SetBuild("plate_food")
            inst.AnimState:SetBank("plate_food")
            inst.AnimState:OverrideSymbol("swap_garnish", "spices", inst.spicename)
            inst:AddTag("spicedfood")
        else
            inst.AnimState:SetBuild(inst.food_symbol_build or "cook_pot_food")
            inst.AnimState:SetBank("cook_pot_food")
        end
    end
    inst.AnimState:OverrideSymbol("swap_food", inst.food_symbol_build or "cook_pot_food",
        inst.food_basename or inst.mimic_food)

    -- 播放特效
    if inst.restore_skill then
        SpawnPrefab("carnival_sparkle_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
    SpawnPrefab("winters_feast_depletefood").Transform:SetPosition(inst.Transform:GetWorldPosition())
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("cook_pot_food")
    inst.AnimState:SetBuild("cook_pot_food")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:OverrideSymbol("swap_food", "cook_pot_food", "meatballs")

    inst:AddTag("furnituredecor")
    inst:AddTag("_named")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:RemoveTag("_named")
    inst:AddComponent("named")

    inst:AddComponent("furnituredecor")

    inst.restore_skill = false
    inst.mimic_food = "meatballs"
    inst.food_symbol_build = ""
    inst.food_basename = ""
    inst.spicename = ""

    local function GetUsesLeft()
        local uses = 1                      -- 保底 1
        if math.random() < 0.5 then         -- 50%概率触发 2
            uses = 2
            if math.random() < 0.5 then     -- 25% 概率触发 3 （0.5*0.5）
                uses = 3
                if math.random() < 0.5 then -- 12.5% 概率触发 4 （0.5*0.5*0.5）
                    uses = 4
                end
            end
        end
        return uses
    end
    inst.uses_left = GetUsesLeft()

    inst:AddComponent("inspectable")

    local inventoryitem = inst:AddComponent("inventoryitem")
    -- inst.components.inventoryitem.imagename = "meatballs"
    -- inst.components.inventoryitem.atlasname = "images/inventoryimages2.xml"

    -- 监听进入物品栏事件
    inst:ListenForEvent("onputininventory", function(inst, owner)
        OnPutInInventory(inst, owner)
    end)

    -- 掉落时重置状态
    inst:ListenForEvent("ondropped", OnDropped)

    inst:DoTaskInTime(0, Initial)

    inst.InitName = InitName

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("decor_food", fn)
