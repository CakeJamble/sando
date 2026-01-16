---@meta

---@class Button
---@field BASE_DX integer
---@field SPACER integer
---@field SCALE_DOWN number
---@field PATH string
---@field moveDuration number
---@field SIDE_BUTTON_SCALE number
---@field BACK_BUTTON_SCALE number
---@field MOVE_SCALE number
---@field pos {x: integer, y: integer, scale: number}
---@field index integer
---@field layer integer
---@field button love.Image
---@field dims {w: integer, h: integer}
---@field tX integer
---@field tY integer
---@field dX integer
---@field active boolean
---@field targets {characters: Character[], enemies: Enemy[]}
---@field displaySkillList boolean
---@field isRotatingRight boolean
---@field isRotatingLeft boolean
---@field description string
---@field descriptionPos {x: integer, y: integer}
---@field easeType string
---@field isActiveButton boolean
---@field scaleFactor number
Button = {}

---@param pos { [string]: number }
---@param index integer
---@param path string
function Button:init(pos, index, path) end

---@param landingPos { [string]: number }
---@param  duration number
---@param easeType? string
function Button:tween(landingPos, duration, easeType) end

---@return integer
function Button:idxToLayer() end

---@param tX { [string]: number }
---@param speedMul number
function Button:setTargetPos(tX, speedMul) end

---@param  isActive boolean
function Button:setIsActiveButton(isActive) end

function Button:draw() end
