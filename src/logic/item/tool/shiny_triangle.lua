-- Signal: OnPickup
---@param characterTeam CharacterTeam
return function(characterTeam)
	local allSkills = {}
	local numSkillsToReplace = {}

	-- Collect all skills
	for _,member in ipairs(characterTeam.members) do
		numSkillsToReplace[member.entityName] = 0
		for _,skill in ipairs(member.skillPool) do
			table.insert(allSkills, skill)
			numSkillsToReplace[member.entityName] = numSkillsToReplace[member.entityName] + 1
		end

		-- clear out member's skill pool
		for i,_ in ipairs(member.skillPool) do
			table.remove(member.skillPool, i)
		end
	end

	-- randomly assign new skill pool based on size of old skill pool
	for _,member in ipairs(characterTeam.members) do
		local numSkills = numSkillsToReplace[member.entityName]
		for i=1,numSkills do
			local j = love.math.random(#allSkills)
			local skill = table.remove(allSkills, j)
			table.insert(member.skillPool, skill)
		end
	end
end;