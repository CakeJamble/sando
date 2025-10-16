local overworld = {}
local SpireGenerator = require('class.map.spire_generator')
local Map = require('class.map.map')
local Log = require('class.log')
local flux = require('libs.flux')

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
	print(state)
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
end;

function overworld:draw()
	shove.beginDraw()

	shove.beginLayer("ui")
	self.map:draw()
	shove.endLayer()

	shove.endDraw()
end;

return overworld