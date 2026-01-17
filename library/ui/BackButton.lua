---@meta

-- For the player too get out of the target select during combat
---@class BackButton
---@field pos {x: integer, y: integer}
---@field path string
---@field button love.Image
---@field playerUsingNonOffensiveSkill boolean
BackButton = {}

---@param pos { [string]: number }
function BackButton:init(pos) end

function BackButton:draw() end