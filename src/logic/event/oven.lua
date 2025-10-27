local loadItem = require('util.item_loader')

-- Determine if event succeeded or failed, and return the relevant data for the next screen
---@param selection integer Which index of the options array the player selected
---@param eventData table Decoded JSON table for the event
---@param characterTeam CharacterTeam
return function(selection, eventData, characterTeam)
	local itemData = eventData.item
	local result = {}

	if selection == 1 then -- risking it by reaching into the oven
		local roll = love.math.random()

		if roll >= eventData.successRate then
			result.item = loadItem(itemData.name, itemData.itemType)
			result.text = eventData.results.reach.success
		else
			result.text = eventData.results.reach.fail
			result.penalty = eventData.penalty
		end
	else -- selection == 2 (leave without risking it)
		result.text = eventData.results.leave
	end

	return result
end;