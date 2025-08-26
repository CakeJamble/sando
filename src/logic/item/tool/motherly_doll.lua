return function(character)
	character.battleStats.hp = math.max(character.battleStats.hp, 1)
end;