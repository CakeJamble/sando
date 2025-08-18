-- On pickup, slightly increase all member's defense stat

return function(members)
	for _,member in pairs(members) do
		local amount = math.ceil(0.08 * member.baseStats.defense)
		member.baseStats.defense = member.baseStats.defense + amount
	end
end;