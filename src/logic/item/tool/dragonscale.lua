return function(character, amount)
	amount = math.floor(0.5 + (amount / 4))
	character:heal(amount)
end;