local proc = {
	equip = function(character)
		character.landingLagMods["designer_loafers"] = 0.5
	end,
	unequip = function(character)
		character.landingLag["designer_loafers"] = nil
	end
}

return proc