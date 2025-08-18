local Class = require('libs.hump.class')
local Signal = require('libs.hump.signal')
local ToolManager = Class{}

function ToolManager:init(characterTeam)
	self.characterTeam = characterTeam
	self.items = self.initItemLists()
	self.indices = self.initIndices()
	self.signalHandlers = {}
	self:registerSignals()
end;

function ToolManager:addTool(tool)
	local signal = tool.signal
	tool.index = self.indices[signal]
	self.indices[signal] = self.indices[signal] + 1
	table.insert(self.items[signal], tool)
	print('added ' .. tool.name .. ' to list: items.' .. signal)
	if signal == 'OnPickup' then
		tool.proc(self.characterTeam)
	end
end;

function ToolManager:popTool(tool)
	if tool.index == 0 then
		error(tool.name .. "'s index was never overwritten when added to the inventory")
	elseif #self.items[tool.signal] == 0 then
		error('Attempted to pop off an empty table')
	else
		local signal = tool.signal
		local i = tool.index
		local result = table.remove(self.items[signal][i])
		self.indices[signal] = self.indices[signal] - 1
		return result
	end
end;

function ToolManager.initItemLists()
	local result = {
		OnStartTurn = {},
		OnStartCombat = {},
		OnAttack = {},
		OnGuard = {},
		OnEnemyAttack = {},
		OnLevelUp = {},
		OnKO = {},
		OnPickup = {},
		OnPurchase = {},
		OnEquipSell = {},
		OnAccSell = {},
	}

	return result
end;

function ToolManager.initIndices()
	local result = {
		OnStartTurn = 1,
		OnStartCombat = 1,
		OnAttack = 1,
		OnGuard = 1,
		OnEnemyAttack = 1,
		OnLevelUp = 1,
		OnKO = 1,
		OnPickup = 1,
		OnPurchase = 1,
		OnEquipSell = 1,
		OnAccSell = 1,
	}
	return result
end;

function ToolManager:registerSignal(name, f)
	self.signalHandlers[name] = f
	Signal.register(name, f)
end;

function ToolManager:registerSignals()
	self:registerSignal('OnStartTurn',
		function(character)
			for _,item in ipairs(self.items.OnStartTurn) do
				item.proc(character)
			end
		end)

	self:registerSignal('OnStartCombat',
		function()
			for _,item in ipairs(self.items.OnStartCombat) do
				item.proc()
			end
		end)

	self:registerSignal('OnAttack',
		function(skill)
			for _,item in ipairs(self.items.OnAttack) do
				item.proc(skill)
			end
		end)

	self:registerSignal('OnGuard',
		function(character)
			for _,item in ipairs(self.items.OnGuard) do
				item.proc(character)
			end
		end)

	self:registerSignal('OnEnemyAttack',
		function(enemy)
			for _,item in ipairs(self.items.OnEnemyAttack) do
				item.proc(enemy)
			end
		end)

	self:registerSignal('OnKO',
		function()
			for _,item in ipairs(self.items.OnKO) do
				item.proc()
			end
		end)

	self:registerSignal('OnLevelUp',
		function(character)
			for _,item in ipairs(self.items.OnLevelUp) do
				item.proc(character)
			end
		end)

	self:registerSignal('OnPurchase',
		function()
			for _,item in ipairs(self.items.OnPurchase) do
				item.proc()
			end
		end)

	self:registerSignal('OnEquipSell',
		function(equip)
			for _,item in ipairs(self.items.OnEquipSell) do
				item.proc(equip)
			end
		end)

	self:registerSignal('OnAccSell',
		function(accessory)
			for _,item in ipairs(self.items.OnAccSell) do
				item.proc(accessory)
			end
		end)
end;

return ToolManager