return function(character, consumable)
	for _,effect in ipairs(consumable.raise) do
		character:modifyBattleStat(effect, 1)
	end
	for _,effect in ipairs(consumable.lower) do
		character:modifyBattleStat(effect, -1)
	end
end;