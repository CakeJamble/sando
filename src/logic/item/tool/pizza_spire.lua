return function(character)
	local amount = character.baseStats.hp * math.floor(0.5 + 0.05 * character.baseStats.hp)
	character:heal(amount)
end;