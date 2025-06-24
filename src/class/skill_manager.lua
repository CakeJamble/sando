--! filename: skill_manager
require('class.qte')
require('class.skill')
require('util.skill_sheet')
Class = require 'libs.hump.class'
SkillManager = Class{}

function SkillManager:init()
	self.actors = nil
	self.skill = nil
	self.qte = nil
end;


