-- Signal: OnPickup
---@param characterTeam CharacterTeam
return function(characterTeam)
	local co = coroutine.create(function()
		local sourceChar = characterTeam:yieldCharacterSelect()
		local skill = sourceChar:yieldSkillSelect()
		local targetChar = characterTeam:yieldCharacterSelect({exclude = {sourceChar}})
		targetChar:learnSkill(skill)
	end)
	coroutine.resume(co)
end;