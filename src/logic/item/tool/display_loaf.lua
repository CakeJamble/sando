-- OnSignal: OnAttack
---@param character Character
return function(character)
	local amount = 5 - character.skill.damage
	if amount > 0 then
		character.target:takeDamagePierce(amount)
	end
end;