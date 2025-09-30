-- Signal: OnSellEquip
---@param characterTeam CharacterTeam
return function(characterTeam)
	local stats = {"hp", "fp", "attack", "defense", "speed", "luck"}
	local i = love.math.random(1, #stats)
	local stat = stats[i]
	for _,member in ipairs(characterTeam.members) do
		member.baseStats[stat] = member.baseStats[stat] + 1
	end
end;