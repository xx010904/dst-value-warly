local ConverSpiceTool = Class(function(self, inst)
	self.inst = inst
	inst:AddTag("converspicetool")
end)

function ConverSpiceTool:OnRemoveFromEntity()
    self.inst:RemoveTag("converspicetool")
end

return ConverSpiceTool
