local Class = require('libs.hump.class')
local AxisRepeater = require('class.input.AxisRepeater')

---@class AcceleratedRepeater: AxisRepeater
local AcceleratedRepeater = Class{__includes = AxisRepeater}

---@param axisValue number
---@param dt number
function AcceleratedRepeater:update(axisValue, dt)
  local pulse = AxisRepeater.update(self, axisValue, dt)

  if pulse ~= 0 then
    self.repeatDelay = math.max(0.05, self.repeatDelay * 0.9)
  end

  return pulse
end
