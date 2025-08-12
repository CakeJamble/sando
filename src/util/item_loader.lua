local json = require('libs.json')

local function loadItem(itemName)
	local jsonPath = 'data/item/' .. itemName .. '.json'
	local logicPath = 'logic/skill/' .. itemName

	local raw = love.filesystem.read(jsonPath)
	local data = json.decode(raw)

	local proc = require('logic.item.' .. itemName)
	if proc then
		data.proc = proc
	else
		error('Failed to find implementation for item named \'' .. itemName .. '\': ' .. tostring(proc))
	end

	item.tag = itemName
	return data
end

return loadItem