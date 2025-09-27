-- Signal: OnLevelUp
---@param character Character
return function(character)
	local amount = math.floor(0.5 + character.battleStats.fp * 0.15)
	character:refresh(amount)
end;