-- Signal: OnPickup
---@param characterTeam CharacterTeam
return function(characterTeam)
	characterTeam.inventory.numConsumableSlots = 2 + characterTeam.inventory.numConsumableSlots
end;