local Class = require('libs.hump.class')
local QTE = require('class.qte.QTE')
local Timer = require('libs.hump.timer')

---@class RhythmBase: QTE
local RhythmBase = Class{__includes = QTE}

---@param data table
function RhythmBase:init(data)
	QTE.init(self, data)
	self.data = data
	self.options = data.options
	self.onComplete = nil
	self.penalty = 1
	self.isPenalized = false
	self.rhythmActive = false
	self.sequence = data.sequence
	self.results = self.initResultTable(#self.sequence)
	self.index = 1
end;

function RhythmBase.initResultTable(length)
	local result = {}
	for i=1, length do
		table.insert(result, false)
	end
	return result
end;

function RhythmBase:reset()
	QTE.reset(self)
	self.sequence = {}
	self.results = {}
	self.signalEmitted = false
end;

function RhythmBase:penalize()
	self.isPenalized = true
	Timer.after(self.penalty, function() self.isPenalized = false end)
end;

function RhythmBase:isOnBeat(button)
	if self.isPenalized then
		return false
	else
		local expected = self.sequence[self.index]
		local isMatching = expected == button
		local isOnBeat = self:getBeat()
	end
	
end;

function RhythmBase:getBeat()

end;

function RhythmBase:gamepadpressed(joystick, button)
	if self.rhythmActive then
		local expected = self.sequence[self.index]
		self.hitChart:checkHit(expected, button)
		if not self.isPenalized and self.isOnBeat and expected == button then
			self.results[self.index] = true
		else
			self:penalize()
		end
	end
end;