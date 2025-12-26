local json = require('libs.json')
local getClosestResolution = require('util.get_closest_resolution')
local SoundManager = require('class.ui.SoundManager')
local Class = require('libs.hump.class')

---@class Settings
---@field DEFAULT_SETTINGS_PATH string
---@field BASE_RESOLUTION {width: integer, height: integer}
---@field SUPPORTED_RESOLUTIONS integer[][]
local Settings = Class{
	DEFAULT_SETTINGS_PATH = "data/settings/default_settings.json",
}

function Settings:init()
	self.path = "settings.json"
	self.postShader = love.graphics.newShader("asset/shader/postprocess.glsl")
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


---@return {resolution: {w: integer, h: integer}, windowModeFlags: {resizable: boolean, vsync: boolean, minwidth: integer, minheight: integer}, musicVolume: number, sfxVolume: number, display: table} settings
function Settings:createDefaultSettings()
	local raw = love.filesystem.read(Settings.DEFAULT_SETTINGS_PATH)
	local data = json.decode(raw)

	local desktopWidth, desktopHeight = love.window.getDesktopDimensions()
	local w, h = tonumber(desktopWidth), tonumber(desktopHeight)
	local resolution = {}
	resolution.w, resolution.h = getClosestResolution(w, h, self.supportedResolutions)

	local gamepadType = "kbm"
	if input.joystick then gamepadType = input.joystick:getGamepadType() end
	local settings = {
		resolution = resolution,
		windowModeFlags = data.flags,
		musicVolume = data.musicVolume,
		sfxVolume = data.sfxVolume,
		display = data.display
	}

	return settings
end;

---@return {resolution: {w: integer, h: integer}, windowModeFlags: {resizable: boolean, vsync: boolean, minwidth: integer, minheight: integer}, musicVolume: number, sfxVolume: number, display: table} settings
function Settings:loadSettings()
	local raw = love.filesystem.read(self.path)
	local data = json.decode(raw)

	return data
end;

function Settings:saveSettings()
	local data = json.encode(self.settings)
	love.filesystem.write(self.path, data)
end;

function Settings:applyAll()
	local resolution = self.settings.resolution
	shove.setWindowMode(resolution.w, resolution.h, self.settings.windowModeFlags)
	self.musicManager:setGlobalVolume(self.settings.musicVolume)
	self.sfxManager:setGlobalVolume(self.settings.sfxVolume)
end;

---@param key string The setting being set
---@param value any New value being set for the setting
function Settings:setSetting(key, value)
	self.settings[key] = value
end;

function Settings:restoreAllDefaults()
	self.settings = self:createDefaultSettings()
	self:applyAll()
	self:saveSettings()
end;

function Settings:draw()
	love.graphics.setShader(self.postShader)
	local display = self.settings.display
	for name, value in pairs(display) do
		self.postShader:send(name, value)
	end
end;

return Settings