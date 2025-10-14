local T = require('libs.knife.test')
local input = love.thread.getChannel("analytics_input")
local output = love.thread.getChannel('analytics_output')
local Events = require('analytics.Events')
local getPlayerInfo = require('analytics.get_player_info')

T('Given a sample player and event description', function (T)
	local player = getPlayerInfo()
	local example = Events.example
	example.playerInfo = player
	input:push(example)

	local result = output:demand()
	T:assert(result.type == "example", "An example event was created")
	T:assert(result.sent, "And it was pushed to PostHog")
end)