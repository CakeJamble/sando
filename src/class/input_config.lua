--! filename: input config

Class = require 'libs.hump.class'
InputConfig = Class{}

function InputConfig:init()
  self.listeners = {}
  self.xboxInputs = {   -- gamepad button : timestamp
    ['a'] = {},
    ['b'] = {},
    ['x'] = {},
    ['y'] = {},
    ['back'] = {},
    ['start'] = {},
    ['leftshoulder'] = {},
    ['rightshoulder'] = {},
    ['dpup'] = {},
    ['dpdown'] = {},
    ['dpleft'] = {},
    ['dpright'] = {}
  }
  self.currentControllerInputs = self.xboxInputs
  self.timeStamp = 0
  self.listening = false
end;

function InputConfig:update()
  if self.listening then
    self.timeStamp = self.timeStamp + 1
  end
end;

function InputConfig:resetTimeStamp()
  self.timeStamp = 0
end;

function InputConfig:insertInput(input, timeStamp)
  table.insert(self.currentControllerInputs[input], timeStamp)
end;

function InputConfig:validateQTE(input, qteWindow) --> bool
  local timeStamps = self.currentControllerInputs[input]
  for i=1, #timeStamps do
    if InputConfig:isWithinWindow(timeStamps[i], qteWindow) then
      return true
    end
  end
  return false
end;

function InputConfig:isWithinWindow(timeStamp, qteWindow)
  local windowOpen = timeStamp[1]
  local windowClose = timeStamp[2]
  
  return timeStamp >= windowOpen and timeStamp <= windowClose
end;

--[[ Redundant fcn
function InputConfig:notifyListeners()
  Signal.emit('input')
end;
]]
  
  