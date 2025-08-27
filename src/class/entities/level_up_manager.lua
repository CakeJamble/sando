local ProgressBar = require('class.ui.progress_bar')
local flux = require('libs.flux')
local Signal = require('libs.hump.signal')
local Class = require('libs.hump.class')

local LevelUpManager = Class{}

function LevelUpManager:init(characterTeam)
	self.characterTeam = characterTeam
	self.levelUpUI = self.initUI(characterTeam.members)
	self.duration = 2
  self.windowWidth, self.windowHeight = push:getDimensions()
  self.windowWidth, self.windowHeight = push:toReal(self.windowWidth, self.windowHeight)
  self.windowWidth, self.windowHeight = self.windowWidth * 0.75, self.windowHeight * 0.75
  -- self.windowWidth, self.windowHeight = 640, 360
  self.wOffset, self.hOffset = self.windowWidth * 0.1, self.windowHeight * 0.1
  -- print('wOffset: ' .. self.wOffset, 'hOffset: ' .. self.hOffset)
end;

function LevelUpManager:distributeExperience(amount)
	for i,member in ipairs(self.characterTeam.members) do
		local previousLevel = member.level
		local totalExp = amount
		local exp = member.experience
		local expReq = member.experienceRequired
		local expToGain = math.min(exp + amount, expReq)
		local pb = self.levelUpUI[member.entityName].expBar
		local expResult = pb:increaseMeter(expToGain)
		local expTween = flux.to(pb.meterOptions, self.duration, {width = expResult})
			:oncomplete(function() member:gainExp(expResult); end)
		totalExp = totalExp - expToGain

		local hasLvlUp = false
		while totalExp > 0 do
			hasLvlUp = true
			pb:reset()
			expToGain = math.min(totalExp, expReq)
			expTween = expTween:after(self.duration, {width = pb:increaseMeter(expToGain)})
				:oncomplete(function() member:gainExp(expToGain); end)
		end

		if hasLvlUp then
			Signal.emit('OnLevel', member, previousLevel)
		end
	end
end;

function LevelUpManager.initUI(members)
	local uiTable = {}

	for _,member in ipairs(members) do
		local pbPos = {x=0,y=0}
		local pbOptions = {
			xOffset = 0, yOffset = 0,
			min = 0, max = member.experienceRequired,
			w = 250, h = 100,
			wModifier = 0
		}

		local pb = ProgressBar(pbPos, pbOptions)
		uiTable[member.entityName] = {character = member, expBar = pb}
	end

	return uiTable
end;

function LevelUpManager:update(dt)
	self.characterTeam:update(dt)
end;

function LevelUpManager:draw()
  love.graphics.push()


	love.graphics.translate(self.wOffset, self.hOffset)
  love.graphics.setColor(0, 0, 0, 0.6) -- dark transparent background
  love.graphics.rectangle("fill", 0, 0, self.windowWidth, self.windowHeight)
  love.graphics.setColor(1, 1, 1)

	for _,member in pairs(self.levelUpUI) do
		member.character:draw()
		member.expBar:draw()
	end


  love.graphics.pop()
end;

return LevelUpManager