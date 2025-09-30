-- Signal: OnTargetConfirm
---@param character Character
return function(character)
	local effects = character.skill.effects
	for _,effect in ipairs(effects) do
		if effect == "heal" then
			character.skill.damage = character.skill.damage + math.floor(0.5 + character.skill.damage * 0.4)
		end
	end
end;