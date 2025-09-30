-- Signal: OnSpeedRaise
---@param character Character
return function(character)
	character:modifyBattleStat('luck', 1)
end;