return function(characterTeam)
	for _,character in ipairs(characterTeam.members) do
		character:raiseMaxHP(0.05)
	end
end;