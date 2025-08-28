return function(characterTeam)
	for _,member in ipairs(characterTeam.members) do
		member.statusRsist.paralyze = 1
	end
end;