return function(characterTeam)
	for _,member in ipairs(characterTeam.members) do
		local numStages = member.numSkillSlots - #member.currentSkills
		if numStages > 0 then
			member:modifyBattleStat('attack', numStages)
		end
	end
end;
