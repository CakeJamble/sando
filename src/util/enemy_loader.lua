local json = require('libs.json')
local loadSkill = require('util.skill_loader')
local dataDir = 'data/entity/enemy_stats/'
local aiPath = 'logic.ai.'

-- Load, package, and return the Enemy data file (JSON), skills (JSON), and AI decision tree (Lua)
---@param entityName string
---@return { [string]: any }
local function loadEnemyData(entityName)
	local raw = love.filesystem.read(dataDir .. entityName .. '.json')
	local data = json.decode(raw)

	local skillPool = {}
	for _,skillName in ipairs(data.skillPool) do
		local skill = loadSkill(skillName)
		table.insert(skillPool, skill)
	end

	data.skillPool = skillPool

	local ai = require(aiPath .. entityName)
	data.ai = ai

	return data
end

return loadEnemyData