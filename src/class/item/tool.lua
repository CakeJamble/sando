--! filename: tool

Class = require 'libs.hump.class'
Tool = Class{}

function Tool:init(toolDict)
	self.name = toolDict.toolName
	self.description = toolDict.description
	self.flavorText = toolDict.flavorText
	self.rarity = toolDict.rarity
	self.procCondition = toolDict.proc
end;

function Tool:update(dt)
	--do
end;

function Tool:draw()
	--do
end;