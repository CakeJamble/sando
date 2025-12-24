local Signal = require('libs.hump.signal')
local Timer = require('libs.hump.timer')
local Class = require('libs.hump.class')

-- Manages sound effects and music for gamestates
	-- Other objects are responsible for their own sfx
---@class SoundManager
local SoundManager = Class{}

---@param sounds table
function SoundManager:init(sounds)
	self.sounds = sounds or {}
	self.activeSounds = {}
	self.volume = 1.0
	self.volumeLimits = {min=0,max=1}
	self.lastSoundIndex = 0

	Signal.register("OnPause",
		function()
			for _,src in ipairs(self.activeSounds) do
				src:pause()
			end
		end)

	Signal.register("OnResume",
		function()
			for _,src in ipairs(self.activeSounds) do
				src:play()
			end
		end)
end;

---@param key string
---@return love.Source? Returns a love.audio.Source or nothing if key not found
function SoundManager:play(key)
	-- grab random variant if there are multiple recordings for a single sound
	local variants = self.sounds[key]
	if not variants or #variants == 0 then return end
	local i = love.math.random(#variants)
	local base = variants[i]

	local sound = base:clone()
	sound:setVolumeLimits(self.volumeLimits.min, self.volumeLimits.max)
	sound:setVolume(self.volume)
	self.lastSoundIndex = self.lastSoundIndex + 1

	if sound:getType() == "stream" then sound:setLooping(true) 
	else 
		Timer.after(sound:getDuration(), function()
			table.remove(self.activeSounds, self.lastSoundIndex) 
			self.lastSoundIndex = self.lastSoundIndex - 1
		end)
	end
	sound:play()
	table.insert(self.activeSounds, sound)
	return sound
end;

function SoundManager:stopAll()
	for _,src in ipairs(self.activeSounds) do
		src:stop()
	end
end;

---@param v number
function SoundManager:setGlobalVolume(v)
	self.volume = v
	for _,src in ipairs(self.activeSounds) do
		src:setVolume(self.volume)
	end
end;

---@param min number
---@param max number
function SoundManager:setGlobalVolumeLimits(min, max)
	self.volumeLimits.min = min
	self.volumeLimits.max = max
	for _,src in ipairs(self.activeSounds) do
		src:setVolumeLimits(min, max)
	end
end;

return SoundManager