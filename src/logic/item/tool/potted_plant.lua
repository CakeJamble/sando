return function(character)
	local amount = love.math.random(1, 5)
	character.baseStats.fp = character.baseStats.fp + amount
end;