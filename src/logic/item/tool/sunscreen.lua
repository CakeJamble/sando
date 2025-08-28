return function(characterTeam)
	for _,member in ipairs(characterTeam.members) do
		member.statusResist.burn = 1
	end
end;