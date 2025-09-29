-- Signal: OnPickup
---@param characterTeam CharacterTeam
return function(characterTeam)
	for _,member in ipairs(characterTeam.members) do
		member.statusResist.paralyze = 1
	end
end;