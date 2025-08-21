return function(characterTeam)
	for _,character in ipairs(characterTeam.members) do
		local inventory = character.inventory

		if inventory.numEquipSlots > #inventory.equipManager.equips then
			character:modifyBattleStat('speed', 1)
			character:modifyBattleStat('luck', 1)
		end
		if inventory.numAccessories > #inventory.accessoryManager.accessories then
			character:modifyBattleStat('speed', 1)
			character:modifyBattleStat('luck', 1)
		end
	end
end;