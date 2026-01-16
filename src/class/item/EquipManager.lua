local AccessoryManager = require("class.item.AccessoryManager")
local Class = require('libs.hump.class')

---@type EquipManager
local EquipManager = Class{__includes = AccessoryManager}

function EquipManager:addItem(equip)
	if equip.signal then
		AccessoryManager.addItem(self, equip)
	else
		table.insert(self.list, equip)
	end
end;

return EquipManager