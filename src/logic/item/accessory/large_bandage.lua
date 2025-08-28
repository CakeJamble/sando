return function(character)
	local amount = 0.03 * character.baseStats.hp
	character:heal(amount)
end;