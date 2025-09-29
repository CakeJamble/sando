-- Signal: OnStatusProc
---@param character Character
return function(character)
	local hp = character.battleStats.hp
	character.battleStats.hp = math.max(1, hp)
end;