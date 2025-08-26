return function(characterTeam)
	local i = love.math.random(1, #characterTeam.members)
	characterTeam.members[i]:applyStatus('burn')
end;