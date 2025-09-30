-- Signal: OnPickup
---@param characterTeam CharacterTeam
return function(characterTeam)
	for _,member in ipairs(characterTeam.members) do
		for _,skill in ipairs(member.currentSkills) do
			if skill.isMultihit then
				skill.numHits = skill.numHits + 1
			end
		end
	end
end;