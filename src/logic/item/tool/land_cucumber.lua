-- Signal: OnFaint
---@param enemy Enemy
---@param koCharacters Character[]
return function(enemy, koCharacters)
	for _,character in ipairs(koCharacters) do
		local amount = enemy.skill.damage
		enemy:takeDamagePierce(amount)
	end
end;