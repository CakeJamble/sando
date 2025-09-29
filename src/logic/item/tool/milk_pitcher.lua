-- Signal: OnConsumableUse
---@param target? Entity
return function(target)
	target:raiseMaxHP(0.05)
end;