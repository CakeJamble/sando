-- Signal: OnPickup
---@param characterTeam CharacterTeam
return function(characterTeam)
	for _,character in ipairs(characterTeam) do
		character.numAccessorySlots = character.numAccessorySlots + 1
	end
end;