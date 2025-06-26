--! filename: tool

Class = require 'libs.hump.class'
Tool = Class{}

function Tool:init(toolDict)
	self.name = toolDict.toolName
	self.description = toolDict.description
	self.flavorText = toolDict.flavorText
	self.rarity = toolDict.rarity
end;