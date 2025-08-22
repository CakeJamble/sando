return function(enemy)
	local chance = 0.2
	if love.math.random() < chance then
		enemy:modifyBattleStat('attack', 1)
	end
end;