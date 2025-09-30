-- Signal: OnGuard
---@param character Character
return function(character)
	character:modifyBattleStat('defense', 1)
	character:lowerAfterSkillResolves('defense', 1)
end;