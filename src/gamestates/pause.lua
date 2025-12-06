local SoundManager = require('class.ui.sound_manager')
local suit = require('libs.suit')
local initLuis = require("libs.luis.init")
local luis = initLuis("libs/luis/widgets")
local pause = {}

function pause:init()
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
end;

function pause:enter(previous)
    self.sliders = {
        musicSlider = {value = 100, min = 0, max = 100},
        sfxSlider = {value = 100, min = 0, max = 100}
    }
    self.windowWidth, self.windowHeight = shove.getViewportDimensions()
    self.musicManager:play('ny_house_party')
end;

function pause:leave()
    self.musicManager:stopAll()
end;

function pause:keypressed(key)
    if key == 'p' then
        return Gamestate.pop()
    end
    suit.keypressed(key)
end;

---@param dt number
function pause:update(dt)
    -- Volume Settings
    rows = suit.layout:rows{pos = {50, 50}, min_height = 150,
        {200, 30},
        {200, 50},
        {200, 30},
        {200, 50},
        {200, 50},
        {200, 50},
        {200, 50},
        {200, 50},
        {200, 50}
    }
    values = suit.layout:rows{pos = {250, 80}, min_height = 150,
        {200, 50},
        {200, 30},
        {200, 50}
    }

    suit.Label("Music", {align = 'left'}, rows.cell(1))
    if suit.Slider(self.sliders.musicSlider, {align = 'left'}, rows.cell(2)).changed then
        local newVol = self.sliders.musicSlider.value / 100
        self.musicManager:setGlobalVolume(newVol)
    end
    suit.Label(math.floor(0.5 + self.sliders.musicSlider.value), values.cell(1))
    
    suit.Label("Sound Effects", {align = 'left'}, rows.cell(3))

    suit.Label('', {align = 'left'}, values.cell(2))
    -- Only want to play once when the slider is released so it doesn't jam the listener
    local sfxReturnStates = suit.Slider(self.sliders.sfxSlider, {align = 'left'}, rows.cell(4))
    if sfxReturnStates.changed then
        local newVol = self.sliders.sfxSlider.value / 100
        self.sfxManager:setGlobalVolume(newVol)
    end

    if sfxReturnStates.hit then
        self.sfxManager:play('uke')
    end
    suit.Label(math.floor(0.5 + self.sliders.sfxSlider.value), values.cell(3))

    -- Display Settings
    suit.Label("Resolution", {align = 'left'}, rows.cell(5))

    if suit.Button("Smaller", rows.cell(6)).hit then
        self.resIndex = math.max(1, self.resIndex - 1)
        local newResolution = self.supportedResolutions[self.resIndex]
        local width, height = newResolution[1], newResolution[2]
        shove.setWindowMode(width, height)
    end
    local res = self.supportedResolutions[self.resIndex]
    local resString = tostring(res[1] .. 'x' .. res[2])
    suit.Label(resString, rows.cell(7))

    if suit.Button("Larger", rows.cell(8)).hit then
        self.resIndex = math.min(#self.supportedResolutions, self.resIndex + 1)
        local newResolution = self.supportedResolutions[self.resIndex]
        local width, height = newResolution[1], newResolution[2]
        shove.setWindowMode(width, height)
    end

    if suit.Button("Main Menu", rows.cell(9)).hit then
        Gamestate.switch(states['main_menu'])
    end
end;

function pause:draw()
    suit.draw()
end;

return pause