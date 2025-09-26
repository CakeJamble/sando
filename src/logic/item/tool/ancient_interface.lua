-- Signal: OnStartCombat
---@param characterTeam CharacterTeam
return function(characterTeam, _)
	for _,character in ipairs(characterTeam) do
		character:modifyBattleStat("luck", 2)
		character:lowerAfterSkillResolves("luck", 2)
	end
end;