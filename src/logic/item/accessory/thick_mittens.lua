return function(character)
	local skill = character.skill
	skill.recoil = math.floor(skill.recoil)
end;