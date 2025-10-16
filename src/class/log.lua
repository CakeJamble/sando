local Class = require('libs.hump.class')

---@class Log
local Log = Class{}


function Log:init()
	self.act = 1
	self.floor = 1
	self.encounters = {
		{},
		{},
		{}
	} -- temp: assume always 3 acts
	self.map = nil
end;

---@param index integer The index choses in the map's activeRooms table
---@param rooms Room[]
function Log:logEncounterSelection(index, rooms)
	local encounter = {
		index = index,
		rooms = rooms
	}
	table.insert(self.encounters[self.act], encounter)
end;

function Log:setCleared()
	local encounter = self.encounters[self.act][self.floor]
	encounter.rooms[encounter.index].cleared = true

	-- Update map state
	if self.floor == self.map.numFloors then
		self.act = self.act + 1
		self.floor = 1
		self.map = nil -- overworld will generate new map for next act
	else
		self.floor = self.floor + 1
	end
end;

---@param act integer
---@param floor integer
---@param encounters table
function Log:loadFromSaveData(act, floor, encounters)
	self.act = act
	self.floor = floor
	self.encounters = encounters
end;

return Log