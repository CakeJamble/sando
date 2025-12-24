--[[
Implementation of a Roguelike Map Generator, based on a tutorial by @GodotGameLab
that was remade in Lua for LOVE2D
]]

local Room = require('class.map.Room')
local Class = require('libs.hump.class')

---@class MapGenerator
local MapGenerator = Class{}

---@param numFloors integer
---@param mapWidth integer
---@param numPaths integer
---@param placementRandomness? integer
function MapGenerator:init(numFloors, mapWidth, numPaths, placementRandomness)
	self.xDist = 30
	self.yDist = 25
	self.placementRandomness = placementRandomness or 1
	self.numFloors = numFloors
	self.mapWidth = mapWidth
	self.numPaths = numPaths
	self.mapData = {}
end;

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

return MapGenerator