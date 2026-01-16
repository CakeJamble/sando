---@meta


--[[Provides the base class utilities for generating a Map. 
The MapGenerator class does not create a valid Map on its own, and derived classes
must implement their own methods to create valid connections between rooms.
Implementation of a Roguelike Map Generator, based on a tutorial by @GodotGameLab
that was remade in Lua for LOVE2D]]
---@class MapGenerator
---@field xDist integer
---@field yDist integer
---@field placementRandomness integer Small pixel offset
---@field numFloors integer
---@field mapWidth integer Max number of Rooms on a floor
---@field numPaths integer Number of starting points
---@field mapData table[] 2D Array of Room objects
---@field weights { COMBAT: integer, SHOP: integer, CAMPFIRE: integer, EVENT: integer }
---@field randomRoomTypeWeights { COMBAT: integer, SHOP: integer, CAMPFIRE: integer, EVENT: integer }
---@field randomRoomTypeTotalWeight integer
MapGenerator = {}

---@param numFloors integer
---@param mapWidth integer
---@param numPaths integer Number of starting points
---@param placementRandomness? integer Optional variable to customize the amount of natural offset
function MapGenerator:init(numFloors, mapWidth, numPaths, placementRandomness) end

-- Creates a completely linear path with no divergences
---@param intervals table
function MapGenerator:generateMap(intervals) end

--[[Creates a room with a small pixel coordinate offset so it doesn't look to rigid.
Always places the room in the center column of the map]]
---@param row integer
---@return Room
function MapGenerator:createRoom(row) end

-- Creates a room with a small pixel coordinate offset so it doesn't look to rigid
---@param row integer
---@param col integer
---@return Room
function MapGenerator:createRoom(row, col) end

--[[Uses weighted distribution values to determine the type of room. 
Returns `"NA"` if `intervals` is `nil`.]]
---@param intervals table
---@param currFloor integer 
---@return ROOM_TYPE
function MapGenerator:calcRoomType(intervals, currFloor) end

-- Create a boss room and connect the penultimate floor's rooms to it
function MapGenerator:setupBossRoom() end

--[[ Setup weighted randomness for room distribution.
Weight inversely correlates with expected number of appearances.]]
function MapGenerator:setupRandomRoomWeights() end

--[[Sets the Room's type based on the following constraints:

	1. No campfires spawn before the 5th floor
	2. Campfires do not spawn consecutively
	3. Shops do not spawn consecutively
	4. A campfire is always placed before the boss (redundant check for safety)
]]
---@param room Room
function MapGenerator:setRandomRoomType(room) end

---@return string
function MapGenerator:getRandomRoomTypeByWeight() end

-- Validates whether the room has a parent (preceding room) of the type provided
---@param room Room
---@param roomType ROOM_TYPE
---@return boolean
function MapGenerator:parentOfType(room, roomType) end

function MapGenerator:setupRoomTypes() end