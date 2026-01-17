local json = require('libs.json')
local getClosestResolution = require('util.get_closest_resolution')
local SoundManager = require('class.ui.SoundManager')
local Class = require('libs.hump.class')

---@type Settings
local Settings = Class{
	DEFAULT_SETTINGS_PATH = "data/settings/default_settings.json",
}

function Settings:init()
	self.path = "settings.json"
	self.musicManager = SoundManager(AllSounds.music)
	self.sfxManager = SoundManager(AllSounds.sfx)
	self.supportedResolutions = {
    {640, 360},
    {1280, 720},
    {1920, 1080},
    {2560, 1440},
    {3840, 2160}
	}
	local info = love.filesystem.getInfo(self.path)
	if info then
		self.settings = self:loadSettings()
	else
		self.settings = self:createDefaultSettings()
		self:saveSettings()
	end
	self:applyAll()
end;


function Settings:createDefaultSettings()
	local raw = love.filesystem.read(Settings.DEFAULT_SETTINGS_PATH)
	local data = json.decode(raw)

	local desktopWidth, desktopHeight = love.window.getDesktopDimensions()
	local w, h = tonumber(desktopWidth), tonumber(desktopHeight)
	local resolution = {}
	resolution.w, resolution.h = getClosestResolution(w, h, self.supportedResolutions)

	local settings = {
		resolution = resolution,
		windowModeFlags = data.flags,
		musicVolume = data.musicVolume,
		sfxVolume = data.sfxVolume,
	}

	return settings
end;

function Settings:loadSettings()
	local raw = love.filesystem.read(self.path)
	local data = json.decode(raw)

	return data
end;

function Settings:saveSettings()
	local data = json.encode(self.settings)
	love.filesystem.write(self.path, data)
	print('settings saved to save dir: ', data)
end;

function Settings:applyAll()
	local resolution = self.settings.resolution
	shove.setWindowMode(resolution.w, resolution.h, self.settings.windowModeFlags)
	self.musicManager:setGlobalVolume(self.settings.musicVolume)
	self.sfxManager:setGlobalVolume(self.settings.sfxVolume)
end;

function Settings:setSetting(key, value)
	self.settings[key] = value
end;

function Settings:restoreAllDefaults()
	self.settings = self:createDefaultSettings()
	self:applyAll()
	self:saveSettings()
end;

return Settings