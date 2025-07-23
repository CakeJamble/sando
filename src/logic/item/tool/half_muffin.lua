-- On pickup, increase all member's HP by 8%

return function(characterTeam)
	for _,member in ipairs(characterTeam.members) do
		member.baseStats.hp = member.baseStats.hp + (math.ceil(0.08 * member.baseStats.hp))
	end
end;