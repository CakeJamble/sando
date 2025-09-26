-- Signal: OnKO
---@param enemies Enemy[] Enemies that are still alive
---@param koEnemies Enemy[]
return function(_, enemies, koEnemies)
	for _, enemy in ipairs(koEnemies) do
		local statuses = enemy.statuses
		for _,status in ipairs(statuses) do
			local i = love.math.random(1, #enemies)
			local target = enemies[i]
			target:applyStatus(status)
		end
	end
end;