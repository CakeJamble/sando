--! tool_manager

Class = require 'libs.hump.class'
ToolManager = Class{}

function ToolManager:init(characterTeam)
	self.toolList = {}
	self.startTurnToolList = {}
	self.pickupToolList = {}
	self.onAttackList = {}
	self.onDefendList = {}
	self.onEnemyAttackList = {}
	self.onLevelList = {}
	self.characterTeam = characterTeam

	Signal.register('OnStartTurn',
		-- Proc the effects of Turn Start Tools
		function(character)
			for i,tool in pairs(self.startTurnToolList) do
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

	Signal.register('OnAttack',
		function(skill)
			for i,tool in pairs(self.onAttackList) do
				tool.proc(skill)
			end
		end
	)

	Signal.register('OnDefend',
		function(character)
			for i,tool in pairs(self.onDamagedToolList) do
				tool.proc(character)
		end
	)

	Signal.register('OnEnemyAttack',
		function(enemy)
			for i,tool in pairs(self.onEnemyAttackList)) do
				tool.proc(enemy)
			end
		end
	)

	Signal.register('OnLevelUp',
		function(character)
			for i,tool in pairs(self.onLevelList) do
				tool.proc(character)
		end
	)
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