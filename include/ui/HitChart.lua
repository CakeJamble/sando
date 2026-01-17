---@meta

---@class HitChart
---@field offset integer Audio delay in milliseconds
---@field hits table
---@field index integer
HitChart = {}

---@param midiSong MidiEvent[]
---@param offset number Amount of milliseconds to delay
function HitChart:init(midiSong, offset) end

---@param midi MidiEvent[]
function HitChart:buildChart(midi) end

---Reset playback position (e.g. song restart)
function HitChart:reset() end

---Get the next hit (without advancing)
---@return table|nil
function HitChart:peek() end

---Advance to next hit
function HitChart:advance() end

---Skip hits that are already missed
---@param songTime number
---@param missWindow number
function HitChart:skipMissed(songTime, missWindow) end

---Check if input is within hit window
---@param songTime number
---@param hitWindow number
---@return boolean, table|nil
function HitChart:checkHit(songTime, hitWindow) end

-- Returns a sequence of inputs & timings from the hit chart within a given time window
---@param songTime number
---@param window number
---@return table
function HitChart:getChartSlice(songTime, window) end