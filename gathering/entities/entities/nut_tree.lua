ENT.Type = "anim"
ENT.PrintName = "Tree"
ENT.Author = "Cyumus"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "Gathering"

if (SERVER) then
	function ENT:Initialize()
		local function getRandomModel()
			local trees = {
				"models/props_foliage/tree_poplar_01.mdl",
				"models/props_foliage/tree_springers_01a-lod.mdl",
				"models/props_foliage/tree_springers_01a.mdl",
				"models/props_foliage/tree_deciduous_03b.mdl",
				"models/props_foliage/tree_deciduous_03a.mdl",
				"models/props_foliage/tree_deciduous_02a.mdl",
				"models/props_foliage/tree_deciduous_01a.mdl",
				"models/props_foliage/tree_deciduous_01a-lod.mdl",
				"models/props_foliage/tree_cliff_01a.mdl",
			}
			local random = math.random(1,table.getn(trees))
			return trees[random]
		end
		self:SetModel(getRandomModel())
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetHealth(nut.config.get("treeLife"))
		local pos = self:GetPos()
		self:SetPos(Vector(pos.X,pos.Y,pos.Z - 10))
		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:EnableMotion(false)
			physicsObject:Sleep()
		end
	end

	function ENT:Use(activator)
	end
else
	function ENT:Draw()
		self:DrawModel()
	end
end
