--------------------------------------------------------------------------------
-- ItsyScape/Analytics/Threads/AnalyticsService.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
-- File was made by lifting source code provided by @erinmaus

local ffi = require('ffi')
local bit = require('bit')

-- Creates a Unique Session ID 
return function()
	local values = {}
	for i = 1, 16 do
		values[i] = ffi.new("uint64_t", love.math.random(0, 0xFF))
	end

	local utcDate = os.date("!*t")
	local localDate = os.date("%c")
	utcDate.isdst = localDate.isdst

	local timestamp = ffi.new("uint64_t", os.time(utcDate) * 1000)
	local timestampHigh = bit.band(bit.rshift(timestamp, 16), 0xFFFFFFFF)
	local timestampLow = bit.band(timestamp, 0xFFFF)

	values[1] = bit.band(bit.rshift(timestampHigh, 24), 0xFF)
	values[2] = bit.band(bit.rshift(timestampHigh, 16), 0xFF)
	values[3] = bit.band(bit.rshift(timestampHigh, 8), 0xFF)
	values[4] = bit.band(timestampHigh, 0xFF)
	values[5] = bit.band(bit.rshift(timestampLow, 8), 0xFF)
	values[6] = bit.band(timestampLow, 0xFF)

	values[7] = bit.bor(bit.rshift(values[7], 8), 0x70)
	values[9] = bit.bor(bit.rshift(values[9], 8), 0x80)

	local result = {}
	for i = 1, 16 do
		table.insert(result, string.format("%02x", values[i]))
		if i == 4 or i == 6 or i == 8 or i == 10 then
			table.insert(result, "-")
		end
	end

	return table.concat(result)
end;