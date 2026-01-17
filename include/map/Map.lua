---@meta

---@class Map
---@field mapData table[] 2D Array of Room objects
---@field numFloors integer
---@field width integer Max number of Rooms on any given floor
---@field numPaths integer Number of starting points
---@field selected table
---@field selectedIndex integer
---@field activeRooms Room[]
---@field pos {x: integer, y: integer}
Map = {}

---@param mapData table[] 2D Array of Room objects
---@param numFloors integer
---@param width integer Max number of Rooms on any given floor
---@param numPaths integer Number of starting points
function Map:init(mapData, numFloors, width, numPaths) end

-- Connect rooms with lines to visualize paths
function Map:connectRooms() end

-- Connect one room to parent(s) by creating lines and assigning it to the room
---@param room Room
function Map:connectLines(room) end

-- Sets validated rooms to active and changes their opacities
---@param floor integer
function Map:checkActiveRooms(floor) end

-- Check if any of the parent rooms are marked as cleared
---@param room Room
---@return boolean
function Map:clearedParents(room) end

---@param log Log
---@param floor integer
function Map:logSelection(log, floor) end

---@param dt number
function Map:update(dt) end

function Map:draw() end
function Map:drawRooms() end
function Map:drawSelectBox() end