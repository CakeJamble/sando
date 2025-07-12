local json = require('libs.json')
local newSkill = require('class.qte.skill')

local function loadSkill(skillName)
	local jsonPath = 'skills/data' .. skillName .. '.json'
	local logicPath = 'skills/logic' .. skillName

	local raw = love.filesystem.read(jsonPath)
	local data = json.decode(raw)

	local success, res = pcall(require, 'logic.skills' .. skillName)
	if success and type(res) == "function" then
		data.proc = proc
	else
		data.proc = function() error('Failed to find implementation for skill named \'' .. skillName .. '\': ' .. tostring(proc))
	end

	return newSkill(data)
end;

