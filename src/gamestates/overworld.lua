local overworld = {}
local SpireGenerator = require('class.map.spire_generator')
local Map = require('class.map.map')

function overworld:init()
	shove.createLayer("background")
	shove.createLayer("ui")
end;

---@param previous table
---@param act integer
---@param floor integer
---@param characterTeam CharacterTeam
function overworld:enter(previous, act, floor, characterTeam)
	self.characterTeam = characterTeam
	self.act = act
	self.floor = floor

	if not self.map then
		self.map = self:generateMap()
	end
end;

---@return Map
function overworld:generateMap()
	local mapGenerator = SpireGenerator()
	local map = Map(mapGenerator:generateMap())
	map:connectRooms()
	return map
end;

function overworld:draw()
	shove.beginDraw()

	shove.beginLayer("ui")
	self.map:draw()
	shove.endLayer()

	shove.endDraw()
end;

return overworld