local cooking = require("cooking")

local PackagingStation = Class(function(self, inst)
    self.inst = inst
    self.cookingtask = nil
end)

local function GetCookedResult(container)
    local ingredients = {}
    for k, v in pairs(container.slots) do
        if v and v.prefab then
            table.insert(ingredients, v.prefab)
        end
    end
    -- 使用游戏内已有函数计算结果（调用烹饪表）
    local product, cooktime = cooking.CalculateRecipe("portablecookpot", ingredients)
    return product, cooktime or 2
end

function PackagingStation:StartPackaging(doer)
    if not self.inst.components.container then return end
    local container = self.inst.components.container

    local product, cooktime = GetCookedResult(container)
    if not product then
        doer.components.talker:Say("这些食材似乎配不出什么菜……")
        return
    end

    -- 锁定容器
    container.canbeopened = false
    -- self.inst.AnimState:PlayAnimation("cooking_loop", true)

    -- self.cookingtask = self.inst:DoTaskInTime(cooktime, function()
        container:DestroyContents()

        local pkg = SpawnPrefab("packaged_cookedmeal")
        pkg.components.packageinfo:SetMeal(product)
        pkg.Transform:SetPosition(self.inst.Transform:GetWorldPosition())

        self.inst.AnimState:PlayAnimation("idle")
        container.canbeopened = true
    -- end)
end

return PackagingStation
