-- Signal: OnPurchase
---@param characterTeam CharacterTeam
return function(characterTeam)
	for _,member in ipairs(characterTeam) do
		local healAmount = member.baseStats.hp * 0.05
		member:heal(healAmount)
	end
end;