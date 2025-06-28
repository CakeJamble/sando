--! filename: TurnStartTool
require('util.globals')
require('class.item.tool')
Class = require 'libs.hump.class'
TurnStartTool = Class{__includes = Tool}

function TurnStartTool:init()
	Tool.init(self)
end;