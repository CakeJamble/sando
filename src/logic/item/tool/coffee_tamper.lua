local Signal = require('libs.hump.signal')

-- Signal: OnPickup
---@param characterTeam CharacterTeam
return function(characterTeam)
	local function onDecision(character)
		character.numSkills = character.numSkills + 1
	end

	Signal.emit("ShowChooseCharacter", characterTeam)

end;