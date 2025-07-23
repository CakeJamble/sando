local json = require('libs.json')

local function loadTool(toolName)
	local jsonPath = 'data/item/tool/' .. toolName .. '.json'
	local logicPath = 'logic/item/tool/' .. toolName

	local raw = love.filesystem.read(jsonPath)
	local data = json.decode(raw)

	local proc = require('logic.item.tool.' .. skillName)
	if proc then
		data.proc = proc
	else
		error('Failed to find implementation for skill named \'' .. skillName .. '\': ' .. tostring(proc))
	end

	return data
end

return loadTool