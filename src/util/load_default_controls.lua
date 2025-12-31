local baton = require('libs.baton')
local json = require('libs.json')
local defaultControlsPath = "data/input/default_controls.json"

return function(joystick)
	local raw = love.filesystem.read(defaultControlsPath)
	print(raw)
	local config = json.decode(raw)
	config.joystick = joystick

	local player = baton.new(config)

	return player
end;