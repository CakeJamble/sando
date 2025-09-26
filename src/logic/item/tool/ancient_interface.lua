-- Signal: OnStartCombat
---@param characterTeam CharacterTeam
return function(characterTeam)
	for _,character in ipairs(characterTeam) do
		character:modifyBattleStat("luck", 2)
		character:lowerAfterSkillResolves("luck", 2)
	end
end;