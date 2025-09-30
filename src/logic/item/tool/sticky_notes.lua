-- Signal: OnFaint
---@param enemy Enemy
return function(enemy)
	if not enemy.target:isAlive() then
		for stat,_ in pairs(enemy.battleStats) do
			if stat ~= 'hp' and stat ~= 'fp' then
				enemy:modifyBattleStat(stat, -1)
			end
		end
	end
end;