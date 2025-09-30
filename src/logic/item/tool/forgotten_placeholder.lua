-- Signal: OnEscape
---@param enemy Enemy
return function(enemy)
	enemy:applyStatus('vulnerable')
end