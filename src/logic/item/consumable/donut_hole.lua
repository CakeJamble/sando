return function(character, consumable)
	for i=1, consumable.numProcs do
		local numTargets = #character.targets
		local randIndex = love.math.random(1, numTargets)
		local target = character.targets[randIndex]
		target:heal(10)
		-- tween donut hole to target, check egg toss for example
	end
end;