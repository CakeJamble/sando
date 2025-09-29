local Signal = require("libs.hump.signal")

-- Signal: OnStartTurn
---@param character Character
return function(character)
	character.debuffImmune = true

	Signal.register("OnEndTurn", function(entity)
		if entity == character then
			character.debuffImmune = false
		end
	end)
end;