local json = require('libs.json')

local function loadTool(toolName)
	local jsonPath = 'data/item/tool/' .. toolName .. '.json'
	local raw = love.filesystem.read(jsonPath)
	local data = json.decode(raw)

	local logicPath = 'logic.item.tool.' .. toolName
	local proc = require(logicPath)
	if proc then
		data.proc = proc
	else
		error('Failed to find implementation for tool named \'' .. toolName .. '\': ' .. tostring(proc))
	end

	data.index = 0

	return data
end;

return loadTool