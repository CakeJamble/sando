-- Signal: OnTargetConfirm
---@param character Character
return function(character)
	local chance = 0.15
	local amount = character.skill.cost

	if chance >= love.math.random() then
		character:refresh(amount)
	end
end;