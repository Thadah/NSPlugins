local PLUGIN = PLUGIN

PLUGIN.name = "Card Readers"
PLUGIN.author = "La Corporativa"
PLUGIN.desc = "Adds card readers with different access levels"
PLUGIN.locks = PLUGIN.locks or {}
if (SERVER) then

	function PLUGIN:SaveData()

		for k, v in pairs( ents.FindByClass("nut_cwureader") ) do
			self.locks[#self.locks + 1] = {reader = "nut_cwureader", position = v:GetPos(), angles = v:GetAngles(), door = v.door}
		end

		for k, v in pairs( ents.FindByClass("nut_comreader") ) do
			self.locks[#self.locks + 1] = {reader = "nut_comreader", position = v:GetPos(), angles = v:GetAngles(), door = v.door}
		end

		for k, v in pairs( ents.FindByClass("nut_admreader") ) do
			self.locks[#self.locks + 1] = {reader = "nut_admreader", position = v:GetPos(), angles = v:GetAngles(), door = v.door}
		end

		for k, v in pairs( ents.FindByClass("nut_nucreader") ) do
			self.locks[#self.locks + 1] = {reader = "nut_nucreader", position = v:GetPos(), angles = v:GetAngles(), door = v.door}
		end

		self:setData(self.locks)
	end

	function PLUGIN:LoadData()
		local lock = self:getData() or {}
		
		for k, v in ipairs(lock) do
			local reader = v.reader
			local position = v.position
			local angles = v.angles
			local door = v.door
			if !door then continue end

			local entity = ents.Create(reader)
				entity:SetPos(position)
				entity:SetAngles(angles)
				entity.door = door
				entity:Spawn()
				
			for _, door in pairs( ents.FindInSphere( door, 5 ) ) do
				if door then
					door:Fire( "close", .1 )
					door:Fire( "lock", .1 )
				end
			end
		end
	end
end

local function IsDoor(entity)
	return string.find(entity:GetClass(), "door")
end

nut.command.add("addlock", {
	adminOnly = true,
	onRun = function(client)
		tr = {}
		tr.start = client:GetShootPos()
		tr.endpos = tr.start + client:GetAimVector() * 200
		tr.filter = client
		trace = util.TraceHull(tr)

		lock = trace.Entity
		
		if (!client:GetVar("lock")) then
			if (lock:IsValid() and (lock:GetClass() == "nut_cwureader" or lock:GetClass() == "nut_specreader" or lock:GetClass() == "nut_comreader" or lock:GetClass() == "nut_nucreader" or lock:GetClass() == "nut_admreader")) then
				client:setNetVar("lock", lock)
				return "@validDoor"
			end
		else
			if trace.Entity:IsValid() and IsDoor(lock) then
				
				local ourLock = client:getNetVar("lock")
				ourLock.door = lock:GetPos()
				
				client:setNetVar("lock", nil)
				return "@readerAdded"
			else
				client:setNetVar("lock", nil)
				return "@valuesRestored"
			end
		end
	
	end
})