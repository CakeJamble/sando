return function(characterTeam)
	for _,member in ipairs(characterTeam.members) do
		member:refresh(0.08)
	end
end;