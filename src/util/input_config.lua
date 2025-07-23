local baton = require 'libs.baton'
--[[
	config: table{
		- controls				: table of controls
		- pairs 					: table of axis pairs
		- joystick 				: LOVE joystic (returned from love.joystick.getJoysticks)
		- deadzone 				: 0 <= deadzone <= 1, represents threshold for registering analog input
		- squareDeadzone	: whether to use square deadzones for axis pairs or not
	}
]]
local directions = {
	left 		= {'key:left', 	'key:a', 'axis:leftx-', 'button:dpleft'},
  right 	= {'key:right', 'key:d', 'axis:leftx+', 'button:dpright'},
  up 			= {'key:up'},		'key:w', 'axis:lefty+', 'button:dpup'},
  down 		= {'key:down'}, 'key:s', 'axis:lefty-', 'button:dpdown'},
}

local actionButtons = {
	ab1 = {'key:u', 'button:a'},
	ab2 = {'key:k', 'button:b'},
	ab3 = {'key:n', 'button:x'},
	ab4 = {'key:h', 'button:y'}
}

local shoulders = {
	lCancel = {'key:c', 'button:leftshoulder'},
	guard = {'key:z', 'button:rightshoulder'}
}

local menus = {
	inventory = {'key:i', 'button:start'},
	settings 	= {'key:escape', 'button:back'}
}

local xboxControls = {
	left 			= directions.left,
	right 		= directions.right,
	up 				= directions.up,
	down 			= directions.down,
	ab1				= actionButtons.ab1,
	ab2				= actionButtons.ab2,
	ab3 			= actionButtons.ab3,
	ab4 			= actionButtons.ab4,
	lCancel		= shoulders.lCancel,
	guard			= shoulders.guard,
	inventory = menus.inventory,
	settings  = menus.settings
}

function CreateXboxConfig()
	local joysticks = love.joystick.getJoysticks()
	local xboxConfig = {
		controls 				= xboxControls,
		joystick 				= joysticks[1],
		deadzone 				= 0.3,
		squareDeadzone 	= false
	}

	return xboxConfig
end;