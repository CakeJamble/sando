local flux = require('libs.flux')
local Signal = require('libs.hump.signal')
local Text = require('libs.sysl-text.slog-text')
local Frame = require('libs.sysl-text.slog-frame')
local Class = require('libs.hump.class')

---@class LootManager
local LootManager = Class{}

---@param characterTeam CharacterTeam
function LootManager:init(lootOptions)

	self.lootOptions = lootOptions
	self.pick3UI = self.initUI()
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
end;

---@return table
function LootManager.initUI()
	local uiOptions = {
		mode = 'fill',
		x = 100,
		y = 100,
		w = 450,
		h = 250,
		offset = 50,
		lootScale = {0, 0, 0}
	}

	return uiOptions
end;

---@return thread
function LootManager:createLootSelectCoroutine()
	return coroutine.create(function()
		self.isActive = true
		-- Oven opens

		-- Loot options emerge
		flux.to(self.pick3UI, 0.25, {lootScale = 1})
			:oncomplete(function()
				self:resumeCurrent()
			end)

		coroutine.yield('await tween finish')
		self.highlightSelected = true
		self.lootIndex = 1

		coroutine.yield('await loot select')
		if self.lootIndex < 4 then
			self.selectedReward = self.lootOptions[self.lootIndex]
		end
	end)
end;

function LootManager:resumeCurrent()
	local co = self.coroutines[self.i]
	if not co then
		Signal.emit('OnLootDistributionComplete', self.selectedReward)
		print('finished! returning control back to the reward state')
		return
	end

	local code, res = coroutine.resume(co)
	if not code then
		error(res)
	else
		print('starting coroutine ' .. self.i)
	end

	if coroutine.status(co) == 'dead' then
		self.i = self.i + 1
		self:resumeCurrent()
	end
end;

---@param item table
function LootManager:raiseItemTween()
	for _,item in ipairs(self.lootOptions) do
		item.pos.scale = 1
	end

	if self.lootIndex < 4 then
		flux.to(self.selectedReward.pos, 0.25, {scale = 1.5}):ease('linear')
	end
end;
---@param joystick string
---@param button string
function LootManager:gamepadpressed(joystick, button)
	if button == 'dpleft' and self.lootIndex > 1 then
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
	elseif button == 'a' and not self.isRewardSelected then
		self.isRewardSelected = true
		self:resumeCurrent()
	end

end;

function LootManager:draw()
	if self.isActive then
		love.graphics.rectangle(self.pick3UI.mode, self.pick3UI.x, self.pick3UI.y,
			self.pick3UI.w, self.pick3UI.h)
		for i,item in ipairs(self.lootOptions) do
			love.graphics.draw(item.image, item.pos.x + (i-1) * self.pick3UI.offset, item.pos.y, 0,
				item.pos.scale, item.pos.scale)
		end
	end
end;