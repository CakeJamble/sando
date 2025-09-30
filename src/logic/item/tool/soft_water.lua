-- Signal: OnPickup
---@param characterTeam CharacterTeam
return function(characterTeam)
	for _,member in ipairs(characterTeam.members) do
		member:cleanse()
		member:removeCurses()
	end
end;