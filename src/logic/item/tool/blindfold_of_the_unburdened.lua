-- Signal: OnStartCombat
---@param characterTeam CharacterTeam
return function(characterTeam)
	for _,character in ipairs(characterTeam.members) do
		local maxEquips = character.numEquipSlots
		local maxAccessories = character.numAccessorySlots
		local items = character.equips

		if maxEquips > #items.equip then
			character:modifyBattleStat("speed", 1)
			character:modifyBattleStat("luck", 1)
		end

		if maxAccessories > #items.accessory then
			character:modifyBattleStat("speed", 1)
			character:modifyBattleStat("luck", 1)
		end
	end
end;