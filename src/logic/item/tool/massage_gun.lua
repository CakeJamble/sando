return function(enemyTeam)
	for _,enemy in ipairs(enemyTeam) do
		enemy:takeDamagePierce(1)
	end
end;