---@meta

--[[Generates a Map from an internal map data grid that ensures that generated paths
will not cross over one another, similar to Slay the Spire's map.]]
---@class SpireGenerator: MapGenerator
SpireGenerator = {}

--[[ Generates a linear path with branches that may merge and diverge, 
but not cross over one another]]
---@return table[]
function SpireGenerator:generateMap() end

-- Generate a grid based on the constraints set by `self.numFloors` & `self.mapWidth`
---@return table[]
function SpireGenerator:generateGrid() end

--[[ Creates an array of integers that represent the column values for the 
positions of the first floor of Rooms]]
---@return integer[]
function SpireGenerator:getRandomStartingPoints() end

--[[ Checks existing paths and generates the next floor of Rooms, such that the 
next floor will not result in any paths that cross over each other.]]
---@param row integer
---@param col integer
---@param room Room
---@return integer
function SpireGenerator:setupConnections(row, col, room) end

--[[ Validates that a Room at a given (row,col) position 
will not result in a path that crosses over an existing path]]
---@param row integer
---@param col integer
---@param room Room
---@return boolean
function SpireGenerator:wouldCrossExistingPath(row, col, room) end