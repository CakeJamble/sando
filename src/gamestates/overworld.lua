local overworld = {}
local SpireGenerator = require('class.map.spire_generator')
local Map = require('class.map.map')
local Log = require('class.log')
local flux = require('libs.flux')
local JoystickUtils = require("util.joystick_utils")
local Camera = require('libs.hump.camera')

function overworld:init()
	shove.createLayer("background")
	shove.createLayer("ui")
end;

---@param previous table
---@param act integer
---@param floor integer
---@param characterTeam CharacterTeam
---@param log? Log
function overworld:enter(previous, act, floor, characterTeam, log)
	self.characterTeam = characterTeam
	self.act = act
	self.floor = floor
	self.log = log or Log()
	if not self.map then
		self.map = self:generateMap()
	end

	self.map:checkActiveRooms(self.floor)

	self.lookY = 0
	camera.smoother = Camera.smooth.damped(10.0)
end;

---@return Map
function overworld:generateMap()
	local numFloors, mapWidth, numPaths = 15, 7, 6
	local mapGenerator = SpireGenerator(numFloors, mapWidth, numPaths)
	local map = Map(mapGenerator:generateMap(), numFloors, mapWidth, numPaths)
	map:connectRooms()
	return map
end;

function overworld:switchState()
	local state = string.lower(self.map.selected.type)
	local options = {}

	if state == "combat" then
		options.act = self.act
		options.floor = self.floor
		options.team = self.characterTeam
	elseif state == "shop" then
		options = self.characterTeam
	end

	Gamestate.switch(states[state], options)
end;


function overworld:gamepadpressed(joystick, button)
	if button == "a" and self.map.selected then
		self:switchState()
	else
		self.map:gamepadpressed(joystick, button)
	end
end;

function overworld:update(dt)
	flux.update(dt)

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

    -- Right Stick
	  if JoystickUtils.isAxisRepeaterTriggered(input.joystick, 'up', 'right') then
	  	self:scrollCamera('up')
	  elseif JoystickUtils.isAxisRepeaterTriggered(input.joystick, 'down', 'right') then
	  	self:scrollCamera('down')
	  end
  end
end;

-- Only scrolls in Y direction
---@param direction string
function overworld:scrollCamera(direction)
	local scrollStep = 64
	local _, cy = camera:position()
	cy = cy + self.lookY

	if direction == 'up' then
		cy = cy - scrollStep
	elseif direction == 'down' then
		cy = cy + scrollStep
	end

	camera:lockY(cy)
end;

function overworld:draw()
	shove.beginDraw()
	camera:attach()

	shove.beginLayer("ui")
	self.map:draw()
	shove.endLayer()

	camera:detach()
	shove.endDraw()
end;

return overworld