local bitser = require('libs.bitser')
local CharacterTeam = require('class.entities.character_team')

---@return CharacterTeam
return function()
	bitser.registerClass("CharacterTeam", CharacterTeam)
	local characterTeam = bitser.loadLoveFile("save_team.dat")
	return characterTeam
end;