---@meta

--[[Manages sound playback and volumes. Class objects with SFX can
get a reference to their SFX table(s) from the global `AllSounds` table.]]
---@class SoundManager
---@field sounds table
---@field activeSounds table
---@field volume number [0..1]
---@field volumeLimits {min: number, max: number} Both in range of [0..1]
---@field lastSoundIndex integer
SoundManager = {}

---@param sounds {[string]: love.Source[]}
function SoundManager:init(sounds) end

--[[Plays and returns the sound/music indexed at the given key in the `self.sounds` table.
If nothing is found at the index, it will return nil.
If the `love.Source` array found at the index contains multiple objects,
a random one will be chosen. If the `love.Source` object is of type `"stream"`,
then it is assumed to be a Music track, and will be set to loop.]]
---@param key string
---@return love.Source? # Returns a love.audio.Source or nothing if key not found
function SoundManager:play(key) end

--[[Stops all Music and SFX. `Source.stop()` is distinct from `Source.pause()`
in that it will set the playback to resume at the start of the track.]]
function SoundManager:stopAll() end

---@param v number
function SoundManager:setGlobalVolume(v) end

---@param min number
---@param max number
function SoundManager:setGlobalVolumeLimits(min, max) end