local Signal = require('libs.hump.signal')
local Class = require 'libs.hump.class'
local ToolManager = Class{}

function ToolManager:init(characterTeam)
	self.toolList = {}
	self.startTurnToolList = {}
	self.onStartBattleList = {}
	self.pickupToolList = {}
	self.onAttackList = {}
	self.onDefendList = {}
	self.onEnemyAttackList = {}
	self.onLevelList = {}
	self.characterTeam = characterTeam
	self.enemyTeam = nil

	Signal.register('OnStartTurn',
		function(character)
			for _,tool in pairs(self.startTurnToolList) do
				tool.proc(character)
			end
		end
	)

	-- OnPickup Tools only proc once, so they pass self as an argument to manager
	Signal.register('OnPickup',
		function(tool)
			tool.proc(self.characterTeam)
		end
	)

	Signal.register('OnStartBattle',
		function()
			for _,tool in ipairs(#self.onStartBattleList) do
				tool.proc(self.characterTeam, self.enemyTeam)
			end
		end
	)

	Signal.register('OnAttack',
		function(skill)
			for _,tool in ipairs(self.onAttackList) do
				tool.proc(skill)
			end
		end
	)

	Signal.register('OnDefend',
		function(character)
			for _,tool in ipairs(self.onDamagedToolList) do
				tool.proc(character)
			end
		end
	)

	Signal.register('OnEnemyAttack',
		function(enemy)
			for _,tool in ipairs(self.onEnemyAttackList) do
				tool.proc(enemy)
			end
		end
	)

	Signal.register('OnKO',
		function()
			for _,tool in ipairs(self.onKOList) do
				tool.proc(self.characterTeam, self.enemyTeam)
			end
		end
	)

	Signal.register('OnLevelUp',
		function(character)
			for _,tool in ipairs(self.onLevelList) do
				tool.proc(character)
			end
		end
	)

	Signal.register('OnPurchase',
		function(characterTeam)
			for _,tool in ipairs(self.onPurchaseList) do
				-- do
			end
		end
	)

	Signal.register('OnEquipSell',
		function(equip)
			for _,tool in ipairs(self.onEquipSellList) do
				tool.proc(equip, self.characterTeam)
			end
		end
	)

	Signal.register('OnAccSell',
		function(accessory)
			for _,tool in ipairs(self.onAccSellList) do
				tool.proc(accessory, self.characterTeam.inventory)
			end
		end
	)
end;

function ToolManager:set(enemyTeam)
	self.enemyTeam = enemyTeam
end;

function ToolManager:reset()
	self.enemyTeam  = nil
end;

--[[Present the prompt for the player to choose which character they will apply the buff to.
Once selected, apply the buff and close the prompt.]]
function ToolManager:chooseCharacter(tool, buff)
	--do
end;

function ToolManager:update(dt)
	for _,tool in pairs(self.toolList) do
		tool:update(dt)
	end
end;

function ToolManager:draw()
	for _,tool in pairs(self.toolList) do
		tool:draw()
	end
end;

return ToolManager