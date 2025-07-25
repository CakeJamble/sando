local json = require('libs.json')

local function loadSkill(skillName)
	local jsonPath = 'data/skill/' .. skillName .. '.json'
	local logicPath = 'logic/skill/' .. skillName

	local raw = love.filesystem.read(jsonPath)
	local data = json.decode(raw)

	local proc = require('logic.skill.' .. skillName)
	if proc then
		data.proc = proc
	else
		error('Failed to find implementation for skill named \'' .. skillName .. '\': ' .. tostring(proc))
	end

	data.tag = skillName

	return data
end

return loadSkill