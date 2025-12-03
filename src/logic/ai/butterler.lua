-- Logic for how Butterler chooses its attacks each turn
---@param ref Enemy Self-reference
---@param validTargets table{ characters: Character[], enemies: Enemy[] }
---@return table, table The target(s) and selected skill or sequence of actions
return function(ref, validTargets)
	local skillPool = ref.skillPool[ref.phaseData.phase]
	local skill = ref.getRandomSkill(skillPool, #validTargets.characters)
	return targets, skill
end;