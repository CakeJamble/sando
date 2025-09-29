-- Signal: OnLevelUp
---@param character Character
return function(character)
	local co = coroutine.create(function()
		local stat = character:yieldStatSelect()
		local amount = character:yieldStatRoll()
		character:raiseStat(stat, amount)
	end)
end;