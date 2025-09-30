local Signal = require('libs.hump.signal')

-- Signal: OnPickup
---@param characterTeam CharacterTeam
return function(characterTeam)
	Signal.register('OnConsumableUse',
		function(consumable)
			if characterTeam.usingFirstConsumable then
				characterTeam.usingFirstConsumable = false
				consumable.mult = consumable.mult * 2
			end
		end)
end;