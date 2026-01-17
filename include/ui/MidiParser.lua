---@meta

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

---@class MidiParser
MidiParser = {}

-- Default constructor - does nothing
function MidiParser:init() end

---@param path string
---@return {ppq: integer, events: MidiEvent[]}
function MidiParser:parse(path) end