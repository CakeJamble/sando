return function(enemyTeam)
	for _,enemy in ipairs(enemyTeam) do
		enemy:applyStatus('slow')
	end
end;