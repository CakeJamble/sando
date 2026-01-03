local Class = require('libs.hump.class')

---@alias ROOM_TYPE
---| '"Combat"' # Combat encounter
---| '"Shop"'
---| '"Campfire"'
---| '"Event"'
---| '"Boss"'
---| '"NA"'

---@class Room
---@field dir string
local Room = Class{dir = "asset/sprites/map/"}


---@param pos table
function Room:init(pos)
	self.type = "NA"
	self.row = pos.row
	self.col = pos.col
	self.pos = {x=pos.x, y=pos.y}
	self.nextRooms = {}
	self.selected = false
	self.sprite = nil
	self.w, self.h = 20, 20
	self.active = false
	self.cleared = false
	self.branches = {}
	self.alpha = 0.5
end;

-- Sets room type and updates UI to match new type
---@param roomType ROOM_TYPE
function Room:setType(roomType)
	self.type = roomType
	local path = Room.dir .. roomType .. ".png"

	-- uncomment me when the assets are here!
	-- self.sprite = love.graphics.newImage(path)
end;

function Room:draw()
	if self.type ~= "NA" then
		local mode = "line"
		local x,y = self.pos.x, self.pos.y

		love.graphics.setColor(1,1,1, self.alpha)

		love.graphics.rectangle(mode, x, y, self.w, self.h)
		love.graphics.print(self.type, x, y, 0, 0.3, 0.3)

		for _,line in ipairs(self.branches) do
			love.graphics.line(line)
		end

		love.graphics.setColor(1,1,1,1)
	end
end;


return Room