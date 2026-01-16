---@meta

---@class LinearMapGenerator: MapGenerator
LinearMapGenerator = {}

function LinearMapGenerator:init(numFloors) end

-- Generate a linear path from a single starting point that may merge and diverge
---@return table[]
function LinearMapGenerator:generateMap() end

-- Generate a grid with a single starting point
---@return table[]
function LinearMapGenerator:generateGrid() end

-- Generates the next floor and connects it to the previous floor
---@param row integer
---@param col integer
---@param room Room
---@return integer
function LinearMapGenerator:setupConnections(row, col, room) end