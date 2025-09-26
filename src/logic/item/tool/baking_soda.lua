-- Signal: OnAttacked
---@param character Character
return function(character)
	local rand = love.math.random()
	if rand <= 0.25 then
		character:cleanse()
	end
end;