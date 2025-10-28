-- Logic for how Dastobunni chooses its attacks each turn
-- Only has single target moves, skill is chosen at random
-- Above Half Health: Targets highest HP Character
-- Below Half Health: Targets lowest HP Character
---@param ref Enemy Self-reference
---@return table The target(s) and selected skill or sequence of actions
return function(ref)
	ref.skill = ref.getRandomSkill(ref.skillPool, 1)

	local currHP = ref.battleStats.hp
	local maxHP = ref.baseStats.hp
	local hpRatio = currHP / maxHP

	if #ref.targets == 0 then
		return { targets = {}, skill = ref.skill }
	end

	local chosenTarget
	local bestValue = hpRatio > 0.5 and -math.huge or math.huge
	local candidates = {}

	for _, target in ipairs(ref.targets) do
		local tHP = target.battleStats.hp

		if hpRatio > 0.5 then
			-- Above half HP: find highest HP
			if tHP > bestValue then
				bestValue = tHP
				candidates = { target }
			elseif tHP == bestValue then
				table.insert(candidates, target)
			end
		else
			-- Below half HP: find lowest HP
			if tHP < bestValue then
				bestValue = tHP
				candidates = { target }
			elseif tHP == bestValue then
				table.insert(candidates, target)
			end
		end
	end

	-- Randomly pick one if there are multiple candidates with the same HP
	chosenTarget = candidates[love.math.random(1, #candidates)]

	return {
		targets = { chosenTarget },
		skill = ref.skill
	}
end
