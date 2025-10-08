local SadowHookTool = Class(function(self, inst)
	self.inst = inst
	inst:AddTag("shadowhooktool")
end)

function SadowHookTool:OnRemoveFromEntity()
    self.inst:RemoveTag("shadowhooktool")
end

return SadowHookTool
