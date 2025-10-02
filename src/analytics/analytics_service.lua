--------------------------------------------------------------------------------
-- ItsyScape/Analytics/Threads/AnalyticsService.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------

local EventUtils = require('analytics.analytics_event')
local input = love.thread.getChannel("analytics_input")
local output = love.thread.getChannel('analytics_output')

local isRunning = true
while isRunning do
	local event = input:demand()
	if type(event) == 'table' then
		if event.type == 'quit' then
			isRunning = false
		elseif event.type == 'example' then
			local isSuccess = EventUtils.pushAnalyticEvent(event)
			output:push({type = event.type, sent=isSuccess})
		end
	end
end