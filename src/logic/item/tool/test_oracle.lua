return function(enemyTeam)
	for _,member in ipairs(enemyTeam.members) do
		member:modifyBattleStat('random', -1)
	end
end;