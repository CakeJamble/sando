local json = require('libs.json')
local newSkill = require('skills.skill')

local function loadSkill(skillName)
	local jsonPath = 'data/skills/' .. skillName .. '.json'
	local logicPath = 'skills/logic/' .. skillName

	local raw = love.filesystem.read(jsonPath)
	local data = json.decode(raw)

	local proc = require('skills.logic.' .. skillName)
	if proc then
		data.proc = proc
	else
		error('Failed to find implementation for skill named \'' .. skillName .. '\': ' .. tostring(proc))
	end

	return data
	-- return newSkill(data)
end

return loadSkill