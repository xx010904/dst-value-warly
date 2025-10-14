local SpiceSackTool = Class(function(self, inst)
	self.inst = inst
	inst:AddTag("spicesacktool")
end)

function SpiceSackTool:OnRemoveFromEntity()
    self.inst:RemoveTag("spicesacktool")
end

return SpiceSackTool
