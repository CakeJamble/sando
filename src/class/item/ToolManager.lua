local Class = require('libs.hump.class')
local Signal = require('libs.hump.signal')

---@class ToolManager
local ToolManager = Class{}

---@param characterTeam CharacterTeam
function ToolManager:init(characterTeam)
	self.characterTeam = characterTeam
	self.tools = self.initToolLists()
	self.indices = self.initIndices(self.tools)
	self.signalHandlers = {}
	self:registerSignals()
end;

---@param tool table
function ToolManager:addItem(tool)
	local signal = tool.signal
	tool.index = self.indices[signal]
	self.indices[signal] = self.indices[signal] + 1
	table.insert(self.tools[signal], tool)
	print('added ' .. tool.name .. ' to list: tools.' .. signal)
	if signal == 'OnPickup' then
		tool.proc(self.characterTeam)
	end
end;

---@param tool table
---@return table
function ToolManager:popItem(tool)
	if tool.index == 0 then
		error(tool.name .. "'s index was never overwritten when added to the inventory")
	elseif #self.tools[tool.signal] == 0 then
		error('Attempted to pop off an empty table')
	else
		local signal = tool.signal
		local i = tool.index
		local result = table.remove(self.tools[signal][i])
		self.indices[signal] = self.indices[signal] - 1
		return result
	end
end;


---@return { [string]: table}
function ToolManager.initToolLists()
	local result = {
		OnStartTurn = {},
		OnStartCombat = {},
		OnAttack = {},
		OnGuard = {},
		OnEnemyAttack = {},
		OnLevelUp = {},
		OnKO = {},
		OnTargetConfirm = {},
		OnEndTurn = {},
		OnEndCombat = {},
		OnPickup = {},
		OnAttacked = {},
		OnPurchase = {},
		OnSpeedRaise = {},
		OnRecoil = {},
		OnEnterShop = {},
		OnCleanseCurse = {},
		OnConsumableUse = {},
		OnEscape = {},
		OnFaint = {},
		OnSummon = {},
		OnDebuffed = {},
		OnBuff = {},
		OnStatusProc = {},
		OnSellEquip = {},
		OnSwapMembers = {},
		OnQTESuccess = {},
		OnSellAccessory = {},
		OnEnemyBuffed = {},
		OnSkillResolved = {},
	}

	return result
end;

---@param tools { [string]: table }
---@return { [string]: integer }
function ToolManager.initIndices(tools)
	local result = {}
	for signal,_ in pairs(tools) do
		result[signal] = 1
	end
	return result
end;

---@param name string
---@param f fun(...)
function ToolManager:registerSignal(name, f)
	self.signalHandlers[name] = f
	Signal.register(name, f)
end;

function ToolManager:registerSignals()
	self:registerSignal('OnStartTurn',
		function(character)
			for _,item in ipairs(self.tools.OnStartTurn) do
				item.proc(character)
			end
		end)

	self:registerSignal('OnStartCombat',
		function(characterTeam, enemyTeam)
			for _,item in ipairs(self.tools.OnStartCombat) do
				item.proc(characterTeam, enemyTeam)
			end
		end)

-- consider making it OnRewardEnter or something?
	self:registerSignal('OnEndCombat',
		function(characterTeam)
			for _,item in ipairs(self.tools.OnEndCombat) do
				item.proc(characterTeam)
			end
		end)


	self:registerSignal('OnAttack',
		function(character)
			for _,item in ipairs(self.tools.OnAttack) do
				item.proc(character)
			end
		end)

	self:registerSignal('OnAttacked',
		function(character, enemy)
			for _,item in ipairs(self.tools.OnAttacked) do
				item.proc(character, enemy)
			end
		end)

	self:registerSignal('OnGuard',
		function(character)
			for _,item in ipairs(self.tools.OnGuard) do
				item.proc(character)
			end
		end)

	self:registerSignal('OnEnemyAttack',
		function(enemy)
			for _,item in ipairs(self.tools.OnEnemyAttack) do
				item.proc(enemy)
			end
		end)

	self:registerSignal('OnBuff',
		function(target, enemyTeam)
			for _,item in ipairs(self.tools.OnBuff) do
				item.proc(target, enemyTeam)
			end
		end)

	self:registerSignal('OnDebuffed',
		function(character)
			for _,item in ipairs(self.tools.OnDebuffed) do
				item.proc(character)
			end
		end)

	self:registerSignal('OnEnemyBuffed',
		function(enemy, characterTeam)
			for _,item in ipairs(self.tools.OnEnemyBuffed) do
				item.proc(enemy, characterTeam)
			end
		end)

	self:registerSignal('OnKO',
		function(character, enemies, koEnemies)
			for _,item in ipairs(self.tools.OnKO) do
				item.proc(character, enemies, koEnemies)
			end
		end)

	self:registerSignal('OnFaint',
		function(enemy, koCharacters)
			for _,item in ipairs(self.tools.OnFaint) do
				item.proc(enemy, koCharacters)
			end
		end)

	self:registerSignal('OnLevelUp',
		function(character)
			for _,item in ipairs(self.tools.OnLevelUp) do
				item.proc(character)
			end
		end)

	self:registerSignal('OnEnterShop',
		function(characterTeam)
			for _,item in ipairs(self.tools.OnEnterShop) do
				item.proc(characterTeam)
			end
		end)

	self:registerSignal('OnPurchase',
		function(characterTeam)
			for _,item in ipairs(self.tools.OnPurchase) do
				item.proc(characterTeam)
			end
		end)

	self:registerSignal('OnEquipSell',
		function(equip, characterTeam)
			for _,item in ipairs(self.tools.OnEquipSell) do
				item.proc(equip, characterTeam)
			end
		end)

	self:registerSignal('OnAccSell',
		function(accessory, characterTeam)
			for _,item in ipairs(self.tools.OnAccSell) do
				item.proc(accessory, characterTeam)
			end
		end)

	self:registerSignal('OnSkillResolved',
		function(entity)
			for _,item in ipairs(self.tools.OnSkillResolved) do
				if entity.type == "character" then item.proc(entity) end
			end
		end)

	self:registerSignal('OnConsumableUse',
		function()
		end)
end;

return ToolManager