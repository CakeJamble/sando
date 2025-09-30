local loadItem = require('util.item_loader')

-- Signal: OnPickup
---@param characterTeam CharacterTeam
return function(characterTeam)
	local inventory = characterTeam.inventory
	local amount = math.ceil(inventory.money / 2)
	inventory:loseMoney(amount)

	-- Add animation?
	local refurbishedIdol = loadItem('refurbished_idol', 'accessory')
	inventory.accessoryManager:addItem(refurbishedIdol)
end;