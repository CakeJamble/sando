-- Signal: OnStartTurn
---@param character Character
return function(character)
	local skills = character.currentSkills

	if not skills or #skills < 2 then return end

	local costs = {}
	for i=1,#skills do
		costs[i] = skills[i].cost
	end

	-- Fisher-Yates
	for i = #costs, 2, -1 do
		local j = love.math.random(i)
		costs[i], costs[j] = costs[j], costs[i]
	end

	for i=1,#skills do
		skills[i].cost = costs[i]
	end
end;