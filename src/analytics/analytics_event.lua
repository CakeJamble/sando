--------------------------------------------------------------------------------
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
-- File was made by lifting source code provided by @erinmaus

local POSTHOG_API_KEY = require("analytics.posthog_api_key")
local getTimeStamp = require("analytics.timestamp")
local json = require('libs.json')
local https = require("https")

local AnalyticsEvent = {}
AnalyticsEvent.eventID = 1

---@param data table
local function setProperties(data)
	local properties = data.properties
	local renderer = data.playerInfo.renderer

	properties["$set"] = {
		["GPU Brand"] = renderer.vendor,
		["Processor and GPU"] = renderer.device,
		["OS Name"] = data.playerInfo.osName,
		["Latest App Version"] = SANDO_VERSION,
		["Latest Player Name"] = properties["playerName"],
		["Choices"] = properties["choices"],
		["Selected"] = properties["selected"]
	}

	properties["$set_once"] = {
		["Initial App Version"] = SANDO_VERSION
	}

	properties["Event ID"] = AnalyticsEvent.eventID
	properties["$session_id"] = AnalyticsEvent.playerInfo.sessionID
	properties["distinct_id"] = data.playerInfo.sessionID
end;

---@param data table
---@return table
function AnalyticsEvent.makeAnalyticEvent(data)
	AnalyticsEvent.playerInfo = data.playerInfo
	setProperties(data)

	local event = {
		api_key = POSTHOG_API_KEY,
		event = data.event,
		timestamp = getTimeStamp(),
		properties = data.properties
	}

	AnalyticsEvent.eventID = AnalyticsEvent.eventID + 1

	return event
end;

---@param event table
---@return boolean, boolean?
function AnalyticsEvent.sendAnalyticEvent(event)
	local s, data = pcall(json.encode, event)

	if not s then return false, false	end

	local code, result = https.request("https://app.posthog.com/capture/", {
		method = "POST",
		data = data,
		headers = {
			["Content-Type"] = "application/json",
			["Accept"] = "*/*"
		}
	})

	print("Response Code", code)
	print("Response Body", result)

	if code == 200 then
		return true
	else
		return false
	end
end;

---@param data table
function AnalyticsEvent.pushAnalyticEvent(data)
	local event = AnalyticsEvent.makeAnalyticEvent(data)
	return AnalyticsEvent.sendAnalyticEvent(event)
end;

return AnalyticsEvent