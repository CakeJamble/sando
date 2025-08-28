local ProgressBar = require('class.ui.progress_bar')
local flux = require('libs.flux')
local Signal = require('libs.hump.signal')
local Class = require('libs.hump.class')

---@class LevelUpManager
local LevelUpManager = Class{}

---@param characterTeam CharacterTeam
function LevelUpManager:init(characterTeam)
	self.characterTeam = characterTeam
	self.levelUpUI = self.initUI(characterTeam.members)
	self.duration = 2
  self.windowWidth, self.windowHeight = shove.getViewportDimensions()
  -- self.windowWidth, self.windowHeight = push:toReal(self.windowWidth, self.windowHeight)
  -- self.tx, self.ty = 250, 250
end;

---@param amount integer
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

---@param members Character[]
---@return { [string]: table }
function LevelUpManager.initUI(members)
	local uiTable = {}

	for _,member in ipairs(members) do
		local pbPos = {
			x=member.pos.x + (2 * member.frameWidth),
			y=member.pos.y + (member.frameHeight / 2)
		}
		local pbOptions = {
			xOffset = 0, yOffset = 0,
			min = 0, max = member.experienceRequired,
			w = 100, h = 25,
			wModifier = 0
		}
		local blue = {0, 0, 1}
		local pb = ProgressBar(pbPos, pbOptions, false, blue)
		uiTable[member.entityName] = {character = member, expBar = pb}
	end

	return uiTable
end;

---@param joystick string
---@param button string
function LevelUpManager:gamepadpressed(joystick, button)
end;

---@param dt number
function LevelUpManager:update(dt)
	self.characterTeam:update(dt)
end;

function LevelUpManager:draw()
  love.graphics.push()

  love.graphics.setColor(0, 0, 0, 0.6) -- dark transparent background
  love.graphics.rectangle("fill", 0, 0, self.windowWidth, self.windowHeight)
  love.graphics.setColor(1, 1, 1)

	-- love.graphics.translate(self.tx, self.ty)
	for _,member in pairs(self.levelUpUI) do
		member.character:draw()
		member.expBar:draw()
		local exp = math.floor(0.5 + member.expBar.meterOptions.width)
		local pos = member.expBar.pos
		love.graphics.print(exp, pos.x, pos.y + 25)
	end

  love.graphics.pop()
end;

return LevelUpManager