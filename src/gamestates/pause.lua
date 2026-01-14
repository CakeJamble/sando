local Pause = {}
local initLuis = require("libs.luis.init")
local luis = initLuis("libs/luis/widgets")
local flux = require('libs.flux')

function Pause:init()
    shove.createLayer("ui", {zIndex = 10})
    self.supportedResolutions = GameSettings.supportedResolutions
    self.resIndex = 4
end;

function Pause:enter(previous)
    luis.initJoysticks()
    luis.setGridSize(32)
    self.luisTime = 0
    GameSettings.musicManager:play('ny_house_party')
    self:defineWidgets()
    luis.newLayer("main")
    luis.setCurrentLayer("main")
    self:createElements()
    luis.showGrid = true
end;

function Pause:defineWidgets()
    local settings = GameSettings.settings
    self.musicVolSlider = luis.newSlider(0, 1, settings.musicVolume, 10, 1,
        function(value)
            GameSettings.musicManager:setGlobalVolume(value)
            GameSettings:setSetting("musicVolume", value)
        end, 1, 1)
    self.sfxSlider = luis.newSlider(0, 1, settings.sfxVolume, 10, 1,
        function(value)
            GameSettings.sfxManager:setGlobalVolume(value)
            GameSettings:setSetting("sfxVolume", value)
    end, 3, 1)
    self.sfxButton = luis.newButton("Test", 2, 1, nil,
        function()
            GameSettings.sfxManager:play("uke")
        end, 3, 12)
    self.resDownButton = luis.newButton("Smaller", 2, 2, nil,
        function()
            self.resIndex = math.max(1, self.resIndex - 1)
            local newResolution = self.supportedResolutions[self.resIndex]
            local width, height = newResolution[1], newResolution[2]
            GameSettings:setSetting("resolution", {w = width, h = height})
            shove.setWindowMode(width, height)
            GameSettings:setSetting("resolution", {w=width, h=height})
        end, 6, 1)
    self.resUpButton = luis.newButton("Larger", 2, 2, nil,
        function()
            self.resIndex = math.min(#self.supportedResolutions, self.resIndex + 1)
            local newResolution = self.supportedResolutions[self.resIndex]
            local width, height = newResolution[1], newResolution[2]
            GameSettings:setSetting("resolution", {w = width, h = height})
            shove.setWindowMode(width, height)
        end, 6, 8)
    self.restoreDefaultsButton = luis.newButton("Restore Defaults", 2, 2, nil,
        function() 
            GameSettings:restoreAllDefaults()
            self:restoreDefaults()
        end, 16, 1)
end;

function Pause:createElements()
    luis.createElement(luis.currentLayer, "Slider", self.musicVolSlider)
    luis.createElement(luis.currentLayer, "Slider", self.sfxSlider)
    luis.createElement(luis.currentLayer, "Button", self.sfxButton)
    luis.createElement(luis.currentLayer, "Button", self.resDownButton)
    luis.createElement(luis.currentLayer, "Button", self.resUpButton)
    luis.createElement(luis.currentLayer, "Button", self.restoreDefaultsButton)
end;

function Pause:leave()
    GameSettings.musicManager:stopAll()
    GameSettings:saveSettings()
end;

---@return string result
function Pause:resolutionToString()
    local resolution = self.supportedResolutions[self.resIndex]
    local  width, height = tostring(resolution[1]), tostring(resolution[2])
    local result = width .. ' x ' .. height
    return result
end;

function Pause:restoreDefaults()
    self.musicVolSlider.value = 1
    self.sfxSlider.value = 1
end;

---@param dt number
function Pause:update(dt)
  self.luisTime = self.luisTime + dt
  if self.luisTime >= 1/60 then
    flux.update(self.luisTime)
    self.luisTime = 0
  end
  -- luis.updateScale()
  luis.update(dt)

  Player:update()

  if Player:pressed('down') then
    luis.moveFocus('next')
  elseif Player:pressed('up') then
    luis.moveFocus('previous')
  elseif Player:pressed('left') then
    local curr = luis.currentFocus
    if curr.type == "Slider" then
        curr:setValue(curr.value - (curr.max - curr.min) * 0.01)
    end
  elseif Player:pressed('right') then
    local curr = luis.currentFocus
    if curr.type == "Slider" then
        curr:setValue(curr.value + (curr.max - curr.min) * 0.01)
    end
  elseif Player:released('confirm') then
    local curr = luis.currentFocus
    if curr.type == "Button" then
        curr:onRelease()
    elseif curr.type == "Slider" then
        luis.moveFocus("next")
    end
  elseif Player:released("cancel") then
    Gamestate.switch(states["MainMenu"])
  end
end;

function Pause:mousepressed(x, y, button, istouch)
    luis.mousepressed(x, y, button, istouch)
end;

function Pause:mousereleased(x, y, button, istouch)
    luis.mousereleased(x, y, button, istouch)
end;

function Pause:draw()
    luis.draw()
end;

return Pause