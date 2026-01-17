local MapGenerator = require('class.map.MapGenerator')
local Class = require('libs.hump.class')

---@type LinearMapGenerator
local LinearMapGenerator = Class{__includes = MapGenerator}

function LinearMapGenerator:init(numFloors)
	MapGenerator.init(self, numFloors, 3, 1)
end;

function LinearMapGenerator:generateMap()
	self.mapData = self:generateGrid()
	local startingPoint = math.floor(0.5 + self.mapWidth)
	for i=1, self.numFloors - 1 do
		startingPoint = self:setupConnections(i, startingPoint, self.mapData[i][startingPoint])
	end

	self:setupBossRoom()
	self:setupRandomRoomWeights()
	self:setupRoomTypes()

	return self.mapData
end;

function LinearMapGenerator:generateGrid()
	local result = {}
	local k = self.mapWidth
	local adjacentRooms = {}
	for j=1, self.mapWidth do
		local room = self:createRoom(i, j)
		table.insert(adjacentRooms, room)
	end
	table.insert(result, adjacentRooms)
	return result
end;

function LinearMapGenerator:setupConnections(row, col, room)
	local randomCol = love.math.random(col - 1, col + 1)
	randomCol = math.max(1, math.min(randomCol, self.mapWidth))
	local nextRoom = self.mapData[row + 1][randomCol]
	table.insert(room.nextRooms, nextRoom)
	return nextRoom.col
end;

return LinearMapGenerator