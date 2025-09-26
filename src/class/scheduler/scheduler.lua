-- local PlayerInputCommand = require('class.input.player_input_command')
-- local SkillCommand = require('class.input.skill_command')
-- local CancelCommand = require('class.input.cancel_command')
-- local AICommand = require('class.input.ai_command')
local QTEManager = require('class.qte.qte_manager')
require('util.globals')
local Timer = require('libs.hump.timer')
local Class = require('libs.hump.class')
local Signal = require('libs.hump.signal')
local flux = require('libs.flux')

---@class Scheduler
local Scheduler = Class{}

---@param characterTeam CharacterTeam
---@param enemyTeam EnemyTeam
function Scheduler:init(characterTeam, enemyTeam)
	self.characterTeam = characterTeam
	self.enemyTeam = enemyTeam
	self.combatants = self:populateCombatants(characterTeam.members, enemyTeam.members)
	self.cameraPosX, self.cameraPosY = camera:position()

	self.qteManager = QTEManager(characterTeam)
	self.combatHazards = {
		characterHazards = {},
		enemyHazards = {}
	}
	self.signalHandlers = {}
	self.rewards = {}
end;

function Scheduler:enter()
	-- for Signal registration that is shared amongst all Scheduler classes
	self:registerSignal('OnEnemyKO',
		function(reward)
			table.insert(self.rewards, reward)
		end)
end;

---@param name string
---@param f fun(...)
function Scheduler:registerSignal(name, f)
	self.signalHandlers[name] = f
	Signal.register(name, f)
end;

function Scheduler:removeSignals()
	for name,f in pairs(self.signalHandlers) do
		Signal.remove(name, f)
	end
	self.signalHandlers = {}
end;

---@param characterMembers Character[]
---@param enemyMembers Enemy[]
---@return Entity[]
function Scheduler:populateCombatants(characterMembers, enemyMembers)
	local queue = {}
	for _,character in ipairs(characterMembers) do
		table.insert(queue, character)
	end
	for _,enemy in ipairs(enemyMembers) do
		table.insert(queue, enemy)
	end

	return queue
end;

---@return { [string]: Entity[] }
function Scheduler:getValidTargets()
	local result = {}
	result.characters = self.characterTeam:getLivingMembers()
	result.enemies = self.enemyTeam:getLivingMembers()
	return result
end;

---@param duration integer
function Scheduler:resetCamera(duration)
	flux.to(camera, duration, {x = self.cameraPosX, y = self.cameraPosY, scale = 1})
end;

---@return integer Duration of time for longest faint animation
function Scheduler:removeKOs()
	local koEnemies = {}
	local koCharacters = {}
	local duration = 0

	-- Get KO duration first so they aren't removed before seeing them faint
	for _,entity in ipairs(self.combatants) do
		if not entity:isAlive() then
			local faintDuration = entity:startFainting()
			duration = math.max(duration, faintDuration)
			if entity.type == "enemy" then
				table.insert(koEnemies, entity)
			else
				table.insert(koCharacters, entity)
			end
		end
		entity:resetDmgDisplay()
	end

  local removeIndices = {}
  for i=1, #self.combatants do
    for j=1, #koEnemies do
      if self.combatants[i] == koEnemies[j] then
        table.insert(removeIndices, i)
      end
    end
  end

  Timer.after(duration,
  	function()
		  for i=1, #removeIndices do
		    print('removing ' .. self.combatants[removeIndices[i]].entityName .. ' from combat')
		    table.remove(self.combatants, removeIndices[i])
		  end

		  self.enemyTeam:removeMembers(koEnemies)
		  self.characterTeam:registerKO(koCharacters)
  	end)
  -- for i=1, #removeIndices do
  --   print('removing ' .. self.combatants[removeIndices[i]].entityName .. ' from combat')
  --   table.remove(self.combatants, removeIndices[i])
  -- end

  -- self.enemyTeam:removeMembers(koEnemies)
  -- self.characterTeam:registerKO(koCharacters)

  return duration
end;

---@return boolean
function Scheduler:winLossConsMet()
  local result = false
  print('checking win loss cons')
  if self.enemyTeam:isWipedOut() then
    print('end combat')
    self:resetCamera(0)
    result = true
    -- Timer.after(1, function()
			for _,member in ipairs(self.characterTeam.members) do
				if member.actionUI then
					member.actionUI.active = false
				end
			end
			print('switching game states')
			Gamestate.switch(states['reward'], self.rewards, self.characterTeam)
    -- end)
  end
  if self.characterTeam:isWipedOut() then
    print('you lose')
    result = true
  end

  return result
end;

---@param dt number
function Scheduler:update(dt)
	for _,entity in pairs(self.combatants) do
		entity:update(dt)
	end
	self.qteManager:update(dt)
end;

function Scheduler:draw()
	self.qteManager:draw()
end;

return Scheduler