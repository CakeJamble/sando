local Shop = {}
local DialogManager = require('class.ui.dialog_manager')
local ItemRandomizer = require('util.item_randomizer')
local SoundManager = require('class.ui.sound_manager')
local CharacterTeam = require('class.entities.character_team')

function Shop:init()
	shove.createLayer('background')
	self.bg = love.graphics.newImage('asset/sprites/background/shop.png')
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
---@param options table
function Shop:enter(previous, options)
	self.sfx = SoundManager(AllSounds.sfx.shop)
	self.characterTeam = options.team
	self.log = options.log or Log()
	self.items = self.loadShopItems(self.numItems, self.shopRarities, self.characterTeam.rarityMod)
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

---@param inventory Inventory
---@param item { [string]: any }
function Shop:processTransaction(inventory, item)
	local money = inventory.money
	local cost = item.value
	if money >= cost then
		inventory:setMoney(money - cost)
		self.sfx:play("coins_drop")
	else
		self.sfx:play("laugh")
	end
end;

---@param dt number
function Shop:update(dt)
end;

function Shop:draw()
	shove.beginDraw()
	camera:attach()

	shove.beginLayer('background')
	love.graphics.draw(self.bg,0,0,0,2,2)
	shove.endLayer()

	camera:detach()
	shove.endDraw()
end;

return Shop