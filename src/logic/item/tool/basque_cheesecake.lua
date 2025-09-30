-- Signal: OnKO
-- Note: OnKO signal is emitted before rewards are added to to the pool
---@param enemies Enemy[] Enemies that are still alive
---@param koEnemies Enemy[]
return function(_, enemies, koEnemies)
	for _,enemy in ipairs (koEnemies) do		
		local isBurned = false
		for _,status in ipairs(enemy.statuses) do
			if status == 'burn' then
				isBurned = true
			end
		end

		if isBurned then
			local extraEXP = 0.25 * enemy.expReward
			enemy.expReward = enemy.expReward + extraEXP
		end
	end
end;