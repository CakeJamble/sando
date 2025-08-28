local json = require('libs.json')

---@param qteName string
---@return { [string]: any }
local function loadQTE(qteName)
	local jsonPath = 'data/qte/' .. qteName .. '.json'

	local raw = love.filesystem.read(jsonPath)
	local data = json.decode(raw)

	-- Load images and overwrite table of paths with images
	local feedbackDir = 'asset/sprites/combat/qte/feedback/'
	local feedback = {}
	for i,path in ipairs(data.feedbackList) do
		local image = love.graphics.newImage(feedbackDir .. path)
		feedback[i] = image
	end
	data.feedbackList = feedback

	return data
end

return loadQTE