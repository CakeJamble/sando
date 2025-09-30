-- Signal: OnEndCombat
---@param characterTeam CharacterTeam
return function(characterTeam)
	characterTeam:increaseMoney(10)
end;