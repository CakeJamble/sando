---@meta

---@class Log
---@field characterTeam CharacterTeam
---@field low number
---@field high number
---@field act integer
---@field floor integer
---@field encounters table[]
---@field map Map
Log = {}

-- Builds a record of encounters and tracks the state of the team.
-- Currently assumes that there will always be 3 acts
---@param characterTeam CharacterTeam
function Log:init(characterTeam) end

---@param index integer The index choses in the map's activeRooms table
---@param rooms Room[]
function Log:logEncounterSelection(index, rooms) end

function Log:setCleared() end

---@return string
function Log:serialize() end

---@param act integer
---@param floor integer
---@param encounters table
function Log:loadFromSaveData(act, floor, encounters) end