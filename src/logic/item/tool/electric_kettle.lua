-- Signal: OnEnterShop
---@param characterTeam CharacterTeam
return function(characterTeam)
	for _, member in ipairs(characterTeam.members) do
		local amount = 0.2 * member.baseStats.hp
		member:heal(amount)
	end
end;