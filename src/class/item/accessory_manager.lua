local Class = require('libs.hump.class')
local Signal = require('libs.hump.signal')
local AccessoryManager = Class{}

function AccessoryManager:init(characterTeam)
	self.characterTeam = characterTeam
	self.accessories = self.initItemLists()
	self.indices = self.initIndices()
	self.signalHandlers = {}
	self:registerSignals()
end;

function AccessoryManager:addAccessory(accessory)
	local signal = accessory.signal
	accessory.index = self.indices[signal]
	self.indices[signal] = self.indices[signal] + 1
	table.insert(self.accessories[signal], accessory)
	print('added ' .. accessory.name .. ' to list: items.' .. signal)
end;

function AccessoryManager:popAccessory(accessory)
	if accessory.index == 0 then
		error(accessory.name .. "'s index was never overwritten when added to the inventory")
	elseif #self.accessories[accessory.signal] == 0 then
		error('Attempted to pop off an empty table')
	else
		local signal = accessory.signal
		local i = accessory.index
		local result = table.remove(self.accessories[signal][i])
		self.indices[signal] = self.indices[signal] - 1
		return result
	end
end;

function AccessoryManager:equip(character, accIndex)
	local accessory = table.remove(self.accessories, accIndex)
	local isAccessory = true
	local oldAccessory = character:equip(accessory, isAccessory)
	return oldAccessory
end;

function AccessoryManager.initItemLists()
	local result = {
		OnEquip = {},
		OnStartTurn = {},
		OnStartCombat = {},
		OnAttack = {},
		OnGuard = {},
		OnEnemyAttack = {},
		OnLevelUp = {},
		OnKO = {},
	}

	return result
end;

function AccessoryManager.initIndices()
	local result = {
		OnStartTurn = 1,
		OnStartCombat = 1,
		OnAttack = 1,
		OnGuard = 1,
		OnEnemyAttack = 1,
		OnLevelUp = 1,
		OnKO = 1,
	}
	return result
end;

function AccessoryManager:registerSignal(name, f)
	self.signalHandlers[name] = f
	Signal.register(name, f)
end;

function AccessoryManager:registerSignals()
	self:registerSignal('OnEquip',
		function(character, item)
			item.proc(character)
		end)

	self:registerSignal('OnStartTurn',
		function(character)
			for _,item in ipairs(self.accessories.OnStartTurn) do
				item.proc(character)
			end
		end)

	self:registerSignal('OnStartCombat',
		function()
			for _,item in ipairs(self.accessories.OnStartCombat) do
				item.proc()
			end
		end)

	self:registerSignal('OnAttack',
		function(skill)
			for _,item in ipairs(self.accessories.OnAttack) do
				item.proc(skill)
			end
		end)

	self:registerSignal('OnGuard',
		function(character)
			for _,item in ipairs(self.accessories.OnGuard) do
				item.proc(character)
			end
		end)

	self:registerSignal('OnEnemyAttack',
		function(enemy)
			for _,item in ipairs(self.accessories.OnEnemyAttack) do
				item.proc(enemy)
			end
		end)

	self:registerSignal('OnKO',
		function()
			for _,item in ipairs(self.accessories.OnKO) do
				item.proc()
			end
		end)

	self:registerSignal('OnLevelUp',
		function(character)
			for _,item in ipairs(self.accessories.OnLevelUp) do
				item.proc(character)
			end
		end)
end;

return AccessoryManager