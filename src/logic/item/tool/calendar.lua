return function(character)
	local enemyTeam = character.targets
	for _,enemy in ipairs(enemyTeam) do
		enemy:takeDamagePierce(4)
	end
	character:takeDamagePierce(1)
end;