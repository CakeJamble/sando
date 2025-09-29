-- Signal: OnEndCombat
---@param characterTeam CharacterTeam
return function(characterTeam)
	characterTeam.inventory:gainMoney(10)
end;