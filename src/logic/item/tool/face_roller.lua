local Signal = require('libs.hump.signal')

-- Signal: OnGuard
---@param character Character
return function(character)
	character.debuffImmune = true

	Signal.register("OnEndTurn", function(entity)
		entity.debuffImmune = false
	end)
end;