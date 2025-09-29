-- Signal: OnDebuffed
---@param character Character
return function(character)
	character:modifyBattleStat('random', 1)
end