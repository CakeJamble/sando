local MapGenerator = require('class.map.MapGenerator')
local Class = require('libs.hump.class')

---@type SpireGenerator
local SpireGenerator = Class{__includes = MapGenerator}

function SpireGenerator:generateMap()
	self.mapData = self:generateGrid()

	local startingPoints = self:getRandomStartingPoints()
	for _,colIndex in ipairs(startingPoints) do
		local k = colIndex
		for i=1, self.numFloors - 1 do
			k = self:setupConnections(i, k, self.mapData[i][k])
		end
	end

	self:setupBossRoom()
	self:setupRandomRoomWeights()
	self:setupRoomTypes()

	return self.mapData
end;

function SpireGenerator:generateGrid()
	local result = {}
	for i=1, self.numFloors do
		local adjacentRooms = {}
		for j=1, self.mapWidth do
			local room = self:createRoom(i, j)
			table.insert(adjacentRooms, room)
		end
		table.insert(result, adjacentRooms)
	end
	return result
end;

function SpireGenerator:getRandomStartingPoints()
	local yCoords = {}
	local uniquePoints = 0

	while uniquePoints < 2 do
		uniquePoints = 0
		yCoords = {}

		for i=1, self.numPaths do
			local startingPoint = love.math.random(1, self.mapWidth)
			local hasY = false
			for _,y in ipairs(yCoords) do
				if y == startingPoint then
					hasY = true
					break
				end
			end

			if not hasY then uniquePoints = uniquePoints + 1 end
			table.insert(yCoords, startingPoint)
		end
	end
	return yCoords
end;

function SpireGenerator:setupConnections(row, col, room)
	local nextRoom

	while not nextRoom or self:wouldCrossExistingPath(row, col, nextRoom) do
		local randomCol = love.math.random(col - 1, col + 1)
		randomCol = math.max(1, math.min(randomCol, self.mapWidth))
		nextRoom = self.mapData[row + 1][randomCol]
	end

	table.insert(room.nextRooms, nextRoom)
	return nextRoom.col
end;

function SpireGenerator:wouldCrossExistingPath(row, col, room)
	local left, right
	if col > 0 then
		left = self.mapData[row][col - 1]
	end
	if col < self.mapWidth then
		right = self.mapData[row][col + 1]
	end

	-- If this path tries to go right and right-side neighboor is going left
	if right and room.col > col then
		for _,nextRoom in ipairs(right.nextRooms) do
			if nextRoom.col < room.col then
				return true
			end
		end
	end

	-- If this path tries to go left and left-side neighbor is going right
	if left and room.col < col then
		for _,nextRoom in ipairs(left.nextRooms) do
			if nextRoom.col > room.col then
				return true
			end
		end
	end

	return false
end;

return SpireGenerator