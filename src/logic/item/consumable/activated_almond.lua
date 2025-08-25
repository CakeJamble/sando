return function(character, consumable)
	local amount = consumable.amount * character.baseStats.fp
	local newFP = character.battleStats.fp + amount
	character.battleStats.fp = math.min(character.baseStats.fp, newFP)
end;