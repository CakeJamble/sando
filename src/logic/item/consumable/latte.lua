return function(character, consumable)
	local amount = math.floor(0.5 + character.baseStats.hp * consumable.amount)
	character:heal(amount)
end;