local loadTool = require('util.tool_loader')

-- Signal: OnPickup
---@param characterTeam CharacterTeam
return function(characterTeam)
	local inventory = characterTeam.inventory
	local newMoney = math.ceil(inventory.money / 2)
	inventory:setMoney(newMoney)

	-- Add animation?
	local refurbishedIdol = loadTool('refurbished_idol')
	inventory:addTool(refurbishedIdol)
end;