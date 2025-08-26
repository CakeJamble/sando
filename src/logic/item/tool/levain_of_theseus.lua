return function(enemy)
	enemy.baseStats.hp = enemy.baseStats.hp + math.floor(enemy.baseStats.hp * 0.3)
	enemy.expReward = enemy.expReward + math.ceil(enemy.expReward * 0.3)
end;