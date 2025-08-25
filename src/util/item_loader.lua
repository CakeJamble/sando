local json = require('libs.json')

local function loadItem(itemName, itemType)
	local jsonPath = 'data/item/' .. itemType .. '/'
	jsonPath = jsonPath .. itemName .. '.json'
	local raw = love.filesystem.read(jsonPath)
	local data = json.decode(raw)

	local logicPath = 'logic.item.' .. itemType .. '.' .. itemName
	local proc = require(logicPath)
	if proc then
		data.proc = proc
	else
		error('Failed to find implementation for item named \'' .. itemName .. '\': ' .. tostring(proc))
	end

	return data
end

return loadItem