-- Signal: OnSummon
---@param enemy Enemy
return function(enemy)
	enemy:applyStatus('weak')
end;