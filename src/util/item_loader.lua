local json = require('libs.json')

local function loadItem(itemName)
	local jsonPath = 'data/item/' .. itemName .. '.json'
	local raw = love.filesystem.read(jsonPath)
	local data = json.decode(raw)

	local itemType
	if data.itemType then
		itemType = data.itemType .. '.'
	else
		error('The item: ' .. itemName .. ', did not have an itemType field defined')
	end

	local logicPath = 'logic.item.' .. itemType .. itemName
	local proc = require(logicPath)
	if proc then
		data.proc = proc
	else
		error('Failed to find implementation for item named \'' .. itemName .. '\': ' .. tostring(proc))
	end

	return data
end

return loadItem