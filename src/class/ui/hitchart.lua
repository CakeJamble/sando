local Class = require('libs.hump.class')

---@class HitChart
local HitChart = Class{}

---@param midiSong MidiEvent[]
---@param offset number
function HitChart:init(midiSong, offset)
	self.offset = offset or 0
	self.hits = {}
	self.index = 1
	self:buildChart(midiSong)
end;

---@param midi MidiEvent[]
function HitChart:buildChart(midi)
	local ppq = midi.ppq
	local events = midi.events

	table.sort(events, function(a, b)
		return a.tick < b.tick
	end)

	local currentTempo = 500000 -- µs per quarter note (120 BPM)
	local lastTick = 0
	local currentTime = 0

	-- Program per channel
	local channelProgram = {}
	for ch = 0, 15 do
		channelProgram[ch] = 0
	end

	for _,e in ipairs(events) do
		local deltaTicks = e.tick - lastTick
		currentTime = currentTime + (deltaTicks / ppq) * (currentTempo / 1e6)

		if e.type == "tempo" then
			currentTempo = e.tempo
		elseif e.type == "note_on" then
			local instrument

			if e.channel == 9 then
				instrument = e.note -- percussion
			else
				instrument = channelProgram[e.channel]
			end

			self.hits[#self.hits+1] = {
				time = currentTime + self.offset,
				channel = e.channel,
				note = e.note,
				instrument = instrument
			}
		end
		lastTick = e.tick
	end
end;


---Reset playback position (e.g. song restart)
function HitChart:reset()
    self.index = 1
end;

---Get the next hit (without advancing)
---@return table|nil
function HitChart:peek()
    return self.hits[self.index]
end;

---Advance to next hit
function HitChart:advance()
    self.index = self.index + 1
end;

---Skip hits that are already missed
---@param songTime number
---@param missWindow number
function HitChart:skipMissed(songTime, missWindow)
    while true do
        local hit = self.hits[self.index]
        if not hit then return end

        if songTime > hit.time + missWindow then
            self.index = self.index + 1
        else
            return
        end
    end
end;

---Check if input is within hit window
---@param songTime number
---@param hitWindow number
---@return boolean, table|nil
function HitChart:checkHit(songTime, hitWindow)
    local hit = self.hits[self.index]
    if not hit then
        return false, nil
    end

    local diff = songTime - hit.time
    if math.abs(diff) <= hitWindow then
        self.index = self.index + 1
        return true, hit
    end

    return false, nil
end;

-- Returns a sequence of inputs & timings from the hit chart within a given time window
---@param songTime number
---@param window number
---@return table
function HitChart:getChartSlice(songTime, window)
	local slice = {}

	local startTime = songTime
	local endTime = songTime + window

	local i = self.index

	while i <= #self.hits and self.hits[i].time < startTime do
		i = i + 1
	end

	while i <= #self.hits do
		local hit = self.hits[i]
		if hit.time > endTime then
			break
		end
		slice[#slice + 1] = hit
		i = i + 1
	end

	return slice
end;

return HitChart