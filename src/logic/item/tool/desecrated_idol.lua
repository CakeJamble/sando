local loadItem = require('util.item_loader')

-- Signal: OnPickup
---@param characterTeam CharacterTeam
return function(characterTeam)
	local inventory = characterTeam.inventory
	local newMoney = math.ceil(inventory.money / 2)
	inventory:setMoney(newMoney)

	-- Add animation?
	local refurbishedIdol = loadItem('refurbished_idol', 'accessory')
	inventory.accessoryManager:addItem(refurbishedIdol)
end;