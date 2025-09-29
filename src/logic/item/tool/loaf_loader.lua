-- Signal: OnPickup
---@param characterTeam CharacterTeam
return function(characterTeam)
	local co = coroutine.create(function()
		local selectedCharacter = characterTeam:yieldCharacterSelect()

		-- pack up 1 random skill from each character
		local skills = {}
		for _,character in ipairs(characterTeam.members) do
			local i = love.math.random(1, #character.skillPool)
			local skill = character.skillPool[i]
			table.insert(skills, skill)
		end

		-- Teach character the skill they select
		selectedCharacter:yieldSkillSelect(skills)
	end)
	coroutine.resume(co)
end;