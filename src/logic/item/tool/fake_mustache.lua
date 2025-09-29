-- Signal: OnAttack
---@param character Character
return function(character)
	character.skill.damage = character.skill.damage + 3
end;