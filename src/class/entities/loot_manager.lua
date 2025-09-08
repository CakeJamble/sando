local flux = require('libs.flux')
local Signal = require('libs.hump.signal')
local Class = require('libs.hump.class')

-- Distributes loot rewards (Accessory, Equip, Tool, Consumables)
---@class LootManager
local LootManager = Class{}

---@param lootOptions table
function LootManager:init(lootOptions)
	self.lootOptions = lootOptions
	self.pick3UI = nil
	self.coroutines = {}
	self.i = 1
	self.isDisplayingNotification = false
	self.textBox = Text.new("left",
	{
    color = {0.9,0.9,0.9,0.95},
    shadow_color = {0.5,0.5,1,0.4},
    character_sound = true,
    sound_every = 2,
	})

	self.isActive = false
	self.highlightSelected = false
	self.lootIndex = 1
	self.selectedReward = nil
	self.isRewardSelected = false
	self.coroutines = {}
end;

---@return table
function LootManager.initUI(loot)
	local images = {}
	for i,item in ipairs(loot) do
		images[i] = {image = item.image, scale = 0}
	end

	local uiOptions = {
		mode = 'fill',
		x = 100,
		y = 100,
		w = 450,
		h = 150,
		offset = 50,
		images = images
	}

	return uiOptions
end;

function LootManager:distributeLoot()
	self.coroutines = {}
	for _,loot in ipairs(self.lootOptions) do
		local co = self:createLootSelectCoroutine(loot)
		table.insert(self.coroutines, co)
	end

	self.i = 1
	self:resumeCurrent()
end;

---@param loot table
---@return thread
function LootManager:createLootSelectCoroutine(loot)
	return coroutine.create(function()
		self.pick3UI = self.initUI(loot)
		self.isActive = true
		-- Oven opens

		-- Loot options emerge
		for _,img in ipairs(self.pick3UI.images) do
			flux.to(img, 0.25, {scale = 1})
		end
		self.highlightSelected = true
		self.lootIndex = 1
		self:raiseItemTween()

		coroutine.yield('await loot select')
		local selectedReward
		if self.lootIndex < 4 then
			selectedReward = loot[self.lootIndex]
		end
		return selectedReward
	end)
end;

function LootManager:resumeCurrent()
	local co = self.coroutines[self.i]
	if not co then
		self.isActive = false
		Signal.emit('OnLootDistributionComplete')
		return
	end

	local code, res = coroutine.resume(co)
	if not code then
		error(res)
	else
		if type(res) ~= "string" then
			Signal.emit('OnLootChosen', res)
		else
			print('Returned from coroutine ' .. self.i .. ': ' .. res)
		end
	end

	if coroutine.status(co) == 'dead' then
		self.i = self.i + 1
		self:resumeCurrent()
	end
end;

function LootManager:raiseItemTween()
	for _,img in ipairs(self.pick3UI.images) do
		img.scale = 1
	end

	if self.lootIndex < 4 then
		flux.to(self.pick3UI.images[self.lootIndex], 0.25, {scale = 2})
	end
end;

---@param joystick string
---@param button string
function LootManager:gamepadpressed(joystick, button)
	if self.isActive then
		print(button)
		if button == 'a' then
			self:resumeCurrent()
		elseif button == 'dpleft' and self.lootIndex > 1 then
			self.lootIndex = self.lootIndex - 1
			self:raiseItemTween()
		elseif button == 'dpright' and self.lootIndex < 4 then
			self.lootIndex = self.lootIndex + 1
			self:raiseItemTween()
		elseif button == 'dpup' or 'b' then
			if self.isRewardSelected then
				self.isRewardSelected = false
			else
				self.lootIndex = 4
				self:raiseItemTween()
			end
		end
	end
end;

function LootManager:draw()
	if self.isActive and self.pick3UI then
		love.graphics.rectangle(self.pick3UI.mode, self.pick3UI.x, self.pick3UI.y,
			self.pick3UI.w, self.pick3UI.h)

		for i,img in ipairs(self.pick3UI.images) do
			love.graphics.draw(img.image, self.pick3UI.x + i * self.pick3UI.offset, self.pick3UI.y, 0,
				img.scale, img.scale)
		end
	end
end;

return LootManager