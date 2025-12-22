local Class = require('libs.hump.class')

---@class MidiNoteOnEvent
---@field tick integer
---@field note integer
---@field type '"note_on"'

---@class MidiTempoEvent
---@field tick integer
---@field tempo integer
---@field type '"tempo"'

---@alias MidiEvent MidiNoteOnEvent | MidiTempoEvent

---@class MidiSong
---@field ppq integer
---@field events MidiEvent[]

---@class Midi
local MidiParser = Class{}

---@param data string
---@param i integer
---@return integer value
---@return integer nextIndex
local function read_u16(data, i)
    return data:byte(i) * 256 + data:byte(i + 1), i + 2
end

---@param data string
---@param i integer
---@return integer value
---@return integer nextIndex
local function read_u32(data, i)
    return data:byte(i) * 16777216
         + data:byte(i + 1) * 65536
         + data:byte(i + 2) * 256
         + data:byte(i + 3), i + 4
end

---@param data string
---@param i integer
---@return integer value
---@return integer nextIndex
local function read_vlq(data, i)
    local value = 0
    while true do
        local b = data:byte(i)
        value = bit.lshift(value, 7) + bit.band(b, 0x7F)
        i = i + 1
        if b < 0x80 then break end
    end
    return value, i
end

function MidiParser:init()
end;

---@param path string
---@return {ppq: integer, events: MidiEvent[]}
function MidiParser:parse(path)
	local data = love.filesystem.read(path)
	assert(data:sub(1, 4) == "MThd", "Not a MIDI file")
	local i = 5
	local headerLen, format, track, ppq

	headerLen, i = read_u32(data, i)
	format, i = read_u16(data, i)
	tracks, i = read_u16(data, i)
	ppq, i = read_u16(data, i)

	-- skip rest of header
	i = 9 + headerLen

	---@type MidiEvent[]
	local events = {}

	for _=1, tracks do
		assert(data:sub(i, i + 3) == "MTrk", "Missing track header")
		i = i + 4

		local trackLen
		trackLen, i = read_u32(data, i)
		local trackEnd = i + trackLen

		local tick = 0
		local runningStatus

		while i < trackEnd do
			local delta
			delta, i = read_vlq(data, i)
			tick = tick + delta

			local status = data:byte(i)
			if status < 0x80 then
				assert(runningStatus, "Running status without previous status")
				status = runningStatus
			else
				i = i + 1
				runningStatus = status
			end
			local eventType = bit.band(status, 0xF0)
			if eventType == 0x90 then
				-- note is on
				local note = data:byte(i)
				local vel = data:byte(i + 1)
				i = i + 2

				if vel > 0 then
					events[#events + 1] = {
						tick = tick,
						note = note,
						type = "note_on"
					}
				end
			elseif eventType == 0x80 then
				-- note is off
				i = i + 2
			elseif status == 0xFF then
				-- meta event
				local metaType = data:byte(i)
				i = i + 1
				local len
				len, i = read_vlq(data, i)

				if metaType == 0x51 then
					-- set tempo
					local tempo =
							data:byte(i) * 65536
						+ data:byte(i + 1) * 256
						+ data:byte(i + 2)

					events[#events + 1] = {
						tick = tick,
						tempo = tempo,
						type = "tempo"
					}
				end
				i = i + len
			else
				-- any other MIDI events
				if eventType == 0xC0 or eventType == 0xD0 then
					i = i + 1
				else
					i = i + 2
				end
			end
		end
	end
	return {ppq = ppq, events = events}
end;

return MidiParser