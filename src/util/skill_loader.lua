local json = require('libs.json')
local initProjectiles = require('util.projectile_animation_loader').initProjectiles

---@param skillName string
---@return { [string]: any }
local function loadSkill(skillName)
	local jsonPath = 'data/skill/' .. skillName .. '.json'
	local logicPath = 'logic.skill.' .. skillName

	local raw = love.filesystem.read(jsonPath)
	local data = json.decode(raw)

	local proc = require(logicPath)
	if proc then
		data.proc = proc
	else
		error('Failed to find implementation for skill named \'' .. skillName .. '\': ' .. tostring(proc))
	end

	data.tag = skillName

	if data.hasProjectile and data.projectiles then
		data.animation = initProjectiles(data.projectiles)
	end

	return data
end

return loadSkill