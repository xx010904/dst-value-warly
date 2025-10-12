local ShadowHookTool = Class(function(self, inst)
	self.inst = inst
	inst:AddTag("shadowhooktool")
end)

function ShadowHookTool:OnRemoveFromEntity()
    self.inst:RemoveTag("shadowhooktool")
end

return ShadowHookTool
