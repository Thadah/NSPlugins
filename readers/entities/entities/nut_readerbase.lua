ENT.Type = "anim"
ENT.PrintName = "Base Reader"
ENT.Author = "La Corporativa"
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Category = "NutScript"

if (SERVER) then
	
	function ENT:Initialize()
		self:SetModel("models/props_combine/combine_smallmonitor001.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetUseType(SIMPLE_USE)
		local p = self:GetPhysicsObject()
		p:EnableCollisions( false )
	end
	
else

	curstat = {
		[0] = { ENT.Level, { 90, 150, 170 } },
		[1] = { "Denied", { 150, 20, 20 }, "buttons/combine_button2.wav" },
		[2] = { "Granted", { 90, 150, 100 }, "buttons/combine_button1.wav" },
	}
	
	function ENT:Initialize()
		self.width = 170
		self.height = 180
		self.scale = .1
	end

	
	function ENT:Think()
		if !self.ResetTime or self.ResetTime < CurTime() then
			self.status = 0
		end
		self:NextThink( CurTime() + 1 )
	end
	
	local grd = surface.GetTextureID("vgui/gradient_down")
	function ENT:Draw()
	
		self:DrawModel()		
		if LocalPlayer():GetPos():Distance( self:GetPos() ) > 200 then return end
		
		local pos, ang = self:GetPos(), self:GetAngles()
		local wide, tall = 165, 180
		pos=pos+self:GetRight()*7
		pos=pos+self:GetForward()*13
		pos=pos+self:GetUp()*20
		
		ang:RotateAroundAxis(ang:Up(), 90)
		ang:RotateAroundAxis(ang:Forward(), 90)
	
		cam.Start3D2D(pos, ang, .1)
			
			local alpha = 120 + math.sin( RealTime() * 80 ) * 10
			surface.SetDrawColor(80,80,80,alpha)
			surface.DrawRect(0,0,wide,tall)
			
			surface.SetTexture(grd)
			surface.SetDrawColor(10,10,10,alpha)
			surface.DrawTexturedRect(0,0,wide,tall)
			
			
			local alpha2 = math.abs( math.cos( RealTime() * 80 ) * 100 )
			local text = "Control de Acceso"
			local tx, ty = surface.GetTextSize( text )
			/*
			surface.SetFont("DermaDefaultBold")
			surface.SetTextColor(255,255,255,255 - alpha2 ) 
			surface.SetTextPos( wide / 2 - tx / 2 ,60)
			surface.DrawText( text )
			*/
			draw.DrawText(text, "DermaDefaultBold", wide/2 - tx/2, 60, Color(255,255,255,255 - alpha2), 0)
			
			local text = curstat[ self.status ][1]
			local tx, ty = surface.GetTextSize( text )
			local col = curstat[ self.status ][2]
			/*
			surface.SetFont("DermaLarge")
			surface.SetTextColor( col[1]/2 , col[2]/2 , col[3]/3 ,255 - alpha2 )
			surface.SetTextPos( wide / 2 - tx / 2 + math.random( -2, 2 ), tall/2 - ty/2 + math.random( -2, 2 ))
			surface.DrawText( text )
			*/
			draw.DrawText(text, "DermaLarge", wide/2 - tx/2 + math.random(-2,2), tall/2 - ty/2 + math.random(-2,2), Color(col[1]/2 , col[2]/2 , col[3]/3 ,255 - alpha2), 0)
			/*
			surface.SetTextColor( col[1] , col[2] , col[3] ,255 - alpha2 )
			surface.SetTextPos( wide / 2 - tx / 2 , tall/2 - ty/2 )
			surface.DrawText( text )
			*/
			draw.DrawText(text, "DermaLarge", wide/2 - tx/2, tall/2 - ty/2, Color(col[1] , col[2] , col[3] ,255 - alpha2), 0)
			
			
		cam.End3D2D()
		
	end
	
end
