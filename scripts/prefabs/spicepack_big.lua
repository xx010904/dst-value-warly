local chefPouchBuffDuration = warlyvalueconfig.chefPouchBuffDuration or 10
local chefPouchSpiceSanMultiplier = warlyvalueconfig.chefPouchSpiceSanMultiplier or 1

local function onequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol(
            "backpack", skin_build, "backpack", inst.GUID, "swap_chefpack"
        )
        owner.AnimState:OverrideItemSkinSymbol(
            "swap_body", skin_build, "swap_body", inst.GUID, "swap_chefpack"
        )
    else
        owner.AnimState:OverrideSymbol("backpack", "swap_chefpack", "backpack")
        owner.AnimState:OverrideSymbol("swap_body", "swap_chefpack", "swap_body")
    end

    if inst.components.container ~= nil then
        inst.components.container:Open(owner)
    end
end

local function onunequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner.AnimState:ClearOverrideSymbol("backpack")

    if inst.components.container ~= nil then
        inst.components.container:Close(owner)
    end
end

local function onequiptomodel(inst, owner)
    if inst.components.container ~= nil then
        inst.components.container:Close(owner)
    end
end

local function onburnt(inst)
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
        inst.components.container:Close()
    end

    SpawnPrefab("ash").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end

local function onignite(inst)
    if inst.components.container ~= nil then
        inst.components.container.canbeopened = false
    end
end

local function onextinguish(inst)
    if inst.components.container ~= nil then
        inst.components.container.canbeopened = true
    end
end

local function onperish(inst)
    local skin_build, skin_id = inst:GetSkinBuild(), inst.skin_id
    if skin_build == nil or skin_build == "" or skin_id == 0 then
        skin_build, skin_id = nil, nil
    end

    local small_pack = SpawnPrefab("spicepack", skin_build, skin_id)
    small_pack.Transform:SetPosition(inst.Transform:GetWorldPosition())
    Launch(small_pack, inst, 0.1)

    -- 转移物品
    if inst.components.container and small_pack.components.container then
        local old_container = inst.components.container
        local new_container = small_pack.components.container

        local items = old_container:GetAllItems()
        for _, item in ipairs(items) do
            if item:IsValid() then
                old_container:RemoveItem(item, true)
                local success = new_container:GiveItem(item)
                if not success then
                    item.Transform:SetPosition(inst.Transform:GetWorldPosition())
                    Launch(item, item, 0.1)
                end
            end
        end
    end

    -- 如果有 owner，把新包放到 owner 背包里
    local owner = inst.components.inventoryitem and inst.components.inventoryitem:GetGrandOwner()
    if owner and owner.components.inventory and inst.components.equippable then
        owner.components.inventory:Unequip(inst.components.equippable.equipslot)
        owner.components.inventory:Equip(small_pack)
    else
        small_pack.Transform:SetPosition(inst.Transform:GetWorldPosition())
        Launch(small_pack, small_pack, 0.1)
    end

    inst:Remove()
end

local function InitSanityAura(inst)
    -- 大厨师包定期检测owner和容器内容
    inst:DoPeriodicTask(0.25, function(inst)
        local container = inst.components.container
        local equippable = inst.components.equippable
        if not container or not equippable then
            return
        end

        local owner = inst.components.inventoryitem and inst.components.inventoryitem:GetGrandOwner()
        if not (owner and owner:HasTag("player")) then
            equippable.dapperness = 0
            return
        end

        local hasSkill = owner.components.skilltreeupdater and
            owner.components.skilltreeupdater:IsActivated("warly_spicepack_upgrade")

        if not hasSkill then
            equippable.dapperness = 0
            return
        end

        local food_count = {}
        for k = 1, container.numslots do
            local item = container:GetItemInSlot(k)
            if item and item:HasTag("spicedfood") and string.find(item.prefab, "spice_") then
                local prefab = item.prefab
                local count = item.components.stackable and item.components.stackable:StackSize() or 1
                food_count[prefab] = (food_count[prefab] or 0) + count
                -- print(string.format("[SpicePack] Slot %d 检测到调料食物: %s (数量 %d)", k, prefab, count))
            end
        end

        local total = 0
        for prefab, count in pairs(food_count) do
            -- 计算递增加成，最多算40个
            local capped = math.min(count, 40)
            local extra = (capped - 1) * 0.05
            total = total + 1 + extra

            -- print(string.format(
            --     "[SpicePack] 食物种类: %s ×%d → capped=%d → 计入 %.2f",
            --     prefab, count, capped, 1 + extra
            -- ))
        end

        local dapper = TUNING.DAPPERNESS_TINY * chefPouchSpiceSanMultiplier * total
        equippable.dapperness = dapper
        -- print(string.format("[SpicePack] 总加成种类数: %.2f，对应理智恢复: %.2f", total, dapper))
    end)
end

--------------------------------------------------------------------------

local function MakeChefPack(name, perish_time)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("backpack1")
        inst.AnimState:SetBuild("swap_chefpack")
        inst.AnimState:PlayAnimation("anim")

        inst.MiniMapEntity:SetIcon("spicepack.png")

        inst:AddTag("backpack")
        inst:AddTag("nocool")
        inst:AddTag("show_spoilage")

        inst.foleysound = "dontstarve/movement/foley/backpack"

        MakeInventoryFloatable(inst, "small", 0.15, 0.85)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.cangoincontainer = false
        inst.components.inventoryitem.imagename = "spicepack"
        inst.components.inventoryitem.atlasname = "images/inventoryimages3.xml"

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.BODY
        inst.components.equippable:SetOnEquip(onequip)
        inst.components.equippable:SetOnUnequip(onunequip)
        inst.components.equippable:SetOnEquipToModel(onequiptomodel)

        inst:AddComponent("container")
        inst.components.container:WidgetSetup(name)

        -- ⭐ 新鲜度组件
        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(perish_time * TUNING.TOTAL_DAY_TIME)
        inst.components.perishable:StartPerishing()
        inst.components.perishable:SetOnPerishFn(onperish)

        inst:AddComponent("preserver")
        inst.components.preserver:SetPerishRateMultiplier(TUNING.PERISH_FOOD_PRESERVER_MULT)

        -- 不同的效果
        if name == "spicepack_chili" then
            -- 辣椒保暖
            if inst.components.insulator == nil then
                inst:AddComponent("insulator")
            end
            inst.components.insulator:SetWinter()
            inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE * 2)
        elseif name == "spicepack_garlic" then
            -- 蒜粉防水防沙
            inst:AddTag("goggles")
            inst:AddComponent("waterproofer")
        elseif name == "spicepack_salt" then
            -- 盐保鲜倍率
            inst.components.preserver:SetPerishRateMultiplier(TUNING.BEARGERFUR_SACK_PRESERVER_RATE)
        elseif name == "spicepack_sugar" then
            -- 甜加移速
            inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT
        end


        InitSanityAura(inst)

        MakeSmallBurnable(inst)
        MakeSmallPropagator(inst)
        inst.components.burnable:SetOnBurntFn(onburnt)
        inst.components.burnable:SetOnIgniteFn(onignite)
        inst.components.burnable:SetOnExtinguishFn(onextinguish)

        MakeHauntableLaunchAndDropFirstItem(inst)

        return inst
    end

    return Prefab(name, fn)
end

--------------------------------------------------------------------------

return
    MakeChefPack("spicepack_chili", chefPouchBuffDuration),  -- 辣
    MakeChefPack("spicepack_salt", chefPouchBuffDuration),   -- 咸
    MakeChefPack("spicepack_garlic", chefPouchBuffDuration), -- 蒜香
    MakeChefPack("spicepack_sugar", chefPouchBuffDuration)   -- 甜
