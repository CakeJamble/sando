local Pause = {}
local initLuis = require("libs.luis.init")
local luis = initLuis("libs/luis/widgets")
local flux = require('libs.flux')

function Pause:init()
    shove.createLayer("ui", {zIndex = 10})
    self.supportedResolutions = GameSettings.supportedResolutions
    luis.setGridSize(32)
    self.resIndex = 4
end;

function Pause:enter(previous)
    self.luisTime = 0
    GameSettings.musicManager:play('ny_house_party')

    self.musicVolSlider = luis.newSlider(0, 1, 1, 10, 1,
        function(value)
            GameSettings.musicManager:setGlobalVolume(value)
        end, 1, 1)
    self.sfxSlider = luis.newSlider(0, 1, 1, 10, 1,
        function(value)
            GameSettings.sfxManager:setGlobalVolume(value)
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
            -- shove.setWindowMode(width, height)
        end, 6, 1)
    self.resUpButton = luis.newButton("Larger", 2, 2, nil,
        function()
            self.resIndex = math.min(#self.supportedResolutions, self.resIndex + 1)
            local newResolution = self.supportedResolutions[self.resIndex]
            local width, height = newResolution[1], newResolution[2]
            GameSettings:setSetting("resolution", {w = width, h = height})
            -- shove.setWindowMode(width, height)
        end, 6, 8)
    self.brightnessSlider = luis.newSlider(0, 2, 1, 10, 1,
        function(value)
            GameSettings.settings.display.brightness = value
            -- Brightness = value
        end, 8, 1)
    self.constrastSlider = luis.newSlider(0, 2, 1, 10, 1,
        function(value)
            GameSettings.settings.display.contrast = value
            -- Contrast = value
        end, 10, 1)
    self.saturationSlider = luis.newSlider(0, 2, 1, 10, 1,
        function(value)
            GameSettings.settings.display.saturation = value
            -- Saturation = value
        end, 12, 1)
    self.hueShiftSlider = luis.newSlider(0, 1, 0, 10, 1,
        function(value)
            GameSettings.settings.display.hueShift = value
            -- HueShift = value
        end, 14, 1)
    self.restoreDefaultsButton = luis.newButton("Restore Defaults", 2, 2, nil,
        function() 
            GameSettings:restoreAllDefaults()
            self:restoreDefaults()
        end, 16, 1)
    luis.newLayer("main")
    luis.setCurrentLayer("main")
    luis.createElement(luis.currentLayer, "Slider", self.musicVolSlider)
    luis.createElement(luis.currentLayer, "Slider", self.sfxSlider)
    luis.createElement(luis.currentLayer, "Button", self.sfxButton)
    luis.createElement(luis.currentLayer, "Button", self.resDownButton)
    luis.createElement(luis.currentLayer, "Button", self.resUpButton)
    luis.createElement(luis.currentLayer, "Slider", self.brightnessSlider)
    luis.createElement(luis.currentLayer, "Slider", self.constrastSlider)
    luis.createElement(luis.currentLayer, "Slider", self.saturationSlider)
    luis.createElement(luis.currentLayer, "Slider", self.hueShiftSlider)
    luis.createElement(luis.currentLayer, "Button", self.restoreDefaultsButton)

    luis.showGrid = true
end;

function Pause:leave()
    self.musicManager:stopAll()
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
    self.brightnessSlider.value = 1
    self.constrastSlider.value = 1
    self.saturationSlider.value = 1
    self.hueShiftSlider.value = 0
end;

function Pause:keypressed(key)
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