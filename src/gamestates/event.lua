local json = require('libs.json')
local loadItem = require('util.item_loader')
local event = {}

function event:init()
	shove.createLayer("background", {zIndex = 1})
	shove.createLayer("ui", {zIndex = 10})
	self.dataDir = 'data/event/'
	local poolPath = self.dataDir .. 'event_pool.json'
	local raw = love.filesystem.read(poolPath)
	self.eventPool = json.decode(raw)

	self.textbox = Text.new("left",
	{
    color = {0.9,0.9,0.9,0.95},
    shadow_color = {0.5,0.5,1,0.4},
    character_sound = true,
    sound_every = 2,
	})
end;

---@param previous table
---@param options table
function event:enter(previous, options)
	self.log = options.log
	self.characterTeam = options.team
	self.ev = self:loadEvent(self.log.act, self.log.floor)
	self:start()
end;

---@param act integer
---@param floor integer
---@return table
function event:loadEvent(act, floor)
	local i = love.math.random(1, #self.eventPool)
	local eventPath = self.dataDir .. self.eventPool[i] .. '.json'
	local raw = love.filesystem.read(eventPath)
	local data = json.decode(raw)

	return data
end;

function event:start()
	self.textbox:send(self.ev.description)
end;

---@param itemOptions table
---@return table
function event.loadRewards(itemOptions)
	-- do
	return {-1}
end;

---@param dt number
function event:update(dt)
	self.textbox:update(dt)
end;

function event:draw()
	shove.beginDraw()

	shove.beginLayer('ui')
	self.textbox.draw()
	shove.endLayer()

	shove.endDraw()
end;

return event