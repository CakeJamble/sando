local Room = require('class.map.Room')
local Class = require('libs.hump.class')

--[[Provides the base class utilities for generating a Map. 
The MapGenerator class does not create a valid Map on its own, and derived classes
must implement their own methods to create valid connections between rooms.
Implementation of a Roguelike Map Generator, based on a tutorial by @GodotGameLab
that was remade in Lua for LOVE2D]]
---@class MapGenerator
local MapGenerator = Class{}

---@param numFloors integer
---@param mapWidth integer
---@param numPaths integer Number of starting points
---@param placementRandomness? integer Optional variable to customize the amount of natural offset
function MapGenerator:init(numFloors, mapWidth, numPaths, placementRandomness)
	self.xDist = 150
	self.yDist = 175
	self.placementRandomness = placementRandomness or 1
	self.numFloors = numFloors
	self.mapWidth = mapWidth
	self.numPaths = numPaths
	self.mapData = {}

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

-- Creates a completely linear path with no divergences
---@param intervals table
function MapGenerator:generateMap(intervals)
	local result = {}
	for i=1,self.numFloors do -- rows
		local roomType = self:calcRoomType(intervals, i)
		local room = self:createRoom(i)
		room:setType(roomType)
		table.insert(result, room)
	end

	return result
end;

-- Creates a room with a small pixel coordinate offset so it doesn't look to rigid
---@param row integer
---@param col? integer
---@return Room
function MapGenerator:createRoom(row, col)
	if not col then col = 1 end

	local offset = {
		x = love.math.random() * self.placementRandomness,
		y = love.math.random() * self.placementRandomness
	}
	local pos = {
		x = (col * self.xDist) + offset.x,
		y = (row * self.yDist) + offset.y,
		row = row,
		col = col
	}

	if row == self.numFloors then -- it's the boss
		pos.y = row * self.yDist
	end

	local room = Room(pos)
	return room
end;

--[[Uses weighted distribution values to determine the type of room. 
Returns `"NA"` if `intervals` is `nil`.]]
---@param intervals table
---@param currFloor integer 
---@return ROOM_TYPE
function MapGenerator:calcRoomType(intervals, currFloor)
	local roomType
	for k,v in pairs(intervals) do
		if currFloor % v == 0 then
			roomType = k
		end
	end
	if not roomType then roomType = "NA" end

	return roomType
end;

-- Create a boss room and connect the penultimate floor's rooms to it
function MapGenerator:setupBossRoom()
	local middle = math.floor(0.5 + self.mapWidth / 2)
	local bossRoom = self.mapData[self.numFloors][middle]
	bossRoom:setType("Boss")

	for j=1, self.mapWidth do
		local currRoom = self.mapData[self.numFloors - 1][j]

		if #currRoom.nextRooms > 0 then
			currRoom.nextRooms = {}
			table.insert(currRoom.nextRooms, bossRoom)
		end
	end
end;

--[[ Setup weighted randomness for room distribution.
Weight inversely correlates with expected number of appearances.]]
function MapGenerator:setupRandomRoomWeights()
	self.randomRoomTypeWeights.COMBAT = self.weights.COMBAT
	self.randomRoomTypeWeights.CAMPFIRE = self.weights.COMBAT + self.weights.CAMPFIRE
	self.randomRoomTypeWeights.EVENT = self.weights.COMBAT + self.weights.CAMPFIRE + self.weights.EVENT
	self.randomRoomTypeWeights.SHOP = self.weights.COMBAT + self.weights.CAMPFIRE + self.weights.EVENT + self.weights.SHOP
	self.randomRoomTypeTotalWeight = self.randomRoomTypeWeights.SHOP
end;

--[[Sets the Room's type based on the following constraints:

	1. No campfires spawn before the 5th floor
	2. Campfires do not spawn consecutively
	3. Shops do not spawn consecutively
	4. A campfire is always placed before the boss (redundant check for safety)
]]
---@param room Room
function MapGenerator:setRandomRoomType(room)
	local campfireBelow4 = true
	local consecutiveCampfire = true
	local consecutiveShop = true
	local campfireBeforeBoss = true

	local typeCandidate
	while campfireBelow4 or consecutiveCampfire or consecutiveShop or campfireBeforeBoss do
		typeCandidate = self:getRandomRoomTypeByWeight()

		local isCampfire = typeCandidate == "Campfire"
		local isShop = typeCandidate == "Shop"

		local hasCampfireParent = self:parentOfType(room, "Campfire")
		local hasShopParent = self:parentOfType(room, "Shop")

		campfireBelow4 = isCampfire and room.row < 4
		consecutiveCampfire = isCampfire and hasCampfireParent
		consecutiveShop = isShop and hasShopParent
		campfireBeforeBoss = isCampfire and room.row == self.numFloors - 1
	end

	room:setType(typeCandidate)
end;

---@return string
function MapGenerator:getRandomRoomTypeByWeight()
	local roll = love.math.random(0, self.randomRoomTypeTotalWeight)

	for roomType,weight in pairs(self.randomRoomTypeWeights) do
		if weight > roll then
			return roomType
		end
	end
	return "Combat"
end;

-- Validates whether the room has a parent (preceding room) of the type provided
---@param room Room
---@param roomType ROOM_TYPE
---@return boolean
function MapGenerator:parentOfType(room, roomType)
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


function MapGenerator:setupRoomTypes()
	-- floor 1 is always a standard combat
	for _,room in ipairs(self.mapData[1]) do
		if #room.nextRooms > 0 then
			room:setType("Combat")
		end
	end

	-- Floor 8 is always an event
	for _,room in ipairs(self.mapData[8]) do
		if #room.nextRooms > 0 then
			room:setType("Event")
		end
	end

	-- Floor 10 is always a shop
	for _,room in ipairs(self.mapData[10]) do
		if #room.nextRooms > 0 then
			room:setType("Shop")
		end
	end

	-- Penultimate room is always a campfire
	for _,room in ipairs(self.mapData[self.numFloors - 1]) do
		if #room.nextRooms > 0 then
			room:setType("Campfire")
		end
	end

	-- Assign all other Rooms a (weighted) random type of encounter
	for _,floor in ipairs(self.mapData) do
		for _,room in ipairs(floor) do
			if room.type == "NA" and #room.nextRooms > 0 then
				self:setRandomRoomType(room)
			end
		end
	end
end;

return MapGenerator