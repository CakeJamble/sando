---@meta

---@alias options {resolution: {w: integer, h: integer}, windowModeFlags: {resizable: boolean, vsync: boolean, minwidth: integer, minheight: integer}, musicVolume: number, sfxVolume: number}

---@class Settings
---@field DEFAULT_SETTINGS_PATH string
---@field path string
---@field musicManager SoundManager
---@field sfxManager SoundManager
---@field supportedResolutions [integer, integer][]
---@field settings options
Settings = {}

function Settings:init() end

-- Creates default settings if a settings file cannot be found
---@return options
function Settings:createDefaultSettings() end

-- Loads and applies settings from an existing settings file
---@return options
function Settings:loadSettings() end

function Settings:saveSettings() end
function Settings:applyAll() end

---@param key string The setting being set
---@param value any New value being set for the setting
function Settings:setSetting(key, value) end

function Settings:restoreAllDefaults() end