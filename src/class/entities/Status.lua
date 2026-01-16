local Class = require('libs.hump.class')

---@type Status
local Status = Class{}

function Status:init(name, params)
	self.name = name
	self.apply = params.apply
	self.tick = params.tick
end;

return Status