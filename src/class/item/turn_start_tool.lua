--! filename: TurnStartTool

require('class.item.tool')
Class = require 'libs.hump.class'
TurnStartTool = Class{__includes = Tool}

function TurnStartTool:init()
	Tool.init(self)

	Signal.register('NextTurn',
		-- Proc the effects of the tool when a turn starts
		function()
			--do
		end
	)
end;