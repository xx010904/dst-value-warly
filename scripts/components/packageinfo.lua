local PackageInfo = Class(function(self, inst)
    self.inst = inst
    self.meal = nil
end)

function PackageInfo:SetIcon()
    local meal = self.meal or "frogglebunwich"
    print("[PackageInfo] setting icon for", meal)

    self.inst.inv_image_bg = { image = meal .. ".tex" }
    self.inst.inv_image_bg.atlas = GetInventoryItemAtlas(self.inst.inv_image_bg.image)
    print("[PackageInfo] atlas", self.inst.inv_image_bg.atlas)

    if self.inst.components.inventoryitem then
        self.inst.components.inventoryitem:ChangeImageName("spice_salt_over")
    end
end

function PackageInfo:SetMeal(meal)
    self.meal = meal
    self.inst.mealtype = meal
end

function PackageInfo:GetMeal()
    return self.meal
end

-------------------------------------------------------
-- ✅ 存档保存 / 读档恢复
-------------------------------------------------------
function PackageInfo:OnSave()
    return {
        meal = self.meal,
    }
end

function PackageInfo:OnLoad(data)
    if data and data.meal then
        self.meal = data.meal
        self.inst.mealtype = data.meal
        -- 恢复图标显示
        self:SetIcon()
    end
end

return PackageInfo
