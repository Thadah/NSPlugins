local PLUGIN = PLUGIN

PLUGIN.name = "Loot Containers"
PLUGIN.author = "Chessnut, Thadah Denyse"
PLUGIN.desc = "Spawns different containers that can be looted"

nut.util.include("sv_containers.lua")
nut.util.include("sv_networking.lua")
nut.util.include("sv_access_rules.lua")
nut.util.include("sh_rarity.lua")
nut.util.include("sh_categories.lua")
nut.util.include("sh_containermodels.lua")
nut.util.include("cl_networking.lua")

nut.config.add("lootEnabled", true, "Whether or not Loot Containers is enabled.", nil, {category = "Loot Containers"})
nut.config.add("lootPersistentCointainers", true, "Whether or not the containers will survive server restarts.", nil, {category="Loot Containers"})
nut.config.add("lootCount", 2, "Number of items each container will have inside.", nil, {data = {min = 1, max = 20}, category = "Loot Containers"})
nut.config.add("lootMaxContainerSpawn", 1, "Number of containers each spawn will have.", nil, {data = {min = 1, max = 50}, category = "Loot Containers"})
nut.config.add("lootMaxWorldContainers", 6, "Number of containers the World will have.", nil, {data = {min = 1, max = 20}, category = "Loot Containers"})
nut.config.add("lootContainerTime", 20, "How much time it will take for a container to spawn.", nil, {data = {min = 1, max = 86400}, category = "Loot Containers"})
nut.config.add("lootContainerDeathTime", 120, "How much time it will take for a container to dissapear (in seconds).", nil, {data = {min = 10, max = 84600}, category = "Loot Containers"})

PLUGIN.spawnedContainers = PLUGIN.spawnedContainers or {}
PLUGIN.contPoints = PLUGIN.contPoints or {}

if (CLIENT) then
	function PLUGIN:transferItem(itemID)
		if (not nut.item.instances[itemID]) then return end
		net.Start("nutStorageTransfer")
			net.WriteUInt(itemID, 32)
		net.SendToServer()
	end
end

nut.command.add("lootaddspawn", {
	adminOnly = true,
	syntax = "<path model>",
	onRun = function(client, arguments)
		local trace = client:GetEyeTraceNoCursor()
		local hitpos = trace.HitPos + trace.HitNormal*5
		local model = arguments[1] or "models/props_lab/filecabinet02.mdl"
		table.insert(PLUGIN.contPoints, {hitpos, model})
		client:notify("You've added a new container spawner")
	end
})

nut.command.add("lootremovespawn", {
	adminOnly = true,
	syntax = "<number distance>",
	onRun = function(client, arguments)
		local trace = client:GetEyeTraceNoCursor()
		local hitpos = trace.HitPos + trace.HitNormal*5
		local range = arguments[1] or 128
		local count = 0
		for k, v in pairs(PLUGIN.contPoints) do
			PLUGIN.contPoints[k] = nil
			local distance = v[1]:Distance(hitpos)
			if distance <= tonumber(range) then
				PLUGIN.contPoints[k] = nil
				count = count+1
			end
		end
		PLUGIN:saveStorage()
		client:notify(count.." spawners have been removed")
	end
})


nut.command.add("lootdisplayspawn", {
	adminOnly = true,
	onRun = function(client)
		if SERVER then
			net.Start("nutDisplayContSpawnPoints")
				net.WriteTable(PLUGIN.contPoints)
			net.Send(client)
			client:notify("Displaying all container spawnpoints for 15 seconds")
		end
	end
})