-- Signal: OnBuff
---@param enemyTeam EnemyTeam
return function(_, enemyTeam)
	for _,enemy in ipairs(enemyTeam.members) do
		enemy:takeDamagePierce(1)
	end
end;