return function(enemyTeam)
	for _,member in ipairs(enemyTeam.members) do
		member:applyStatus('vulnerable')
	end
end;