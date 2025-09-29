-- Signal: OnPickup
---@param characterTeam CharacterTeam
return function(characterTeam)
	characterTeam.discount = characterTeam.discount + 0.08
end;