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
function overworld:enter(previous, characterTeam, log)
	self.characterTeam = characterTeam
	self.log = log or Log()
	self.act = self.log.act
	self.floor = self.log.floor
	self.map = self.log.map or self:generateMap()
	
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
	-- self.log:setMap(map)
	self.log.map = map
	return map
end;

function overworld:switchState()
	self.map:logSelection(self.log, self.floor)
	local state = string.lower(self.map.selected.type)
	self.map.selected = nil
	local options = {
		team = self.characterTeam,
		log = self.log,
	}

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