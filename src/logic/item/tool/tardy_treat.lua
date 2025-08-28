return function(characterTeam)
	for _,member in ipairs(characterTeam.members) do
		member:applyStatus('slow')
		member:modifyBattleStat('all', 1)
	end
end;