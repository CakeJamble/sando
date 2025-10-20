local Entity = require('class.entities.entity')
local PlayerInputCommand = require('class.input.player_input_command')
local AICommand = require('class.input.ai_command')
-- local STBScheduler = require('class.scheduler.stb_scheduler')
local Scheduler = require('class.scheduler.scheduler')
local Class = require('libs.hump.class')
local Signal = require('libs.hump.signal')
local Timer = require('libs.hump.timer')

-- CTB is similar to STB except that enemies act once every n character actions
---@class CTBScheduler: Scheduler
local CTBScheduler = Class{__includes = Scheduler}

---@param characterTeam CharacterTeam
---@param enemyTeam EnemyTeam
function CTBScheduler:init(characterTeam, enemyTeam)
	Scheduler.init(self, characterTeam, enemyTeam)
	self.combatants = self.characterTeam.members -- lazy override scheduler init
	self:sortQueue(self.combatants)
	self.enemyTimers = {}
	self.turnIndex = 1
	self.activeEntity = nil
	self.activeCommand = nil
	self.characterCommandQueue = {}
	self.enemyCommandQueue = {}
	self.isEnemyTurn = false
end;

function CTBScheduler:enter()
	Scheduler.enter(self)
	Entity.isATB = false
	local turnStart = function()
		local duration = self:removeKOs()

		Timer.after(duration,
			function()
			if self:winLossConsMet() then return end
			while not self.combatants[self.turnIndex]:isAlive() do
				self.turnIndex = (self.turnIndex % #self.combatants) + 1
			end

			self.activeEntity = self.combatants[self.turnIndex]
			local command
			if self.activeEntity.type == 'character' then
				command = PlayerInputCommand(self.activeEntity, self)
			else
				command = AICommand(self.activeEntity, self)
			end
			self.activeCommand = command
			self.turnIndex = (self.turnIndex % #self.combatants) + 1
			self.activeCommand:start()
		end)
	end

	print('registering signals')
	self:registerSignal("NextTurn", turnStart)

	self:registerSignal("OnStartCombat",
		function()
			for _,enemy in ipairs(self.enemyTeam.members) do
				local contextTimer = self.initCTimer(enemy)
				table.insert(self.enemyTimers, contextTimer)
			end
			Timer.after(1, turnStart)
		end)

	self:registerSignal("OnEndTurn",
		function(timeBtwnTurns)
			self:resetCamera(timeBtwnTurns)
			Timer.after(timeBtwnTurns, function()
				self:tick()
				self.activeCommand.done = true
				turnStart()
			end)

		end)
end;

---@param t Character[]
---@return table
function CTBScheduler:sortQueue(t)
  table.sort(t,
    function(entity1, entity2)
      return entity1:getSpeed() > entity2:getSpeed()
    end
  );
  return t
end;

function CTBScheduler:sortWaitingCombatants()
  local waitingCombatants = {unpack(self.combatants, self.turnIndex, #self.combatants)}
  local i=1
  for j=self.turnIndex, #self.combatants do
    self.combatants[j] = waitingCombatants[i]
    i = i+1
  end
end;

-- for now, all enemies go every 3 turns
---@param enemy Enemy
---@return table
function CTBScheduler.initCTimer(enemy)
	-- in future, use speed to determine rate of attacks
	local speed = enemy.battleStats.speed
	local cTimer = {
		enemy = enemy,
		tick = 0,
		gauge = 3
	}
	return cTimer
end;

function CTBScheduler:tick()
	for _,timer in ipairs(self.enemyTimers) do
		timer.tick = timer.tick + 1

		if timer.tick % timer.gauge == 0 then
			local command = AICommand(timer.enemy, self)
			table.insert(self.enemyCommandQueue, command)
		end
	end
end;

---@param command Command
function CTBScheduler:enqueueCommand(command)
	  print('enqueuing command from ' .. command.entity.entityName .. ' in command queue')
	if command.entity.type == "enemy" then
		table.insert(self.enemyCommandQueue, command)
	else
		table.insert(self.characterCommandQueue, command)
	end
	self:checkQueues()
end;

function CTBScheduler:checkQueues()
	self:removeKOs()

	if not self.activeCommand then
		if #self.enemyCommandQueue > 0 then
			self.activeCommand = table.remove(self.enemyCommandQueue, 1)
		elseif #self.characterCommandQueue > 0 then
			self.activeCommand = table.remove(self.characterCommandQueue, 1)
		end

		if self.activeCommand then
			self.activeCommand:start()
		end
	elseif self.activeCommand.done then
		self.activeCommand = nil
		self:checkQueues()
	elseif #self.enemyCommandQueue > 0 and not self.isEnemyTurn then
		local command = table.remove(self.characterCommandQueue, 1)
		self.activeCommand:interrupt()
		table.insert(self.characterCommandQueue, 1, self.activeCommand)
		self.activeCommand = command
		self.activeCommand:start()
	end
end;

-- Roundabout way of removing enemy KOs without putting them in the combatants list
function CTBScheduler:removeKOs()
	local dur1 = Scheduler.removeKOs(self, self.activeEntity)
	local dur2 = 1

	local koEnemies = {}
	for _,enemy in ipairs(self.enemyTeam.members) do
		if not enemy:isAlive() then
			table.insert(koEnemies, enemy)
		end
		enemy:resetDmgDisplay()
	end

	Timer.after(dur2,
		function()
			self.enemyTeam:removeMembers(koEnemies)
			self:emitDeathSignals(self.activeEntity, {}, koEnemies)

			for _,enemy in ipairs(koEnemies) do
				table.insert(self.rewards, enemy:getRewards())
			end
		end)

	return math.max(dur1, dur2)
end;

-- Update enemies without needing them in the combatants list
---@param dt number
function CTBScheduler:update(dt)
	Scheduler.update(self, dt)
	for _,enemy in ipairs(self.enemyTeam.members) do
		enemy:update(dt)
	end
end;

-- Draws the timers
function CTBScheduler:draw()
	for _,timer in ipairs(self.enemyTimers) do
		local countdown = tostring(timer.gauge - (timer.tick % timer.gauge))
		local pos = timer.enemy.pos
		love.graphics.print(countdown, pos.x, pos.y + 30)
	end
end;

return CTBScheduler