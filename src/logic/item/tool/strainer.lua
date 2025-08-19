return function(characterTeam)
	local members = characterTeam.members
	for _,member in pairs(members) do
		local amount = math.ceil(0.08 * member.baseStats.defense)
		member.baseStats.defense = member.baseStats.defense + amount
	end
end;