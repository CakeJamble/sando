require('class.entities.enemy_team')
require('class.entities.enemy')
local json = require('libs.json')
local loadEnemy = require('util.enemy_loader')
local dataDir = 'data/encounter_pools/'

local function generateEncounter(floorNumber)
	local poolName
	--[[ Uncomment later after pools have been implemented as data
	if floorNumber < 10 then
		pool = 'enemy_pool_1'
	elseif  floorNumber == 10 then
		pool = 'boss_pool_1'
	elseif ...
	]]
	-- for testing encounter functionality only
	poolName = 'test_encounter'

	local raw = love.filesystem.read(dataDir .. poolName .. '.json')
	local data = json.decode(raw)
	local pool = data[love.math.random(1, #data)]
	local enemies = {}
	for i,enemyName in ipairs(pool.enemyList) do
		local enemy = Enemy(loadEnemy(enemyName))
		table.insert(enemies, enemy)
	end
	local enemyTeam = EnemyTeam(enemies)
	return enemyTeam
end;

return generateEncounter