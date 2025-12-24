local json = require('libs.json')
local JoystickUtils = require("util.joystick_utils")
local loadItem = require('util.item_loader')
local Event = {}

function Event:init()
	shove.createLayer("background", {zIndex = 1})
	shove.createLayer("ui", {zIndex = 10})
	self.dataDir = 'data/event/'
	local poolPath = self.dataDir .. 'event_pool.json'
	local raw = love.filesystem.read(poolPath)
	self.eventPool = json.decode(raw)

	self.textbox = Text.new("left",
	{
    color = {0.9,0.9,0.9,0.95},
    shadow_color = {0.5,0.5,1,0.4},
    character_sound = true,
    sound_every = 2,
	})
end;

---@param previous table
---@param options table
function Event:enter(previous, options)
	self.log = options.log
	self.characterTeam = options.team
	self.eventData = self:loadEvent(self.log.act, self.log.floor)
	self.rewards = self.loadRewards(self.eventData)
	self.coroutines = {}
	self.i = 1
	self.selectedIndex = nil
	if self.eventData.eventType == "combat" then Gamestate.switch(states['Combat'], options) else self:start() end
end;

function Event:start()
	table.insert(self.coroutines, self:createOptionSelectCo())
	self:resumeCurrent()
end;

function Event:createOptionSelectCo()
	return coroutine.create(function()
		self.textbox:send(self.eventData.description)

		coroutine.yield('await option select')
		return self.eventData.proc(self.selectedIndex, self.eventData, self.characterTeam)
	end)
end;

---@param act integer
---@param floor integer
---@return table
function Event:loadEvent(act, floor)
	local i = love.math.random(1, #self.eventPool)
	local eventPath = self.dataDir .. self.eventPool[i] .. '.json'
	local raw = love.filesystem.read(eventPath)
	local data = json.decode(raw)

	local logicPath = 'logic.event.' .. self.eventPool[i]
	local proc = require(logicPath)
	if proc then data.proc = proc
	else 
		error('Failed to find implementation for event named ' .. self.eventPool[i] .. ': ' .. tostring(proc))
	end

	return data
end;

---@param eventData table
---@return table
function Event.loadRewards(eventData)
	local rewards = {}
	local itemType = eventData.itemType
	for _,itemName in ipairs(eventData.itemNames) do
		local item = loadItem(itemName, itemType)
		table.insert(rewards, item)
	end
	return rewards
end;

-- Regulates the order of coroutines occurring in the event gamestate
function Event:resumeCurrent()
	local co = self.coroutines[self.i]
	local code, res = coroutine.resume(co)
	if not code then
		error(res)
	else
		print('Returned from coroutine ' .. self.i .. ': ' .. res)
	end

	if coroutine.status(co) == 'dead' then
		self.i = self.i + 1

		if self.coroutines[self.i] then
			self:resumeCurrent()
		else
			self:applyEventOutcome(res)
		end
	end
end;

---@param eventResult table
function Event:applyEventOutcome(eventResult)
	print(eventResult)
end;

---@param joystick love.Joystick
---@param button love.GamepadButton
function Event:gamepadpressed(joystick, button)
	-- if not self.selectedIndex then
		-- self.selectedIndex = 1
	-- elseif button == 'dpleft' then
end;

---@param dt number
function Event:update(dt)
	self.textbox:update(dt)
	self:updateJoystick()
end;

function Event:updateJoystick()
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

function Event:draw()
	shove.beginDraw()

	shove.beginLayer('ui')
	self.textbox.draw()
	shove.endLayer()

	shove.endDraw()
end;

return Event