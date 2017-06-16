PLUGIN.name = "Gathering"
PLUGIN.author = "La Corporativa"
PLUGIN.desc = "Adds resources and ways to get them."
PLUGIN.resEntities = {"nut_tree", "nut_rock"}

nut.config.add("gathering", true, "Whether gathering is active or not.", nil, {
	category = "Gathering"
})

nut.config.add("lifeDrain", 10, "How much life will be drain from the entities that are being gathered.", nil, {
	category = "Gathering",
	data = {min=1, max=200}
})

nut.config.add("treeLife", 150, "How much life the trees will have.", nil, {
	category = "Gathering",
	data = {min=1, max=2000}
})

nut.config.add("rockLife", 100, "How much life the rocks will have.", nil, {
	category = "Gathering",
	data = {min=1, max=2000}
})

local gatherItems = {
	["nut_rock"] = {
		["iron_ore"] = 10,
		["coal"] = 3,
		["sulphur"] = 3,
		["iron_copper"] = 8,
	},
	["nut_tree"] = {
		["wood"] = 15,
	},
}

if SERVER then
	resource.AddWorkshop("152429256")

	function PLUGIN:SaveData()
		local data = {}

		for _, v in pairs(self.resEntities) do
			for _, v2 in ipairs(ents.FindByClass(v)) do
				data[#data + 1] = {v2, v2:GetPos(), v2:GetAngles(), v2:GetModel()}
			end
		end

		self:setData(data)
	end

	function PLUGIN:LoadData()
		local data = self:getData()

		for k, v in ipairs(data) do
			local storage = ents.Create(v[1])
			storage:SetPos(v[2])
			storage:SetAngles(v[3])
			storage:SetModel(v[4])
			storage:SetSolid(SOLID_VPHYSICS)
			storage:PhysicsInit(SOLID_VPHYSICS)
			storage:Spawn()
		end
	end
end

function give(client, item)
	local given = false
	given = client:getChar():getInv():add(item.uniqueID)
	return given
end

function getGatheredItem(client, ent)
	local randomZ = math.Rand(0,100)
	local localProb = 0
	for k, v in pairs(gatherItems[ent:GetClass()]) do
		-- randomZ must be between localProb and the sum of the localProb and the probability of each good
		if localProb <= randomZ and (v+localProb) > randomZ then
			return k
		end
		localProb = localProb + v
	end
	return nil
end

function getItemEntity(item)
	for k, v in SortedPairs(nut.item.list) do
		if (item == v.uniqueID) then
			return v
		end
	end
	return nil
end


netstream.Hook("nut_lc_gather", function(client, ent, tool)
	if (IsValid(ent)) then
		if (ent:GetClass() == "nut_rock" and tool:GetClass() == "hl2_m_pickaxe")
		or (ent:GetClass() == "nut_tree" and tool:GetClass() == "hl2_m_axe") then
			client:EmitSound( Format( "physics/concrete/rock_impact_hard%d.wav",math.random(1, 6)), 80, math.random(150,170))
			ent:SetHealth(ent:Health() - nut.config.get("lifeDrain"))
			if (ent:Health() < 0) then
				ent:Remove()
			end
			local itemID = getGatheredItem(client, ent)
			if (itemID != nil) then
				local itemEntity = getItemEntity(itemID)
				if (give(client, itemEntity)) then
					local gathered = "@lc_youGathered"
					client:notifyLocalized(Format("%s %s!", gathered, itemEntity.name))
				else
					client:notifyLocalized("lc_noSpace")
				end
			end
		end
	end
end)
