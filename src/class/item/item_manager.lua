local Class = require('libs.hump.class')
local Signal = require('libs.hump.signal')
local ItemManager = Class{}

function ItemManager:init(characterTeam)
	self.characterTeam = characterTeam
	self.indices, self.items = self.initItemLists()
	self.signalHandlers = {}
	self:registerSignals()
end;

function ItemManager:addItem(item)
	local itemType = item.itemType
	local signal = item.signal
	item.index = self.indices[itemType][signal]
	self.indices[itemType][signal] = self.indices[itemType][signal] + 1
	table.insert(self.items[item.itemType][item.signal], item)
	if item.signal == 'OnPickup' then
		item.proc(self.characterTeam)
	end
end;

function ItemManager:popItem(item)
	if item.index == 0 then
		error(item.name .. "'s index was never overwritten when added to the inventory")
	elseif #self.items[item.itemType][item.signal] == 0 then
		error('Attempted to pop off an empty table')
	else
		local result = table.remove(self.items[item.itemType][item.signal][item.index])
		local itemType = item.itemType
		local signal = item.signal
		self.indices[itemType][signal] = self.indices[itemType][signal] - 1
		return result
	end
end;

function ItemManager.initItemLists()
	local result = {}
	local indices = {}
	local itemType = {'accessory', 'equip', 'tool'}
	for _,t in pairs(itemType) do
		result[t] = {
			OnStartTurn = {},
			OnStartCombat = {},
			OnAttack = {},
			OnDefend = {},
			OnEnemyAttack = {},
			OnLevelUp = {},
			OnKO = {},
		}

		indices[t] = {
			OnStartTurn = 1,
			OnStartCombat = 1,
			OnAttack = 1,
			OnDefend = 1,
			OnEnemyAttack = 1,
			OnLevelUp = 1,
			OnKO = 1
		}

		-- Types & Signals specific to tools
		if t == 'tool' then
			result[t].OnPickup = {}
			result[t].OnPurchase = {}
			result[t].OnEquipSell = {}
			result[t].OnAccSell = {}

			indices[t].OnPickup = 1
			indices[t].OnPurchase = 1
			indices[t].OnEquipSell = 1
			indices[t].OnAccSell = 1
		end
	end
	return indices, result
end;

function ItemManager:registerSignal(name, f)
	self.signalHandlers[name] = f
	Signal.register(name, f)
end;

function ItemManager:registerSignals()
	self:registerSignal('OnStartTurn',
		function(character)
			for _,itemList in ipairs(self.items) do
				for _,item in pairs(itemList.OnStartTurn) do
					item.proc(character)
				end
			end
		end)

	self:registerSignal('OnStartCombat',
		function()
			for _,itemList in ipairs(self.items) do
				for _,item in ipairs(itemList.OnStartCombat) do
					item.proc(self.characterTeam, self.enemyTeam)
				end
			end
		end)

	self:registerSignal('OnAttack',
		function(skill)
			for _,itemList in ipairs(self.items) do
				for _,item in ipairs(itemList.OnAttack) do
					item.proc(skill)
				end
			end
		end)

	self:registerSignal('OnDefend',
		function(character)
			for _,itemList in ipairs(self.items) do
				for _,item in ipairs(itemList.OnDefend) do
					item.proc(character)
				end
			end
		end)

	self:registerSignal('OnEnemyAttack',
		function(enemy)
			for _,itemList in ipairs(self.items) do
				for _,item in ipairs(itemList.OnEnemyAttack) do
					item.proc(enemy)
				end
			end
		end)

	self:registerSignal('OnKO',
		function()
			for _,itemList in ipairs(self.items) do
				for _,item in ipairs(itemList.OnKO) do
					item.proc()
				end
			end
		end)

	self:registerSignal('OnLevelUp',
		function(character)
			for _,itemList in ipairs(self.items) do
				for _,item in ipairs(itemList.OnLevelUp) do
					item.proc(character)
				end
			end
		end)

	self:registerSignal('OnPurchase',
		function()
			for _,itemList in ipairs(self.items) do
				for _,item in ipairs(itemList.OnPurchase) do
					item.proc()
				end
			end
		end)

	self:registerSignal('OnEquipSell',
		function(equip)
			for _,itemList in ipairs(self.items) do
				for _,item in ipairs(itemList.OnEquipSell) do
					item.proc(equip)
				end
			end
		end)

	self:registerSignal('OnAccSell',
		function(accessory)
			for _,itemList in ipairs(self.items) do
				for _,item in ipairs(itemList.OnAccSell) do
					item.proc(accessory)
				end
			end
		end)
end;

return ItemManager