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
  self.coroutines = {}
  self.i = 1
end;

---@param amount integer
function LevelUpManager:distributeExperience(amount)
	self.coroutines = {}
	for _,member in ipairs(self.characterTeam.members) do
		local co = self:createExpCoroutine(member, amount)
		table.insert(self.coroutines, co)
	end

	self.i = 1
	self:resumeCurrent()
end;

---@param member Character
---@param amount integer
function LevelUpManager:createExpCoroutine(member, amount)
	return coroutine.create(function()
		local totalExp = amount
		local previousLevel = member.level
		local pb = self.levelUpUI[member.entityName].expBar

		-- gain experience
		while totalExp > 0 do
			local expToGain = math.min(totalExp, member.experienceRequired)
			totalExp = totalExp - expToGain
			local expResult = pb:increaseMeter(expToGain)
			flux.to(pb.meterOptions, self.duration, {width = expResult * pb.mult})
				:oncomplete(function()
					member:gainExp(expToGain)
					print('tween finished')
					self:resumeCurrent()
				end)

			coroutine.yield('await expbar tween')
			print('done waiting', member.entityName, member.level, totalExp)
			-- trigger level up
			if member.level > previousLevel then
				print(member.entityName .. ' leveled up')
				Signal.emit('OnLevel', member, previousLevel)
				coroutine.yield('levelup')
				previousLevel = member.level

				-- check for new skills
				local newSkill = member:checkForNewSkill()
				if newSkill then
					Signal.emit("OnLearnSkill", member, newSkill)
					coroutine.yield('learnskill')

					if member:skillSlotFull() then
						Signal.emit('OnOverwriteSkill', member, newSkill)
						coroutine.yield('overwrite')
					end
				end

				-- roll stat bonus
				local statBonus = member:rollStatBonus()
				Signal.emit('OnStatBonus', member, statBonus)
				coroutine.yield("statbonus")
			end
		end
	end)
end;

function LevelUpManager:resumeCurrent()
	local co = self.coroutines[self.i]
	if not co then
		Signal.emit('OnExpDistributionComplete')
		return
	end

	local code, res = coroutine.resume(co)
	if not code then
		error(res)
	else
		print('starting coroutine ' .. self.i)
	end

	if coroutine.status(co) == 'dead' then
		self.i = self.i + 1
		self:resumeCurrent()
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
		local expStr = math.floor(0.5 + exp / member.expBar.mult)
		love.graphics.print(expStr, pos.x, pos.y + 25)
	end

  love.graphics.pop()
end;

return LevelUpManager