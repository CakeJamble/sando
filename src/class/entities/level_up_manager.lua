local ProgressBar = require('class.ui.progress_bar')
local flux = require('libs.flux')
local Signal = require('libs.hump.signal')
local Class = require('libs.hump.class')

local LevelUpManager = Class{}

function LevelUpManager:init(characterTeam)
	self.characterTeam = characterTeam
	self.levelUpUI = self.initUI(characterTeam.members)
	self.duration = 2
end;

function LevelUpManager:distributeExperience(amount)
	for i,member in ipairs(self.characterTeam.members) do
		local previousLevel = member.level
		local totalExp = amount
		local exp = member.experience
		local expReq = member.experienceRequired
		local expToGain = math.min(exp + amount, expReq)
		local pb = self.levelUpUI[i]
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
		table.insert(uiTable, pb)
	end
end;

return LevelUpManager