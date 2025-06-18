--! filename: enemy_offense_state
require('class.offense_state')

Class = require 'libs.hump.class'
EnemyOffenseState = Class{}	-- there should be a base class for this now

function EnemyOffenseState:init(x, y, battleStats)
	self.x = x
	self.y = y
	self.skill = nil
	self.animFrameLength = nil
	self.stats = battleStats
	self.damage = battleStats.attack
	self.target = nil
	self.isComplete = false

	-- Data used for calculating timed input for character's defense
	self.frameCount = 0
	self.frameWindow = 0
end;

function EnemyOffenseState:reset()
  self.isComplete = false
  self.frameCount = 0
  self.target = nil
end;

function EnemyOffenseState:setSkill(skillObj)
	self.skill = skillObj
	self.frameWindow = skillObj.qte_window
	self.animFrameLength = skillObj.duration
	self.damage = self.damage + self.skill.skill.damage
end;

function EnemyOffenseState:dealDamage()
	if self.target then
		print('dealing damage to ' .. self.target.entityName)
		self.target:takeDamage(self.damage)
	end
end;

function EnemyOffenseState:update(dt)
	if self.isComplete then return end
	if not self.skill then return end

	self.frameCount = self.frameCount + 1
	self.skill:update(dt)

	if self.frameCount > self.animFrameLength then
		self:dealDamage()
		self.isComplete = true
		self.isWindowActive = false
	end
end;

function EnemyOffenseState:draw()
	self.skill:draw(self.x, self.y)
end;