local ActiveSpoiledCloudTool = Class(function(self, inst)
	self.inst = inst
	inst:AddTag("activespoiledcloudtool")
end)

function ActiveSpoiledCloudTool:OnRemoveFromEntity()
    self.inst:RemoveTag("activespoiledcloudtool")
end

return ActiveSpoiledCloudTool
