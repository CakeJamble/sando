local Shop = {}
local DialogManager = require('libs.ui.dialog_manager')
local ItemRandomizer = require('util.item_randomizer')

function Shop:init()
	self.dialogManager = DialogManager()
	self.dialogManager:getAll('shop')
	self.textbox = Text.new("left",
	{
    color = {0.9,0.9,0.9,0.95},
    shadow_color = {0.5,0.5,1,0.4},
    character_sound = true,
    sound_every = 2,
	})
	self.hasVisited = false
	self.numItems = 8
	self.shopRarities = {
		rare = 0.1,
		shop = 0.2,
		uncommon = 0.4
	}
end;

---@param previous table
---@param characterTeam CharacterTeam
function Shop:enter(previous, characterTeam)
	self.characterTeam = characterTeam
	self.items = self.loadShopItems(self.numItems, self.shopRarities, characterTeam.rarityMod)
end;

---@param hasVisited boolean
---@param dialogManager DialogManager
---@return string
function Shop.getGreeting(hasVisited, dialogManager)
	local result

	if not hasVisited then
		result = dialogManager:getText('shop', 'firstVisit')
		hasVisited = true
	else
		result = dialogManager:getText('shop', 'returnVisit')
	end

	return result
end;

---@param numItems integer
---@param rarities { [string]: number }
---@param rarityMod number
function Shop.loadShopItems(numItems, rarities, rarityMod)
	local itemTypes = {"accessory", "consumable", "equip", "tool"}
	local rarityTypes = {}
	local modRarities = {}
	for name,rarity in pairs(rarities) do
		table.insert(rarityTypes, name)
		modRarities[name] = rarity + rarityMod
	end
	return ItemRandomizer.getRandomItems(numItems, itemTypes,
	rarityTypes, modRarities)
end;

---@param dt number
function Shop:update(dt)
end;

function Shop:draw()
end;

return Shop