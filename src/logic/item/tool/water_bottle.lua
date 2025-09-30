local Inventory = require('class.item.inventory')

-- Signal: OnPickup
---@param characterTeam CharacterTeam
return function(characterTeam)
	Inventory.consumableMult = Inventory.consumableMult + 1

	-- for consumables already in inventory
	local consumables = characterTeam.inventory.consumables
	for _,item in ipairs(consumables) do
		item.amount = item.amount * Inventory.consumableMult
	end
end;