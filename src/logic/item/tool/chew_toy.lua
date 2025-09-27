-- Signal: OnStartCombat
---@param enemyTeam EnemyTeam
return function(_, enemyTeam)
	for _,enemy in ipairs(enemyTeam.members) do
		enemy:applyStatus('weak')
	end
end;