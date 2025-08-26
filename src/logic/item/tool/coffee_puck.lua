local json = require('libs.json')
local loadItem = require('util.item_loader')

return function(characterTeam)
	-- load item pools
	local pref = 'data/item/consumable/'
	local rawCommon = love.filesystem.read(pref .. 'common_pool.json')
	local rawUncommon = love.filesystem.read(pref .. 'uncommon_pool.json')
	local rawRare = love.filesystem.read(pref .. 'rare_pool.json')

	local commonPool = json.decode(rawCommon)
	local uncommonPool = json.decode(rawUncommon)
	local rarePool = json.decode(rawRare)

	local pools = {commonPool, uncommonPool, rarePool}
	local rewards = {}
	for i=1, 3 do
		local randPool = love.math.random(1, #pools)
		local randIndex = love.math.random(1, pools[randPool])
		local randConsumable = loadItem(pools[randPool][randIndex])
		table.insert(rewards, randConsumable)
	end

	-- wait for user to take all or leave menu
	-- temp impl for linter
	characterTeam:addItem(rewards[1])
	for _,reward in ipairs(rewards) do
		print(reward.name)
	end
end;