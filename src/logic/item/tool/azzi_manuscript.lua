-- Signal: OnPickup
---@param characterTeam CharacterTeam
return function(characterTeam)
	characterTeam.rarityMod = characterTeam.rarityMod + 0.1
end;