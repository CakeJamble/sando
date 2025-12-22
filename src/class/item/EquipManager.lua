local AccessoryManager = require("class.item.AccessoryManager")
local Class = require('libs.hump.class')

---@class EquipManager: AccessoryManager
local EquipManager = Class{__includes = AccessoryManager}

-- not all equips have signals, some just raise stats
---@param equip table
function EquipManager:addItem(equip)
	if equip.signal then
		AccessoryManager.addItem(self, equip)
	else
		table.insert(self.list, equip)
	end
end;

return EquipManager