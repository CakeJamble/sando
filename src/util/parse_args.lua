---@param args string[]
---@return table
return function(args)
	local parsed = {}
	for _,arg in ipairs(args) do
		local k,v = arg:match("%-%-(%w+)=(%w+)")
		if k then
			parsed[k] = v
		end
	end
	return parsed
end;