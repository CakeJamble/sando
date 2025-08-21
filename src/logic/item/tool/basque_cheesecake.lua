return function(enemy)
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
end;