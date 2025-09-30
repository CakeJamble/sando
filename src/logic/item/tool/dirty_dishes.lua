-- Signal: OnStartCombat
---@param enemyTeam EnemyTeam
return function(_, enemyTeam)
	for _,enemy in ipairs(enemyTeam) do
		enemy:applyStatus('slow')
	end
end;