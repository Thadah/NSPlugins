
net.Receive("nutStorageOpen", function()
	local entity = net.ReadEntity()
	local inventory = entity:getInv()
	local inventory2 = LocalPlayer():getChar():getInv()
	if (not inventory) then return false end

	local panel = nut.gui["inv"..inventory:getID()]
	local panel2 = nut.gui["inv"..inventory2:getID()]
	local parent = entity.invID and nut.gui["inv"..entity.invID] or nil

	if (IsValid(panel)) then
		panel:Remove()
	end

	if (IsValid(panel2)) then
		panel2:Remove()
	end

	if (inventory) then
		local panel = nut.inventory.show(inventory, parent)
		local panel2 = nut.inventory.show(inventory2, parent)
		if (IsValid(panel)) then
			panel:ShowCloseButton(true)
			panel:SetTitle("Container")
			panel:MoveTo(ScrW() / 1.425 - panel:GetWide(), ScrH() / 2 - panel:GetTall() / 2, 0, 0, -1, function()
				panel2:SetTitle("Inventory")
				panel2:MoveLeftOf(panel, 4)
			end)
			panel.OnClose = function()
				if (IsValid(panel2)) then
					panel2:Remove()
				end
			end
		end
	else
		local itemID = entity:getID()
		local index = entity:getData("id", "nil")
		ErrorNoHalt(
			"Invalid inventory "..index.." for bag entity "..itemID.."\n"
		)
	end
	return false
end)

net.Receive("nutDisplayContSpawnPoints", function()
	local points = net.ReadTable()
	for k, v in pairs(points) do
		local emitter = ParticleEmitter( v[1] )
		local smoke = emitter:Add( "sprites/glow04_noz", v[1] )
		smoke:SetVelocity( Vector( 0, 0, 1 ) )
		smoke:SetDieTime(15)
		smoke:SetStartAlpha(255)
		smoke:SetEndAlpha(255)
		smoke:SetStartSize(64)
		smoke:SetEndSize(64)
		smoke:SetColor(255,0,0)
		smoke:SetAirResistance(300)
	end
end)


function PLUGIN:exitStorage()
	net.Start("nutStorageExit")
	net.SendToServer()
end

