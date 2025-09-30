-- Signal: OnPickup
---@param characterTeam CharacterTeam
return function(characterTeam)
	local inventory = characterTeam.inventory
	for _,consumable in ipairs(inventory.consumables) do
		consumable.value = consumable.value + math.floor(0.5 + 0.4 * consumable.value)
	end

	local tools = inventory.toolManager.tools
	for _,tool in ipairs(tools) do
		tool.value = tool.value + math.floor(0.5 + 0.4 * tool.value)
	end

	local equips = inventory.equipManager.list
	for _,equip in ipairs(equips) do
		equip.value = equip.value + math.floor(0.5 + 0.4 * equip.value)
	end

	local accessories = inventory.accessoryManager.list
	for _,accessory in ipairs(accessories) do
		accessory.value = accessory.value + math.floor(0.5 + 0.4 * accessory.value)
	end
end;