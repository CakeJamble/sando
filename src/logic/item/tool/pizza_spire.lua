-- Signal: OnSwapMembers
---@param swapOutCharacter Character
---@param swapInCharacter Character
return function(swapOutCharacter, swapInCharacter)
	local amountHP = swapOutCharacter.baseStats.hp * math.floor(0.5 + 0.05 * swapOutCharacter.baseStats.hp)
	swapOutCharacter:heal(amountHP)

	local amountFP = swapInCharacter.baseStats.fp * math.floor(0.5 + 0.05 * swapOutCharacter.baseStats.hp)
	swapInCharacter:refresh(amountFP)
end;