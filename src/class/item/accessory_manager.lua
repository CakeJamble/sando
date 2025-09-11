local Class = require('libs.hump.class')
local Signal = require('libs.hump.signal')

---@class AccessoryManager
local AccessoryManager = Class{}

---@param characterTeam CharacterTeam
function AccessoryManager:init(characterTeam)
	self.characterTeam = characterTeam
	self.list = self.initItemLists()
	self.indices = self.initIndices(self.list)
	self.signalHandlers = {}
	self:registerSignals()
	self.showSwapInterface = false
	self.ui = nil
	self.i = 1
end;

---@param item table
function AccessoryManager:addItem(item)
	local signal = item.signal
	item.index = self.indices[signal]
	self.indices[signal] = self.indices[signal] + 1
	table.insert(self.list[signal], item)
	print('added ' .. item.name .. ' to: self.list.' .. signal)
end;

---@param item table
---@return table
function AccessoryManager:popItem(item)
	if item.index == 0 then
		error(item.name .. "'s index was never overwritten when added to the inventory")
	elseif #self.list[item.signal] == 0 then
		error('Attempted to pop off an empty table')
	else
		local signal = item.signal
		local i = item.index
		local result = table.remove(self.list[signal][i])
		self.indices[signal] = self.indices[signal] - 1
		return result
	end
end;

---@param character Character
---@param i integer
function AccessoryManager:equip(character, i, itemType)
	local item = table.remove(self.list, i)
	local numSlots

	if itemType == 'equip' then
		numSlots = character.numEquipSlots
	else -- itemType == 'accessory'
		numSlots = character.numAccessorySlots
	end

	if numSlots >= character.equips[itemType] then
		-- Coroutine: confirm to sell or equip back on and revert
		local co = self:createEquipCoroutine(character, item, itemType)
		coroutine.resume(co)
	end
end;

---@param character Character
---@param item table
---@param itemType string
---@return thread
function AccessoryManager:createEquipCoroutine(character, item, itemType)
	return coroutine.create(function()
		local stats = character.baseStats
		local gearTable = character.equips[itemType]
		self:displaySwapInterface(stats, gearTable, item)

		coroutine.yield('await choice')

		print('done with equip sale choice coroutine')
	end)
end;

---@return { [string]: table}
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
		OnTargetConfirm = {},
		OnEndTurn = {},
		OnEndCombat = {},
	}

	return result
end;

---@param list { [string]: table }
---@return { [string]: integer }
function AccessoryManager.initIndices(list)
	local result = {}
	for signal,_ in pairs(list) do
		result[signal] = 1
	end
	return result
end;

---@param name string
---@param f fun(...)
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
			for _,item in ipairs(self.list.OnStartTurn) do
				item.proc(character)
			end
		end)

	self:registerSignal('OnStartCombat',
		function()
			for _,item in ipairs(self.list.OnStartCombat) do
				item.proc()
			end
		end)

	self:registerSignal('OnAttack',
		function(skill)
			for _,item in ipairs(self.list.OnAttack) do
				item.proc(skill)
			end
		end)

	self:registerSignal('OnGuard',
		function(character)
			for _,item in ipairs(self.list.OnGuard) do
				item.proc(character)
			end
		end)

	self:registerSignal('OnEnemyAttack',
		function(enemy)
			for _,item in ipairs(self.list.OnEnemyAttack) do
				item.proc(enemy)
			end
		end)

	self:registerSignal('OnKO',
		function()
			for _,item in ipairs(self.list.OnKO) do
				item.proc()
			end
		end)

	self:registerSignal('OnLevelUp',
		function(character)
			for _,item in ipairs(self.list.OnLevelUp) do
				item.proc(character)
			end
		end)
end;

function AccessoryManager:draw()
	if self.showSwapInterface then
		self:drawSwapInterface()
	end
end;

---@param stats { [string]: integer }
---@param gearTable table
---@param item table
function AccessoryManager:displaySwapInterface(stats, gearTable, item)
	self.showSwapInterface = true
	self.ui = {
		mode = 'fill',
		x = 100,
		y = 100,
		w = 400,
		h = 200,
		offset = 40,
		stats = stats,
		gear = gearTable,
		item = item
	}
end;

function AccessoryManager:drawSwapInterface()
	love.graphics.rectangle(self.ui.mode, self.ui.x, self.ui.y, self.ui.w, self.ui.h)
	for i,item in ipairs(self.ui.gear) do
		love.graphics.draw(item.image, self.ui.x + self.ui.offset,
			self.ui.y + i * self.ui.offset)
	end

	love.graphics.draw(self.ui.item.image, self.ui.x + 2 * self.ui.offset,
		self.ui.y + self.i * self.ui.offset)
end;

return AccessoryManager