local uuidv7 = require('analytics.uuidv7')
local json = require('libs.json')

-- Creates a Unique ID & packages it together with hardware info and name
---@return table
return function()
	local result = {}
	result.sessionID = uuidv7()
	result.deviceID = json.null

	result.renderer = {}
	result.renderer.name, result.renderer.version,
		result.renderer.vendor, result.renderer.device = love.graphics.getRendererInfo()

	result.osName = love.system.getOS()
	
	return result
end;