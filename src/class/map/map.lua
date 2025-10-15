local Class = require('libs.hump.class')

---@class Map
local Map = Class{}

---@param mapData table[] 2D Array of Room objects
function Map:init(mapData)
	self.mapData = mapData
	self.lines = {}
end;

function Map:connectRooms()
	for _,row in ipairs(self.mapData) do
		for _,room in ipairs(row) do
			self:connectLines(room)
		end
	end
end;

---@param room Room
function Map:connectLines(room)
	if not room.nextRooms then return end

	-- Points start from center-bottom of node and connect to top of next node
	local x1,y1 = room.pos.x + (room.w / 2), room.pos.y + room.h
	for _,nextRoom in ipairs(room.nextRooms) do
		local line = {x1, y1, nextRoom.pos.x + (nextRoom.w / 2), nextRoom.pos.y}
		table.insert(self.lines, line)
	end
end;

function Map:draw()
	for _,row in ipairs(self.mapData) do
		for _,room in ipairs(row) do
			room:draw()
		end
	end

	for _,line in ipairs(self.lines) do
		love.graphics.line(line)
	end
end;

return Map