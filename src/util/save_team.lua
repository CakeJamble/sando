local bitser = require('libs.bitser')
local CharacterTeam = require('class.entities.character_team')

---@param characterTeam CharacterTeam
return function(characterTeam)
	bitser.registerClass("CharacterTeam", CharacterTeam)
	characterTeam = bitser.register("characterTeam", characterTeam)
	bitser.dumpLoveFile('save_team.dat', characterTeam)
end;

