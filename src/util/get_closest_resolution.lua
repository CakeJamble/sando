---@param dW number?
---@param dH number?
---@param resolutions number[][]
---@return integer, integer
return function(dW, dH, resolutions)
	local width, height

	for _, res in ipairs(resolutions) do
		local w, h = res[1], res[2]
		if w < dW and h < dH then
			width, height = w, h
		else
			break
		end
	end

	return width, height
end;