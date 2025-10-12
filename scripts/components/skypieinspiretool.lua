local SkyPieInspireTool = Class(function(self, inst)
	self.inst = inst
	inst:AddTag("skypieinspiretool")
end)

function SkyPieInspireTool:OnRemoveFromEntity()
    self.inst:RemoveTag("skypieinspiretool")
end

return SkyPieInspireTool
