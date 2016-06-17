PLUGIN.name = "Looting"
PLUGIN.author = "orc, thadah"
PLUGIN.desc = "A plugin for dropping player inventory on death."

nut.config.add("lootTime", 100, "Number of seconds before loot disappears.", nil, {data = {min = 1, max = 1000}, category = "Looting"})

-- note nut_container does not exist in 1.1 so alter that

function PLUGIN:PlayerDeath( ply, dmg, att )
	local entity = ents.Create("nut_loot") --** Create World Container that should not be saved in the server.
		entity:SetPos( ply:GetPos() + Vector( 0, 0, 10 ) )
		entity:SetAngles(entity:GetAngles())
		entity:Spawn()
		entity:setNetVar("name", "Belongings" ) --** Yup.
		entity:setNetVar( "max", 5000 )
		entity:SetModel("models/props_junk/garbage_bag001a.mdl")
		entity:SetSolid(SOLID_VPHYSICS)
		entity:PhysicsInit(SOLID_VPHYSICS)

		local physObj = entity:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(true)
			physObj:Wake()
		end
		
	local invName = "loot-"..math.random(0,9999) --++Just in case it is needed somewhere
	local plyInv = ply:getChar():getInv()

	nut.item.newInv(0, invName, function(inventory)
		if (IsValid(entity)) then
			inventory:setSize(6, 4)
			entity:setInventory(inventory)
		end
	end)

	local items = plyInv:getItems()
	local entInv = entity:getInv()

	for _, v in pairs(items) do
		v:transfer(entity:getNetVar("id"))
	end

	ply:StripAmmo() --** This is Normal.

end



if (SERVER) then

	function PLUGIN:saveLoot()
		local data = {}

		for k, v in ipairs(ents.FindByClass("nut_loot")) do
			if (v:getInv()) then
				data[#data + 1] = {v:GetPos(), v:GetAngles(), v:getNetVar("id"), v:GetModel()}
			end
		end

		self:setData(data)
	end

	function PLUGIN:loadLoot()
		local data = self:getData() or {}

		if (data) then
			for k, v in ipairs(data) do
				local container = ents.Create("nut_loot")
				container:SetPos(v[1])
				container:SetAngles(v[2])
				container:Spawn()
				container:SetModel(v[3])
				container:SetSolid(SOLID_VPHYSICS)
				container:PhysicsInit(SOLID_VPHYSICS)
				
				local physObject = container:GetPhysicsObject()

				if (physObject) then
					physObject:EnableMotion()
				end
			end
		end
	end

	function PLUGIN:SaveData()
		self:saveLoot()
	end

	function PLUGIN:LoadData()
		self:loadLoot()
	end
	
	function PLUGIN:LootItemRemoved(entity, inventory)
		self:saveLoot()
	end

	function PLUGIN:LootCanTransfer(inventory, client, oldX, oldY, x, y, newInvID)
		local inventory2 = nut.item.inventories[newInvID]

		print(inventory2)
	end

	netstream.Hook("lootExit", function(client)
		local entity = client.nutBagEntity

		if (IsValid(entity)) then
			entity.receivers[client] = nil
		end

		client.nutBagEntity = nil
	end)

else
	netstream.Hook("lootOpen", function(entity, index)
		local inventory = nut.item.inventories[index]

		if (IsValid(entity) and inventory and inventory.slots) then
			nut.gui.inv1 = vgui.Create("nutInventory")
			nut.gui.inv1:ShowCloseButton(true)

			local inventory2 = LocalPlayer():getChar():getInv()

			if (inventory2) then
				nut.gui.inv1:setInventory(inventory2)
			end

			local panel = vgui.Create("nutInventory")
			panel:ShowCloseButton(true)
			panel:SetTitle("Belongings")
			panel:setInventory(inventory)
			panel:MoveLeftOf(nut.gui.inv1, 4)
			panel.OnClose = function(this)

				if (IsValid(nut.gui.inv1) and !IsValid(nut.gui.menu)) then
					nut.gui.inv1:Remove()
				end

				netstream.Start("lootExit")
			end
			local oldClose = nut.gui.inv1.OnClose
			nut.gui.inv1.OnClose = function()
				if (IsValid(panel) and !IsValid(nut.gui.menu)) then
					panel:Remove()
				end

				netstream.Start("lootExit")
				-- IDK Why. Just make it sure to not glitch out with other stuffs.
				nut.gui.inv1.OnClose = oldClose
			end

			nut.gui["inv"..index] = panel
		end
	end)
end