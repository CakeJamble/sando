local Room = require('class.map.Room')
local Class = require('libs.hump.class')

---@type MapGenerator
local MapGenerator = Class{}

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

function MapGenerator:createRoom(row, col)
	if not col then
		-- If not given, then just set it to the center of the map
		col = math.floor(0.5 + (self.mapWidth / 2)) 
	end

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

function MapGenerator:setupRandomRoomWeights()
	self.randomRoomTypeWeights.COMBAT = self.weights.COMBAT
	self.randomRoomTypeWeights.CAMPFIRE = self.weights.COMBAT + self.weights.CAMPFIRE
	self.randomRoomTypeWeights.EVENT = self.weights.COMBAT + self.weights.CAMPFIRE + self.weights.EVENT
	self.randomRoomTypeWeights.SHOP = self.weights.COMBAT + self.weights.CAMPFIRE + self.weights.EVENT + self.weights.SHOP
	self.randomRoomTypeTotalWeight = self.randomRoomTypeWeights.SHOP
end;

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

function MapGenerator:getRandomRoomTypeByWeight()
	local roll = love.math.random(0, self.randomRoomTypeTotalWeight)

	for roomType,weight in pairs(self.randomRoomTypeWeights) do
		if weight > roll then
			return roomType
		end
	end
	return "Combat"
end;

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

-- TODO: Make an overload where you can supply the defaults instead
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