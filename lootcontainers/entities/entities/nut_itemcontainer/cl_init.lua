include("shared.lua")

ENT.DrawEntityInfo = true

local toScreen = FindMetaTable("Vector").ToScreen
local colorAlpha = ColorAlpha
local drawText = nut.util.drawText
local configGet = nut.config.get

function ENT:onDrawEntityInfo(alpha)
	local position = toScreen(self.LocalToWorld(self, self.OBBCenter(self)))
	local x, y = position.x, position.y

	local def = self:getStorageInfo() 
	if (def) then
		local tx, ty = drawText(L(def.name or "Container"), x, y, colorAlpha(configGet("color"), alpha), 1, 1, nil, alpha * 0.65)
		y = y + ty + 1

		if (def.desc) then
			drawText(L(def.desc), x, y, colorAlpha(color_white, alpha), 1, 1, nil, alpha * 0.65)
		end
	end
end
