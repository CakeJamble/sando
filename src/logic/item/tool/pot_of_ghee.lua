-- Signal: OnTargetConfirm
---@param character Character
---@param buff string
return function(character, buff)
	character:modifyBattleStat(buff, 1)
end;