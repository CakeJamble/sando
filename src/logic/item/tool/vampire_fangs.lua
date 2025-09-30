-- Signal: OnPickup
---@param characterTeam CharacterTeam
return function(characterTeam)
	local co = coroutine.create(function()
		local character = characterTeam:yieldCharacterSelect()
		character:lowerMaxHP(0.5)
		for _,skill in ipairs(character.skillPool) do
			table.insert(skill.effects, 'lifesteal')
		end
		for _,skill in ipairs(character.currentSkills) do
			table.insert(skill.effects, 'lifesteal')
		end
	end)
	coroutine.resume(co)
end;