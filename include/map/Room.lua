---@meta

---@alias ROOM_TYPE
---| '"Combat"' # Combat encounter
---| '"Shop"'
---| '"Campfire"'
---| '"Event"'
---| '"Boss"'
---| '"NA"'

---@class Room
---@field dir string
---@field type ROOM_TYPE
---@field row integer
---@field col integer
---@field pos {x: integer, y: integer}
---@field nextRooms Room[]
---@field selected boolean
---@field sprite love.Image
---@field w integer
---@field h integer
---@field active boolean
---@field cleared boolean
---@field branches table
---@field alpha number
Room = {}

---@param pos table
function Room:init(pos) end

-- Sets room type and updates UI to match new type
---@param roomType ROOM_TYPE
function Room:setType(roomType) end

function Room:draw() end