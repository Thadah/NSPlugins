local PLUGIN = PLUGIN

ENT.Type = "anim"
ENT.PrintName = "Item Container"
ENT.Category = "NutScript"
ENT.Spawnable = false
ENT.isStorageEntity = true
ENT.timeToDelete = 1

function ENT:getInv()
	return nut.inventory.instances[self:getNetVar("id")]
end

function ENT:getStorageInfo()
	self.lowerModel = self.lowerModel or self:GetModel()
	return PLUGIN.containerModel[self.lowerModel]
end
