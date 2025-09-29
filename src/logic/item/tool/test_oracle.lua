-- Signal: OnStartCombat
---@param enemyTeam EnemyTeam
return function(_, enemyTeam)
	for _,member in ipairs(enemyTeam.members) do
		member:modifyBattleStat('random', -1)
	end
end;