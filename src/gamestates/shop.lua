local shop = {}
local DialogManager = require('class.ui.dialog_manager')
local ItemRandomizer = require('util.item_randomizer')
local SoundManager = require('class.ui.sound_manager')
local JoystickUtils = require('util.joystick_utils')
local flux = require('libs.flux')
local suit = require('libs.suit')

function shop:init()
	shove.createLayer('background', {zIndex = 1})
	shove.createLayer('item', {zIndex = 5})
	shove.createLayer('ui', {zIndex = 10})
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

	self.textboxPositionRange = {
		xmin = 0, xmax = 100,
		ymin = 0, ymax = 100
	}
	self.textPos = {x=0,y=0,a=1}
	self.hasVisited = false
	self.numItems = 4
	self.shopRarities = {
		rare = 0.1,
		shop = 0.2,
		uncommon = 0.4
	}
	self.selected = nil
	self.selectedIndex = 0
	self.selectedItemType = nil
	self.itemTypes = {"tool", "equip", "accessory", "consumable"}
	self.typeIndex = 0
	self.drawTextbox = true
	self.textTween = nil

end;

---@param previous table
---@param options table
function shop:enter(previous, options)
	self.sfx = SoundManager(AllSounds.sfx.shop)
	self.characterTeam = options.team
	self.log = options.log
	self.items = self.loadShopItems(self.numItems, self.shopRarities, self.characterTeam.rarityMod)
	self.layout = self.setLayout()
	self.itemsUI = suit.new()

	local greeting = self.getGreeting(self.hasVisited, self.dialogManager)
	self:send(greeting)
	self.showMessage = false
end;

---@param text string
function shop:send(text)
	if self.textTween then self.textTween:stop() end
	self.drawTextbox = true
	self.textPos.a = 1
	local x = love.math.random(self.textboxPositionRange.xmin, self.textboxPositionRange.xmax)
	local y = love.math.random(self.textboxPositionRange.ymin, self.textboxPositionRange.ymax)
	self.textPos.x, self.textPos.y = x, y
	self.textbox:send(text)
	self.textTween = flux.to(self.textPos, 1.5, {a=0})
		:delay(4)
		:oncomplete(function()
			self.drawTextbox = false
		end)
end;

---@return table
function shop.setLayout()
	local result = {
		tool = {
			x = 32,
			y = 320,
			xOffset = 46,
			yOffset = 46
		},
		equip = {
			x = 320,
			y = 320,
			xOffset = 46,
			yOffset = 46
		},
		accessory = {
			x = 320,
			y = 160,
			xOffset = 46,
			yOffset = 46
		},
		consumable = {
			x = 32,
			y = 32,
			xOffset = 46,
			yOffset = 46
		}
	}
	return result
end;

---@param hasVisited boolean
---@param dialogManager DialogManager
---@return string
function shop.getGreeting(hasVisited, dialogManager)
	local result

	if not hasVisited then
		result = dialogManager:getText('shop', 'firstVisit')
		hasVisited = true
	else
		result = dialogManager:getText('shop', 'returnVisit')
	end

	return result
end;

-- for testing: Shop always stocks 2 tools, 2 equip, 2 accessories, 2 consumables
---@param numItems integer
---@param rarities { [string]: number }
---@param rarityMod number
function shop.loadShopItems(numItems, rarities, rarityMod)
	local rarityTypes = {}
	local modRarities = {}
	for name,rarity in pairs(rarities) do
		table.insert(rarityTypes, name)
		modRarities[name] = rarity + rarityMod
	end

	local items = {}
	local itemTypes = {"accessory", "consumable", "equip", "tool"}
	for _,itemType in ipairs(itemTypes) do
		for i=1, 2 do
			local rarity = ItemRandomizer.getWeightedRandomItemRarity(rarityTypes, modRarities)
			local item = ItemRandomizer.getRandomItem(itemType, rarity)
			item.itemType = itemType
			table.insert(items, item)
		end
	end
	return items
end;

---@param inventory Inventory
---@param item { [string]: any }
function shop:processTransaction(inventory, item)
	local money = inventory.money
	local cost = item.value
	if money >= cost then
		inventory:loseMoney(money - cost)
		self.sfx:play("coins_drop")
		local item = table.remove(self.items[self.selectedItemType], self.selectedIndex)
		self.characterTeam.inventory:addItem(item, self.selectedItemType)
		-- Adjust selection if you clear out stock
		if #self.items[self.selectedItemType] == 0 then
			self.selected = nil
			self.selectedItemType = nil
		end
	else
		self.sfx:play("laugh")
		local dialog = self.dialogManager:getText('shop', 'insufficientMoney')
		self:send(dialog)
		-- add a visual
	end
end;

---@param joystick love.Joystick
---@param button love.GamepadButton
function shop:gamepadpressed(joystick, button)
	if button == 'b' then
		self.log:setCleared()
		Gamestate.switch(states['overworld'], self.characterTeam, self.log)
	elseif not self.selected or not self.selectedItemType then
		self.typeIndex = 1
		self.selectedIndex = 1

		for itemType,itemList in pairs(self.items) do
			if #itemList == 0 then
				self.typeIndex = self.typeIndex + 1
			else
				self.selectedItemType = itemType
				break
			end
		end

		self.selected = self.items[self.selectedItemType][self.selectedIndex]
	elseif button == "dpleft" then
		self.selectedIndex = self.selectedIndex - 1
		if self.selectedIndex <= 0 then
			self.selectedIndex = #self.items[self.selectedItemType]
		end
		self.selected = self.items[self.selectedItemType][self.selectedIndex]
	elseif button == "dpright" then
		self.selectedIndex = self.selectedIndex + 1
		if self.selectedIndex > #self.items[self.selectedItemType] then
			self.selectedIndex = 1
		end
		self.selected = self.items[self.selectedItemType][self.selectedIndex]
	elseif button == "leftshoulder" then
		self.selectedIndex = 1
		self.typeIndex = self.typeIndex - 1
		if self.typeIndex <= 0 then
			self.typeIndex = #self.itemTypes
		end
		self.selectedItemType = self.itemTypes[self.typeIndex]
		self.selected = self.items[self.selectedItemType][self.selectedIndex]
	elseif button == "rightshoulder" then
		self.selectedIndex = 1
		self.typeIndex = self.typeIndex + 1
		if self.typeIndex > #self.itemTypes then
			self.typeIndex = 1
		end
		self.selectedItemType = self.itemTypes[self.typeIndex]
		self.selected = self.items[self.selectedItemType][self.selectedIndex]
	elseif button == "a" then
		if self.selected then
			self:processTransaction(self.characterTeam.inventory, self.selected)
		end
	end
end;

---@param dt number
function shop:update(dt)
	self:updateSUIT(dt)
	flux.update(dt)
	self.textbox:update(dt)
	if input.joystick then
		-- Left Stick
    if JoystickUtils.isAxisRepeaterTriggered(input.joystick, 'right') then
      self:gamepadpressed(input.joystick, 'dpright')
    elseif JoystickUtils.isAxisRepeaterTriggered(input.joystick, 'left') then
      self:gamepadpressed(input.joystick, 'dpleft')
    elseif JoystickUtils.isAxisRepeaterTriggered(input.joystick, 'up') then
      self:gamepadpressed(input.joystick, 'dpup')
    elseif JoystickUtils.isAxisRepeaterTriggered(input.joystick, 'down') then
      self:gamepadpressed(input.joystick, 'dpdown')
    end
  end
end;

---@param dt number
function shop:updateSUIT(dt)
	local items = {accessory = {}, consumable = {}, equip = {}, tool = {}}
	for _, item in ipairs(self.items) do
		table.insert(items[item.itemType], item)
	end
	local itemTypes = {"accessory", "consumable", "equip", "tool"}
	self.itemsUI.layout:reset(25, 50)
	local px, py = 32, 32
	self.itemsUI.layout:padding(px, py)
	local w,h = 32, 32

	for i,itemType in ipairs(itemTypes) do
		for _,item in ipairs(items[itemType]) do
			local x,y = self.itemsUI.layout:col(w, h)
			local returnState = self.itemsUI:ImageButton(item.image, x, y)
			if returnState.hovered then
				self.itemsUI:Label(item.description, 150, 50, 100, 50)
			elseif returnState.hit then
				self:purchaseTransaction(self.characterTeam.inventory, item)
			end
		end
		-- self.itemsUI.layout:row(-(px + 2 * w))
		self.itemsUI.layout:push(25, 50 + i * (h + py))
	end
end;

function shop:draw()
	shove.beginDraw()
	camera:attach()

	shove.beginLayer('background')
	love.graphics.draw(self.bg,0,0,0,2,2)
	shove.endLayer()

	shove.beginLayer('item')
	-- self:drawItems()
	shove.endLayer()

	shove.beginLayer('ui')
	self:drawUI()
	self.itemsUI:draw()
	-- love.graphics.draw(self.lin, 20, 175)
	love.graphics.rectangle("fill", 360, 32, 32, 16)
	love.graphics.print("Press b to leave", 360, 50)
	shove.endLayer()

	camera:detach()
	shove.endDraw()
end;

function shop:drawItems()
	for key, layout in pairs(self.layout) do
		local items = self.items[key]
		for i, item in ipairs(items) do
			local x,y = layout.x + (layout.xOffset * (i-1)), layout.y
			-- love.graphics.draw(self.itemBox, x, y)
			love.graphics.draw(item.image, x, y)
		end
	end
end;

function shop:drawCursor()
	local layout = self.layout[self.selectedItemType]
	local x = layout.x + ((self.selectedIndex - 1) * layout.xOffset)
	local y = layout.y
	love.graphics.setColor(0, 0, 1)
	love.graphics.rectangle('line', x, y, 32, 32)
	love.graphics.setColor(1, 1, 1)
	-- love.graphics.draw(self.cursor, x, y)
end;

function shop:drawUI()
	-- self.drawBoard(self.items)

	-- love.graphics.draw(self.truck, 100, 100)
	if self.selected then
		self:drawCursor()
		-- love.graphics.draw(self.itemUIContainer, 200, 100)
	end

	if self.drawTextbox then
		local x,y,a = self.textPos.x, self.textPos.y, self.textPos.a
		love.graphics.setColor(1,1,1,a)
		self.textbox:draw(x, y)
		love.graphics.setColor(1,1,1,1)
	end
end;

-- ---@param items table[]
-- function shop.drawBoard(items)
-- 	local offset = 32
-- 	love.graphics.translate(320 , 32)
-- 	love.graphics.rectangle("fill", 0, 0, 96, 170)

-- 	love.graphics.setColor(0, 0, 0)
-- 	local i = 0
-- 	for itemType, itemList in pairs(items) do
-- 		love.graphics.print(itemType, offset / 2, i * offset, 0, 0.5, 0.5)

-- 		for j, item in ipairs(itemList) do
-- 			local y = offset * i + offset * j
-- 			love.graphics.print(item.name, offset / 2, y, 0, 0.5, 0.5)
-- 		end
-- 		i = i + 1
-- 	end
-- 	love.graphics.setColor(1,1,1)
-- end;

return shop