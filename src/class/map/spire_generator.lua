--[[
Implementation of a Roguelike Map Generator, based on a tutorial by @GodotGameLab
that was remade in Lua for LOVE2D
]]

local MapGenerator = require('class.map.map_generator')
local Class = require('libs.hump.class')

---@class SpireGenerator: MapGenerator
local SpireGenerator = Class{__includes = MapGenerator}

---@param numFloors integer
---@param mapWidth integer
---@param numPaths integer
function SpireGenerator:init(numFloors, mapWidth, numPaths)
	MapGenerator.init(self, numFloors, mapWidth, numPaths)
	self.weights = {
		COMBAT = 10,
		SHOP = 3,
		CAMPFIRE = 4,
		EVENT = 2
	}

	self.randomRoomTypeWeights = {
		COMBAT = 0,
		SHOP = 0,
		CAMPFIRE = 0,
		EVENT = 2
	}

	self.randomRoomTypeTotalWeight = 0
end;

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

function SpireGenerator:setupBossRoom()
	local middle = math.floor(0.5 + self.mapWidth / 2)
	local bossRoom = self.mapData[self.numFloors][middle]
	bossRoom:setType("BOSS")
	print(bossRoom.pos.x, bossRoom.pos.y)

	for j=1, self.mapWidth do
		local currRoom = self.mapData[self.numFloors - 1][j]

		if #currRoom.nextRooms > 0 then
			currRoom.nextRooms = {}
			table.insert(currRoom.nextRooms, bossRoom)
		end
	end
end;

function SpireGenerator:setupRandomRoomWeights()
	self.randomRoomTypeWeights.COMBAT = self.weights.COMBAT
	self.randomRoomTypeWeights.CAMPFIRE = self.weights.COMBAT + self.weights.CAMPFIRE
	self.randomRoomTypeWeights.EVENT = self.weights.COMBAT + self.weights.CAMPFIRE + self.weights.EVENT
	self.randomRoomTypeWeights.SHOP = self.weights.COMBAT + self.weights.CAMPFIRE + self.weights.EVENT + self.weights.SHOP
	self.randomRoomTypeTotalWeight = self.randomRoomTypeWeights.SHOP
end;

function SpireGenerator:setupRoomTypes()
	-- floor 1 is always a standard combat
	for _,room in ipairs(self.mapData[1]) do
		if #room.nextRooms > 0 then
			room:setType("COMBAT")
		end
	end

	-- Floor 8 is always an event
	for _,room in ipairs(self.mapData[8]) do
		if #room.nextRooms > 0 then
			room:setType("EVENT")
		end
	end

	-- Floor 10 is always a shop
	for _,room in ipairs(self.mapData[10]) do
		if #room.nextRooms > 0 then
			room:setType("SHOP")
		end
	end

	-- Penultimate room is always a campfire
	for _,room in ipairs(self.mapData[self.numFloors - 1]) do
		if #room.nextRooms > 0 then
			room:setType("CAMPFIRE")
		end
	end

	for _,floor in ipairs(self.mapData) do
		for _,room in ipairs(floor) do
			if room.type == "NA" and #room.nextRooms > 0 then
				self:setRandomRoomType(room)
			end
		end
	end

end;

---@param room Room
function SpireGenerator:setRandomRoomType(room)
	local campfireBelow4 = true
	local consecutiveCampfire = true
	local consecutiveShop = true
	local campfireBeforeBoss = true

	local typeCandidate
	while campfireBelow4 or consecutiveCampfire or consecutiveShop or campfireBeforeBoss do
		typeCandidate = self:getRandomRoomTypeByWeight()

		local isCampfire = typeCandidate == "CAMPFIRE"
		local isShop = typeCandidate == "SHOP"

		local hasCampfireParent = self:parentOfType(room, "CAMPFIRE")
		local hasShopParent = self:parentOfType(room, "SHOP")

		campfireBelow4 = isCampfire and room.row < 4
		consecutiveCampfire = isCampfire and hasCampfireParent
		consecutiveShop = isShop and hasShopParent
		campfireBeforeBoss = isCampfire and room.row == self.numFloors - 1
	end

	room:setType(typeCandidate)
end;

---@return string
function SpireGenerator:getRandomRoomTypeByWeight()
	local roll = love.math.random(0, self.randomRoomTypeTotalWeight)

	for roomType,weight in pairs(self.randomRoomTypeWeights) do
		if weight > roll then
			return roomType
		end
	end
	return "COMBAT"
end;

---@param room Room
---@param roomType ROOM_TYPE
---@return boolean
function SpireGenerator:parentOfType(room, roomType)
	local parents = {}

	local has = function(list, obj)
		for _,item in ipairs(list) do
			if item == obj then
				return true
			end
		end
		return false
	end

	-- left parent
	if room.col > 1 and room.row > 1 then
		local parentCandidate = self.mapData[room.row - 1][room.col - 1]

		if has(parentCandidate.nextRooms, room) then
			table.insert(parents, parentCandidate)
		end
	end

	-- parent below
	if room.row > 1 then
		local parentCandidate = self.mapData[room.row - 1][room.col]

		if has(parentCandidate.nextRooms, room) then
			table.insert(parents, parentCandidate)
		end
	end

	-- right parent
	if room.col < self.mapWidth and room.row > 1 then
		local parentCandidate = self.mapData[room.row - 1][room.col + 1]

		if has(parentCandidate.nextRooms, room) then
			table.insert(parents, parentCandidate)
		end
	end

	-- check if room arg matches any parent room types
	for _,parent in ipairs(parents) do
		if parent.type == roomType then
			return true
		end
	end
	return false

end;

return SpireGenerator