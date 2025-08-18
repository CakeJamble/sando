local Signal = require('libs.hump.signal')
local Class = require 'libs.hump.class'
local ToolManager = Class{}

function ToolManager:init(members)
	self.tools = {
		OnStartTurn = {},
		OnStartCombat = {},
		OnPickup = {},
		OnAttack = {},
		OnDefend = {},
		OnEnemyAttack = {},
		OnLevelUp = {},
		OnKO = {},
		OnPurchase = {},
		OnEquipSell = {},
		OnAccSell = {}
	}

	self.members = members
	self.enemyTeam = nil

	Signal.register('OnStartTurn',
		function(character)
			for _,tool in pairs(self.tools.startTurnToolList) do
				tool.proc(character)
			end
		end
	)

	Signal.register('OnStartCombat',
		function()
			for _,tool in ipairs(self.tools.OnStartCombat) do
				tool.proc(self.characterTeam, self.enemyTeam)
			end
		end
	)

	Signal.register('OnAttack',
		function(skill)
			for _,tool in ipairs(self.tools.onAttackList) do
				tool.proc(skill)
			end
		end
	)

	Signal.register('OnDefend',
		function(character)
			for _,tool in ipairs(self.tools.onDefendList) do
				tool.proc(character)
			end
		end
	)

	Signal.register('OnEnemyAttack',
		function(enemy)
			for _,tool in ipairs(self.tools.onEnemyAttackList) do
				tool.proc(enemy)
			end
		end
	)

	Signal.register('OnKO',
		function()
			for _,tool in ipairs(self.tools.onKOList) do
				tool.proc(self.characterTeam, self.enemyTeam)
			end
		end
	)

	Signal.register('OnLevelUp',
		function(character)
			for _,tool in ipairs(self.tools.OnLevelUp) do
				tool.proc(character)
			end
		end
	)

	Signal.register('OnPurchase',
		function()
			for _,tool in ipairs(self.tools.OnPurchase) do
				-- do
			end
		end
	)

	Signal.register('OnEquipSell',
		function(equip)
			for _,tool in ipairs(self.onEquipSellList) do
				tool.proc(equip, self.members)
			end
		end
	)

	Signal.register('OnAccSell',
		function(accessory)
			for _,tool in ipairs(self.onAccSellList) do
				tool.proc(accessory, self.members)
			end
		end
	)
end;

function ToolManager:set(enemyTeam)
	self.enemyTeam = enemyTeam
end;

function ToolManager:addTool(tool)
	table.insert(self.tools[tool.signal], tool)
	if tool.signal == 'OnPickup' then
		tool.proc(self.members)
	end
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