local Class = require('libs.hump.class')
local lovebpm = require('libs.lovebpm')
local Timer = require('libs.hump.timer')
local Signal = require('libs.hump.signal')

---@class CombatMusicManager: SoundManager
local RhythmManager = Class{}

---@param filename string Path to song
---@param sequence love.GamepadButton[]
---@param bpm? number
function RhythmManager:init(filename, sequence, bpm)
	self.sequence = sequence
	self.results = {}
	for i=1, #self.sequence do
		table.insert(self.results, false)
	end
	self.index = 1
	self.isOnBeat = false
	if not bpm then bpm = lovebpm.detectBPM(filename) end
	self.music = lovebpm.newTrack()
		:load(filename)
		:setBPM(bpm)
		:setLooping(true)

	self.rhythmWindow = 0.1
	self.penalty = 1
	self.isPenalized = false
	self.isRhythmQTEActive = false
end;

function RhythmManager:play()
	self.music:play()
end;

-- Returns the number of correct button presses (matches sequence & on-beat)
---@return integer
function RhythmManager:getResults()
	local result = 0
	for _, wasOnBeat in ipairs(self.results) do
		if wasOnBeat then result = result + 1 end
	end

	return result
end;

-- Sets `self.isOnBeat` to `true`, and sets to `false` after time window ends, & increments `self.index`
function RhythmManager:beginWindow()
	self.isOnBeat = true
	Timer.after(2 * self.rhythmWindow, function()
		self.isOnBeat = false
		if self.index < #self.sequence then self.index = self.index + 1 end
	end)
end;

-- Sets `self.isPenalized` to `true`, and sets back to `false` after time window ends
function RhythmManager:beginPenalty()
	self.isPenalized = true
	Timer.after(self.penalty, function() self.isPenalized = false end)
end;

-- Adds `num` passed to `self.rhythmWindow`
---@param num number Value added to `self.RhythmWindow`
function RhythmManager:modifyRhythmWindow(num)
	self.rhythmWindow = self.rhythmWindow + num
end;

-- Adds `num` passed to `self.penalty`
---@param num number Value added to `self.penalty`
function RhythmManager:modifyPenaltyWindow(num)
	self.penalty = self.penalty + num
end;

---@param joystick love.Joystick
---@param button love.GamepadButton
function RhythmManager:gamepadpressed(joystick, button)
	if self.isRhythmQTEActive then
		local expected = self.sequence[self.index]
		if expected == button and not self.isPenalized and self.isOnBeat then
			self.results[self.index] = true
		else
			self:beginPenalty()
		end
	end
end;

---@param dt number
function RhythmManager:update(dt)
	self.music:update()
	if self.isRhythmQTEActive then
		local _, subbeat = self.music:getBeat()
		self.isOnBeat = subbeat <= self.rhythmWindow or subbeat >= (1 - self.rhythmWindow)
	end
end;