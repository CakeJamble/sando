return function(character, consumable)
	local numTurns = consumable.duration
	character:negateDamage(numTurns)
end;