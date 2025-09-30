-- Signal: OnPickup
---@param characterTeam CharacterTeam
return function(characterTeam)
	local members = characterTeam.members
	local percentIncrease = 0.08
	for _,member in ipairs(members) do
		local ratio = member.battleStats.hp / member.baseStats.hp
		local amount = math.ceil(percentIncrease * member.baseStats.hp)
		member.baseStats.hp = member.baseStats.hp + amount
		member.battleStats.hp = math.ceil(member.baseStats.hp * ratio)
	end
end;