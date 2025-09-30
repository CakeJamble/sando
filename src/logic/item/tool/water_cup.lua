-- Signal: OnEquipSell
---@param characterTeam CharacterTeam
return function(_, characterTeam)
	for _,member in ipairs(characterTeam.members) do
		member:refresh(0.08)
	end
end;