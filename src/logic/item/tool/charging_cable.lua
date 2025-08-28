return function(characterTeam)
	for _,member in ipairs(characterTeam.members) do
		local amount = math.floor(0.5 + member.battleStats.fp * 0.15)
		member:refresh(amount)
	end
end;