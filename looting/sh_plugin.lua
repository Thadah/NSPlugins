PLUGIN.name = "Looting"
PLUGIN.author = "orc, thadah, hikka (fix)"
PLUGIN.desc = "A plugin for dropping player inventory on death."

nut.config.add("lootTime", 50, "Number of seconds before loot disappears.", nil, {data = {min = 1, max = 1000}, category = "Looting"})

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

	--nut.item.newInv(0, "loot-"..math.random(0,9999), function(inventory)
	nut.item.newInv(0, "loot"..ply:getChar():getID(), function(inventory)
		if (IsValid(entity)) then
			inventory:setSize(nut.config.get("invW"), nut.config.get("invH"))
			entity:setInventory(inventory)
		end
	end)

	local items = ply:getChar():getInv():getItems()
	for _, v in pairs(items) do
		if (item:getData("equip")) then
			entity:getInv():add(item.uniqueID)
			item:remove()
		else
			v:transfer(entity:getNetVar("id"))
		end
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

	netstream.Hook("lootExit", function(client, index)
		local entity = client.nutBagEntity

		if (IsValid(entity)) then
			entity.receivers[client] = nil
		end

		client.nutBagEntity = nil

		--local inv = nut.item.inventories[index:getNetVar("id")]
		--local inv = index:getInv():getItems()
		--if inv && #inv < 1 then index.timeToDelete = CurTime() return end
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

			lootingPanelMain = vgui.Create("nutInventory")
			lootingPanelMain:ShowCloseButton(true)
			lootingPanelMain:SetTitle("Loot")
			lootingPanelMain:setInventory(inventory)
			lootingPanelMain:MoveLeftOf(nut.gui.inv1, 4)
			lootingPanelMain.OnClose = function(this)

				if (IsValid(nut.gui.inv1) and !IsValid(nut.gui.menu)) then
					nut.gui.inv1:Remove()
				end

				netstream.Start("lootExit", entity)
			end
			local oldClose = nut.gui.inv1.OnClose
			nut.gui.inv1.OnClose = function()
				if (IsValid(lootingPanelMain) and !IsValid(nut.gui.menu)) then
					lootingPanelMain:Remove()
				end

				netstream.Start("lootExit", entity)
				-- IDK Why. Just make it sure to not glitch out with other stuffs.
				nut.gui.inv1.OnClose = oldClose
			end

			nut.gui["inv"..index] = lootingPanelMain
		end
	end)

	netstream.Hook("closeLootMenuSafe", function()
		if (IsValid(nut.gui.inv1) and !IsValid(nut.gui.menu)) then
			nut.gui.inv1:Remove()
		end
		if (IsValid(lootingPanelMain) and !IsValid(nut.gui.menu)) then
			lootingPanelMain:Remove()
		end
	end)
end
