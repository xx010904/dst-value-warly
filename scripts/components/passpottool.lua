local PassPotTool = Class(function(self, inst)
	self.inst = inst
	inst:AddTag("passpottool")
end)

function PassPotTool:OnRemoveFromEntity()
    self.inst:RemoveTag("passpottool")
end

return PassPotTool
