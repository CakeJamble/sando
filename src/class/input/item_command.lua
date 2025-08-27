local Command = require('class.input.command')
local Class = require('libs.hump.class')

---@class ItemCommand: Command
local ItemCommand = Class{__includes = Command}

---@param entity Entity
---@param item table
---@param qteManager QTEManager
function ItemCommand:init(entity, item, qteManager)
	Command.init(self, entity)
	self.qteManager = qteManager
	self.item = item
	self.done = false
	self.isInterruptible = false
end;

---@param turnManager Scheduler
function ItemCommand:start(turnManager)
	local projectileMade = function(projectile)
		table.insert(self.entity.projectiles, projectile)
	end
	local despawnProjectile = function(index)
		local i = index or 1
		table.remove(self.entity.projectiles, i)
	end
	self:registerSignal('ProjectileMade', projectileMade)
	self:registerSignal('DespawnProjectile', despawnProjectile)

	local endTurn = function()
		self:cleanupSignals()
		self.done = true
	end
	self:registerSignal('OnEndTurn', endTurn)

	local qteType = self.item.qteType
	if self.qteManager and qteType then
		self.waitingForQTE = true
		self.qteManager:setQTE(qteType, self.entity.actionButton, self.item)
		self.qteManager.activeQTE:setUI(self.entity)
		self.qteManager.activeQTE:beginQTE(function()
			self:executeItemAction()
		end)
	else
		self:executeItemAction()
	end
end;

function ItemCommand:executeItemAction()
	self.item.proc(self.item, self.entity)
end;

---@param dt number
function ItemCommand:update(dt)
	if self.qteManager and self.waitingForQTE then
		self.qteManager:update(dt)
	end
end;

return ItemCommand