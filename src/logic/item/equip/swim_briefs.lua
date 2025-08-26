return function(character, equip)
	for stat,mod in ipairs(equip.stats) do
		local baseStat = character.baseStats[stat]
		local statChange = math.ceil(baseStat * mod)
		character.baseStats[stat] = baseStat + statChange
	end
end;