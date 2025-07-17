-- On pickup, slightly increase all member's defense stat

return function(characterTeam)
	for, _,member in pairs(characterTeam.members) do
		member.baseStats.defense = member.baseStats.defense + (math.ceil(0.1 * member.baseStats.defense))
	end
end;