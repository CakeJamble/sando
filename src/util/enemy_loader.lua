local json = require('libs.json')
local loadSkill = require('util.skill_loader')
local dataDir = 'data/entity/enemy_stats/'

local function loadEnemyData(entityName)
	local raw = love.filesystem.read(dataDir .. entityName .. '.json')
	local data = json.decode(raw)

	local skillPool = {}
	for _,skillName in ipairs(data.skillPool) do
		local skill = loadSkill(skillName)
		table.insert(skillPool, skill)
	end

	data.skillPool = skillPool
	return data
end

return loadEnemyData