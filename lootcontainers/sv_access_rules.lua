
local PROHIBITED_ACTIONS = {
	["Equip"] = true,
	["EquipUn"] = true,
}

function PLUGIN:CanPlayerInteractItem(client, action, itemObject, data)
	local inventory = nut.inventory.instances[itemObject.invID]

    if (PROHIBITED_ACTIONS[action]) then
        return false, "forbiddenActionStorage"
    end
end

local MAX_ACTION_DISTANCE = 128
local RULES = {
	ContainerAccessRules = function(inventory, action, context)
		-- Ensure correct storage entity and player.
		local client = context.client
		if (not IsValid(client)) then return end
		local storage = context.storage or client.nutStorageEntity
		if (not IsValid(storage)) then return end
		if (storage:getInv() ~= inventory) then return end

		-- If the player is too far away from storage, then ignore.
		local distance = storage:GetPos():Distance(client:GetPos())
		if (distance > MAX_ACTION_DISTANCE) then return false end

		return true
	end
}

function PLUGIN:StorageInventorySet(storage, inventory)
	inventory:addAccessRule(RULES.ContainerAccessRules)
end

return RULES