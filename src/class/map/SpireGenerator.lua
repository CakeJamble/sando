local MapGenerator = require('class.map.MapGenerator')
local Class = require('libs.hump.class')

--[[Generates a Map from an internal map data grid that ensures that generated paths
will not cross over one another, similar to Slay the Spire's map.]]
---@class SpireGenerator: MapGenerator
local SpireGenerator = Class{__includes = MapGenerator}

--[[ Generates a linear path with branches that may merge and diverge, 
but not cross over one another]]
---@return table[]
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

-- Generate a grid based on the constraints set by `self.numFloors` & `self.mapWidth`
---@return table[]
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

--[[ Creates an array of integers that represent the column values for the 
positions of the first floor of Rooms]]
---@return integer[]
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

--[[ Checks existing paths and generates the next floor of Rooms, such that the 
next floor will not result in any paths that cross over each other.]]
---@param row integer
---@param col integer
---@param room Room
---@return integer
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

--[[ Validates that a Room at a given (row,col) position 
will not result in a path that crosses over an existing path]]
---@param row integer
---@param col integer
---@param room Room
---@return boolean
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