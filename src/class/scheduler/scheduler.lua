require('class.input.player_input_command')
require('class.input.skill_command')
require('class.input.cancel_command')
require('class.input.ai_command')
require('class.qte.qte_manager')
require('util.globals')
Scheduler = Class{}

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
end;

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

function Scheduler:populateCombatants(characterMembers, enemyMembers)
	local queue = {}
	for i,character in ipairs(characterMembers) do
		table.insert(queue, character)
	end
	for i,enemy in ipairs(enemyMembers) do
		table.insert(queue, enemy)
	end

	return queue
end;

function Scheduler:resetCamera(duration)
	flux.to(camera, duration, {x = self.cameraPosX, y = self.cameraPosY, scale = 1})
end;

function Scheduler:removeKOs()
	local koEnemies = {}
	local koCharacters = {}
	for i=1, #self.combatants do
		local entity = self.combatants[i]
		if not entity:isAlive() then
			if entity.type == 'enemy' then
				table.insert(koEnemies, entity)
			else
				table.insert(koCharacters, entity)
			end
		else
			self.combatants[i]:resetDmgDisplay()
			-- self.combatants[i].state = 'idle'
		end
	end

  local removeIndices = {}
  for i=1, #self.turnQueue do
    for j=1, #koEnemies do
      if self.combatants[i] == koEnemies[j] then
        table.insert(removeIndices, i)
      end
    end
  end

  for i=1, #removeIndices do
    print('removing ' .. self.turnQueue[removeIndices[i]].entityName .. ' from combat')
    table.remove(self.turnQueue, removeIndices[i])
  end

  self.enemyTeam:removeMembers(koEnemies)
  self.characterTeam:registerKO(koCharacters)
end;

function Scheduler:winLossConsMet()
  local result = false
  print('checking win loss cons')
  if self.enemyTeam:isWipedOut() then
    print('end combat')
    Gamestate.switch(states['reward'], self.rewards)
    result = true
  end
  if self.characterTeam:isWipedOut() then
    print('you lose')
    result = true
  end

  return result
end;

function Scheduler:update(dt)
	for _,entity in pairs(self.combatants) do
		entity:update(dt)
	end
	self.qteManager:update(dt)
end;

function Scheduler:draw()
	self.qteManager:draw()
end;