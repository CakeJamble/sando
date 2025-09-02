local ProgressBar = require('class.ui.progress_bar')
local flux = require('libs.flux')
local Signal = require('libs.hump.signal')
local Text = require('libs.sysl-text.slog-text')
local Frame = require('libs.sysl-text.slog-frame')
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
  self.isDisplayingNotification = false
  self.textBox = Text.new("left",
  {
	    color = {0.9,0.9,0.9,0.95},
	    shadow_color = {0.5,0.5,1,0.4},
	    character_sound = true,
	    sound_every = 2,
	    -- sound_number = 1
    })
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
				pb:reset()
				print(member.entityName .. ' leveled up')
				Signal.emit('OnLevel', member, previousLevel)
				self:displayNotification(member, function()
					return member.entityName .. ' leveled up! [shake][color=#0000FF](' .. previousLevel
						.. ' -> ' .. member.level .. ')[/color][/shake]'
				end)
				coroutine.yield('levelup')
				previousLevel = member.level

				-- check for new skills
				local newSkills = member:updateSkills()
				if #newSkills > 0 then
					Signal.emit("OnLearnSkill", member, newSkills)
					self:displayNotification(member, function()
						local result = ''
						for _,skillName in ipairs(newSkills) do
							result = result .. member.entityName .. ' learned [color=#90EE90]' .. skillName .."[/color]\n"
						end
						return result
					end)
					coroutine.yield('learnskill')

					-- -- add back in if needed
					-- if member:skillSlotFull() then
					-- 	Signal.emit('OnOverwriteSkill', member, newSkill)
					-- 	coroutine.yield('overwrite')
					-- end
				end

				-- roll stat bonus
				-- local statBonus = member:rollStatBonus()
				-- Signal.emit('OnStatBonus', member, statBonus)
				self:displayNotification(member, function()
					local stats = {'hp', 'fp', 'attack', 'defense', 'speed', 'luck'}
					local i = love.math.random(1, #stats)
					local j = love.math.random(1, 4)
					local stat = stats[i]
					local prevStat = member.baseStats[stat]
					member.baseStats[stat] = member.baseStats[stat] + j
					return member.entityName .. "'s " .. stat .. ': [bounce][color=#0000FF]' .. prevStat
						.. ' -> ' .. member.baseStats[stat] .. '[/color][/bounce]'
				end)
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

---@param character Character
---@param callback fun(): string
function LevelUpManager:displayNotification(character, callback)
	self.isDisplayingNotification = true
	-- self.notification = callback()
	local text = callback()
	self.textBox:send(text, 255)
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
	if button == 'a' then
		if self.isDisplayingNotification then
			self.isDisplayingNotification = false
			self:resumeCurrent()
		end
	end
end;

---@param dt number
function LevelUpManager:update(dt)
	self.characterTeam:update(dt)
	if self.isDisplayingNotification then
		self.textBox:update(dt)
	end
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

	if self.isDisplayingNotification then
		-- love.graphics.print(self.notification, 100, 100)
		Frame.draw("eb", 100, 102, 275, 58)
		self.textBox:draw(105, 105)
	end

  love.graphics.pop()
end;

return LevelUpManager