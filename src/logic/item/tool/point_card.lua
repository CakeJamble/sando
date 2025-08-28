return function(character)
	local cost = character.skill.cost
	local hpCost = cost - character.battleStats.fp
	if hpCost > 0 then
		character:takeDamagePierce(hpCost)
	end
end;