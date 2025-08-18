return function(members)
	local randIndex = love.math.random(1, #members)
	local member = members[randIndex]

	member:modifyBattleStat('speed', 1)
end;