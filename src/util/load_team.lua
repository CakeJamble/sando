local bitser = require('libs.bitser')
local CharacterTeam = require('class.entities.CharacterTeam')

---@return CharacterTeam
return function()
	bitser.registerClass("CharacterTeam", CharacterTeam)
	local characterTeam = bitser.loadLoveFile("save_team.dat")
	return characterTeam
end;