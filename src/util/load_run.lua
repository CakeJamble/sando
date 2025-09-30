local lume = require('libs.lume')
local CharacterTeam = require('class.entities.character_team')

---@param path? string
---@return table|nil
return function(path)
	local savePath = path or "run_savedata"
	local saveData = nil

	if love.filesystem.getInfo(savePath) then
		local file = love.filesystem.read(savePath)
		saveData = lume.deserialize(file)
	end

	return saveData
end;