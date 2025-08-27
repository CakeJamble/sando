local json = require('libs.json')
local loadSkill = require('util.skill_loader')
local dataDir = 'data/entity/character_stats/'

---@param entityName string
---@return { [string]: any }
local function loadCharacterData(entityName)
	local raw = love.filesystem.read(dataDir .. entityName .. '.json')
	local data = json.decode(raw)

	local basicAttack = loadSkill(data.basic)
	data.basic = basicAttack

	local skillPool = {}
	for _,skillName in ipairs(data.skillPool) do
		local skill = loadSkill(skillName)
		table.insert(skillPool, skill)
	end

	data.skillPool = skillPool
	return data
end

return loadCharacterData