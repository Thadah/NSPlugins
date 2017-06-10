ITEM.name = "Welder"
ITEM.desc = "A welder"
ITEM.model = "models/warz/items/syringe.mdl"
ITEM.class = "hl2_m_taladro"
ITEM.width = 1
ITEM.height = 1
ITEM.price = 0
ITEM.category = "Tool"
ITEM.cant = 1
ITEM.functions.EquipUn = {
	onCanRun = function(item)
		return false
	end
}
ITEM.functions.Equip = {
	onCanRun = function(item)
		return false
	end
}
