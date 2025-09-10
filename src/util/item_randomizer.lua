local loadItem = require('util.item_loader')
require('util.globals')
local ItemRandomizer = {}
---@param itemTypes string[]
---@return string
local function getItemType(itemTypes)
	local i = love.math.random(1, #itemTypes)
	local itemType = itemTypes[i]

	return itemType
end;

---@param pools string[]
---@param rarities { [string]: number }
---@return string
local function getItemRarity(pools, rarities)
	local rarity
	local chance = love.math.random()
	for k,v in pairsByValues(rarities) do
		if v >= chance then 
			rarity = k
			break
		end
	end

	if not rarity then rarity = 'common' end

	return rarity
end;

-- Load an item and remove it from the global ItemPool if it's not a consumable
---@param itemType string
---@param rarity string
---@return { [string]: any }
ItemRandomizer.getRandomItem = function(itemType, rarity)
	local tLen = #ItemPool[itemType][rarity]
	local i = love.math.random(1, tLen)
	local itemName = ItemPool[itemType][rarity][i]
	if itemType ~= "consumable" then
		table.remove(ItemPool[itemType][rarity], i)
	end
	local item = loadItem(itemName, itemType)
	return item
end;

---@param numItems integer
---@param itemTypes string[]
---@param pools string[]
---@param rarities { [string]: number }
---@return table
ItemRandomizer.getRandomItems = function(numItems, itemTypes, pools, rarities)
	local items = {}

	for i=1,numItems do
		local itemType = getItemType(itemTypes)
		local rarity = getItemRarity(pools, rarities)
		local item = ItemRandomizer.getRandomItem(itemType, rarity)
		table.insert(items, item)
	end

	return items
end;

return ItemRandomizer