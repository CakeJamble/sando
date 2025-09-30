-- Signal: OnStartCombat
---@param characterTeam CharacterTeam
return function(characterTeam, _)
	local i = love.math.random(1, #characterTeam.members)
	characterTeam.members[i]:applyStatus('burn')
end;