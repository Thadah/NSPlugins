ENT.Base = "nut_readerbase"
ENT.Type = "anim"
ENT.PrintName = "Magnetic Card Reader - Level 2"
ENT.Author = "La Corporativa"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript"
ENT.Level = "Level 2"

if (SERVER) then

	util.AddNetworkString("nut_CardVerification")

	function ENT:Use(activator)
		if !activator.nextUse or activator.nextUse < CurTime() then
			net.Start( "nut_CardVerification" )
				net.WriteEntity( self )

				local inventory = activator:getChar():getInv()
				
				if inventory:hasItem("comkey") or inventory:hasItem("admkey") or inventory:hasItem("nuckey") then
					net.WriteFloat( 2 )
					if self.door then
						for _, door in pairs( ents.FindInSphere( self.door, 5 ) ) do
							if door then
								door:Fire( "unlock", .1 )
								door:Fire( "open", .1 )
								timer.Simple(4, function()
									door:Fire( "close", .1 )
									door:Fire( "lock", .1 )
								end)
							end
						end
					end
				else
					net.WriteFloat( 1 )
				end
			net.Broadcast()
			activator.nextUse = CurTime() + 1
		end
	end
	
else
	/*
	curstat = {
	[0] = { "Nivel 2", { 90, 150, 170 } },
	[1] = { "Denegado", { 150, 20, 20 }, "buttons/combine_button2.wav" },
	[2] = { "Concedido", { 90, 150, 100 }, "buttons/combine_button1.wav" },
	}
	*/
	
	net.Receive( "nut_CardVerification", function( len )
		local ent = net.ReadEntity()
		local stat = net.ReadFloat()
		if !ent:IsValid() then return end
		ent.ResetTime = CurTime() + 2
		ent.status = stat
		ent:EmitSound( curstat[ stat ][3] )
	end)

end