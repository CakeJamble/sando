local SoundManager = require('class.ui.sound_manager')
local pause = {}
local initLuis = require("libs.luis.init")
local luis = initLuis("libs/luis/widgets")
local flux = require('libs.flux')

function pause:init()

    shove.createLayer("ui", {zIndex = 10})
    self.musicManager = SoundManager(AllSounds.music)
    self.sfxManager = SoundManager(AllSounds.sfx)
    self.supportedResolutions = {
        {640, 360},
        {1280, 720},
        {1920, 1080},
        {2560, 1440},
        {3840, 2160}
    }
    self.resIndex = 4
    -- luis.baseWidth = 2560
    -- luis.baseHeight = 1440
end;

function pause:enter(previous)
    self.container = luis.newFlexContainer(18, 20, 2, 2)
    self.windowWidth, self.windowHeight = shove.getViewportDimensions()

    self.luisTime = 0
    self.musicManager:play('ny_house_party')

    self.musicVolSlider = luis.newSlider(0, 1, 1, 10, 2,
        function(value)
            self.musicManager:setGlobalVolume(value)
        end, 1, 1)
    self.sfxSlider = luis.newSlider(0, 1, 1, 10, 2,
        function(value)
        self.sfxManager:setGlobalVolume(value)

    end, 3, 1)
    self.sfxButton = luis.newButton("Test", 4, 2, nil,
        function()
            self.sfxManager:play("uke")
        end, 15, 14)
    self.container:addChild(self.musicVolSlider)
    self.container:addChild(self.sfxSlider)
    self.container:addChild(self.sfxButton)
    luis.newLayer("main")
    luis.setCurrentLayer("main")
    luis.createElement(luis.currentLayer, "FlexContainer", self.container)
    luis.showGrid = true
end;

function pause:leave()
    self.musicManager:stopAll()
end;

function pause:keypressed(key)
    if key == 'p' then
        return Gamestate.pop()
    end
end;

---@param dt number
function pause:update(dt)
  self.luisTime = self.luisTime + dt
  if self.luisTime >= 1/60 then
    flux.update(self.luisTime)
    self.luisTime = 0
  end
  -- luis.updateScale()
  luis.update(dt)
end;

function pause:mousepressed(x, y, button, istouch)
    luis.mousepressed(x, y, button, istouch)
end;

function pause:mousereleased(x, y, button, istouch)
    luis.mousereleased(x, y, button, istouch)
end;

function pause:draw()
    luis.draw()
end;

return pause