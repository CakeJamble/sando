local json = require('libs.json')
local loadItem = require('util.item_loader')
local ItemRandomizer = require('util.item_randomizer')

return function(characterTeam)
	local bonus = characterTeam.rarityMod
	local itemType = {"consumable"}
	local itemPools = {"common", "uncommon", "rare"}
	local rarities = {uncommon = 0.3 + bonus, rare = 0.1 + bonus}
	local consumables = ItemRandomizer.getRandomItems(3, itemType, itemPools, rarities)
	
	-- start coroutine
	-- await decision

	-- temp
	characterTeam:addConsumable(consumables[1])
	for _,item in ipairs(consumables) do
		print(item.name)
	end
end;