local Class = require('libs.hump.class')
local flux = require('libs.flux')

---@class Map
local Map = Class{}

---@param mapData table[] 2D Array of Room objects
---@param numFloors integer
---@param width integer
---@param numPaths integer
function Map:init(mapData, numFloors, width, numPaths)
	self.mapData = mapData
	self.numFloors = numFloors
	self.width = width
	self.numPaths = numPaths
	self.selected = nil
	self.selectedIndex = nil
	self.activeRooms = {}
	self.pos = {
		x = shove.getViewportWidth() / 4,
		y = 0
	}
end;

-- Connect rooms with lines to visualize paths
function Map:connectRooms()
	for _,row in ipairs(self.mapData) do
		for _,room in ipairs(row) do
			self:connectLines(room)
		end
	end
end;

-- Connect one room to parent(s) by creating lines and assigning it to the room
---@param room Room
function Map:connectLines(room)
	if not room.nextRooms then return end

	-- Points start from center-bottom of node and connect to top of next node
	local x1,y1 = room.pos.x + (room.w / 2), room.pos.y + room.h
	for _,nextRoom in ipairs(room.nextRooms) do
		local line = {x1, y1, nextRoom.pos.x + (nextRoom.w / 2), nextRoom.pos.y}
		table.insert(room.branches, line)
	end
end;

-- Sets validated rooms to active and changes their opacities
---@param floor integer
function Map:checkActiveRooms(floor)
	self.activeRooms = {}
	for _,room in ipairs(self.mapData[floor]) do
		if room.type ~= "NA" then
			if floor == 1 and not room.cleared then
				room.active = true
			elseif self:clearedParents(room) then
				room.active = true
			end

			if room.active then
				table.insert(self.activeRooms, room)
				flux.to(room, 1, {alpha = 1})
			end
		end
	end
end;

-- Check if any of the parent rooms are marked as cleared
---@param room Room
---@return boolean
function Map:clearedParents(room)
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
	if room.col < self.width and room.row > 1 then
		local parentCandidate = self.mapData[room.row - 1][room.col + 1]

		if has(parentCandidate.nextRooms, room) then
			table.insert(parents, parentCandidate)
		end
	end

	for _,parent in ipairs(parents) do
		if parent.cleared then
			return true
		end
	end
	return false
end;

---@param log Log
---@param floor integer
function Map:logSelection(log, floor)
	log:logEncounterSelection(self.selectedIndex, self.mapData[floor])

	for _,room in ipairs(self.mapData[floor]) do
		room.alpha = 0.5
	end
end;

---@param joystick love.Joystick
---@param button love.GamepadButton
function Map:gamepadpressed(joystick, button)
	if not self.selected then
		self.selected = self.activeRooms[1]
		self.selectedIndex = 1
	elseif button == "dpleft" then
		self.selectedIndex = self.selectedIndex - 1
		if self.selectedIndex <= 0 then
			self.selectedIndex = #self.activeRooms
		end
		self.selected = self.activeRooms[self.selectedIndex]
	elseif button == "dpright" then
		self.selectedIndex = self.selectedIndex + 1
		if self.selectedIndex > #self.activeRooms then
			self.selectedIndex = 1
		end
		self.selected = self.activeRooms[self.selectedIndex]
	end
end;

function Map:draw()
	-- Center map
	local dx,dy = self.pos.x, self.pos.y
	love.graphics.translate(dx, dy)

	self:drawRooms()
	self:drawSelectBox()
end;

function Map:drawRooms()
	for _,row in ipairs(self.mapData) do
		for _,room in ipairs(row) do
			room:draw()
		end
	end
end;

function Map:drawSelectBox()
	if self.selected then
		love.graphics.setColor(0, 0, 1)
		local x,y,w,h = self.selected.pos.x, self.selected.pos.y, self.selected.w, self.selected.h
		love.graphics.rectangle("line", x, y, w, h)
		love.graphics.setColor(1,1,1)
	end
end;

return Map