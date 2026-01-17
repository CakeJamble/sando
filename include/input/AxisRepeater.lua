---@meta

---@class AxisRepeater
---@field threshold number
---@field initialDelay number
---@field repeatDelay number
---@field timer number
---@field direction number
---@field fired boolean
AxisRepeater = {}

--[[Instantiates an AxisRepeater from default values

    - `threshold`: 0.5
    - `initialDelay`: 0.4
    - `repeatDelay`: 0.1
]]
function AxisRepeater:init() end

-- Instantiates an AxisRepeater from a table of settings
---@param opts {threshold: number, initialDelay: number, repeatDelay: number}
function AxisRepeater:init(opts) end

---@param axisValue number
---@param dt number
function AxisRepeater:update(axisValue, dt) end