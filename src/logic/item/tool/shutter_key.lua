-- Signal: OnStartCombat
---@param characterTeam CharacterTeam
return function(characterTeam, _)
	for _,member in ipairs(characterTeam.members) do
		local amount = math.floor(0.5 + member.baseStats.hp * 0.1)
		member:heal(amount)
	end
end;