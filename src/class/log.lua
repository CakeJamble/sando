local Class = require('libs.hump.class')

---@class Log
local Log = Class{}


function Log:init()
	self.act = 1
	self.floor = 1
	self.encounters = {}
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