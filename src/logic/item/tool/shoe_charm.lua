-- Signal OnBuff
---@param character Character
---@param buff string
return function(character, buff)
	if buff == "speed" then
		character:modifyBattleStat('luck', 1)
	end
end;