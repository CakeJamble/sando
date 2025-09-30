local Signal = require('libs.hump.signal')

-- Signal: OnPickup
return function(_)
	Signal.register('OnStartNext3Combats', function(counter, enemyTeam)
		if counter <= 3 then
			for _,enemy in ipairs(enemyTeam.members) do
				enemy.baseStats.hp = 1
			end
		end
	end)
end;