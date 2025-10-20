local event = {}

function event:init()
	shove.createLayer("background", {zIndex = 1})
	shove.createLayer("ui", {zIndex = 10})
end;

---@param previous table
---@param options table
function event:enter(previous, options)
	self.log = options.log
	self.characterTeam = options.team
end;

return event