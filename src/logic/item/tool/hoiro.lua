-- Signal: OnStartCombat
---@param enemyTeam EnemyTeam
return function(_, enemyTeam)
	for _,enemy in ipairs(enemyTeam.members) do
		if enemy.type == 'elite' then
			enemy.baseStats.hp = math.floor(enemy.baseStats.hp * 0.7)
		end
	end
end;