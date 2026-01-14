local flux = require('libs.flux')

---@param ref Character
---@param qteManager QTEManager
return function(ref, qteManager)
	local attack = ref.actor:getAnimation("swing_attack")
	attack:onAnimOver(function()
		-- go back (jump or dash)
		-- switch back to idle
		ref.actor:switch('idle')
		-- end turn
	end)
end;