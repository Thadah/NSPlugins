local PLUGIN = PLUGIN

AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Item Box [Premium]"
ENT.Category = "International Fleet RP"
ENT.Spawnable = true
ENT.AdminOnly = true

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/Items/item_item_crate.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self.receivers = {}

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(true)
			physObj:Wake()
		end
	end
	
	function ENT:CreateInv(activator)
		local character = activator:getChar()
		nut.item.newInv(character:getID(), "safe."..character:getID(), function(inventory)
			character:setData("safebox", inventory:getID())
		end)
	end
	
	function ENT:getInv(activator)
		local index = activator:getChar():getData("safebox")

		if (index) then
			return nut.item.inventories[index]
		end
	end

	function ENT:RestoreInv(activator)
		local character = activator:getChar()
		local index = character:getData("safebox")
		local inventory = nut.item.inventories[index]
		
		if (index) then
			if (inventory) then
				inventory:sync(activator)
			else
				nut.item.restoreInv(index, PLUGIN.config.width, PLUGIN.config.height, function(inventory)
					inventory:setOwner(character, true)
				end)
			end
		else
			self:CreateInv(activator)
		end
	end
	
	function ENT:OpenInv(activator)
		local index = activator:getChar():getData("safebox")
		

		if (index) then
			netstream.Start(activator, "safeOpen", index)
		else
			self:RestoreInv(activator)
		end
	end
	function ENT:Use(activator)
		self:OpenInv(activator)		
	end
else
	player2 = LocalPlayer()
	if(player2:IsUserGroup("Premium Member")) then
		netstream.Hook("safeOpen", function(index)
			local inventory = nut.item.inventories[index]

			nut.gui.inv1 = vgui.Create("nutInventory")
			nut.gui.inv1:ShowCloseButton(true)

			local inventory2 = LocalPlayer():getChar():getInv()

			if (inventory2) then
				nut.gui.inv1:setInventory(inventory2)
			end

			local panel = vgui.Create("nutInventory")
			panel:ShowCloseButton(true)
			panel:SetTitle("Storage Entity")
			panel:setInventory(inventory)
			panel:MoveLeftOf(nut.gui.inv1, 4)

			panel.OnClose = function(this)
				if (IsValid(nut.gui.inv1) and !IsValid(nut.gui.menu)) then
					nut.gui.inv1:Remove()
				end
			end
			local oldClose = nut.gui.inv1.OnClose

			nut.gui.inv1.OnClose = function()
				if (IsValid(panel) and !IsValid(nut.gui.menu)) then
					panel:Remove()
				end
				-- IDK Why. Just make it sure to not glitch out with other stuffs.
				nut.gui.inv1.OnClose = oldClose
			end

			nut.gui["inv"..index] = panel

		end)

		ENT.DrawEntityInfo = true
		local toScreen = FindMetaTable("Vector").ToScreen
		local colorAlpha = ColorAlpha
		local drawText = nut.util.drawText
		local configGet = nut.config.get

		function ENT:onDrawEntityInfo(alpha)
			local position = toScreen(self.LocalToWorld(self, self.OBBCenter(self)))
			local x, y = position.x, position.y
			local tx, ty = drawText("Storage Entity", x, y, colorAlpha(configGet("color"), alpha), 1, 1, nil, alpha * 2)
		end
		else nut.util.notifyLocalized("Subscribe to a Premium Membership to access this box!")
		end
end
