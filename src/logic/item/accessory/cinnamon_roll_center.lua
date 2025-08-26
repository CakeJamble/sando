return function(enemy, accessory)
	if enemy.skill.hasProjectile then
		accessory.entity:modifyBattleStat('defense', 1)
	end
end;