return function(enemy)
	local amount = enemy.skill.damage
	enemy:takeDamagePierce(amount)
end;