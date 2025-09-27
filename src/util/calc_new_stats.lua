return {
	Bake = {
		hp = function(level) return 20 + level*level end,
		fp = function(level) return 15 + level*level end,
		attack = function(level) return 5 + math.floor(level * 1.5) end,
		defense = function(level) return 3 + math.floor(level * 2) end,
		speed = function(level) return 10 + math.floor(level * 1.75) end,
		luck = function(level) return level + level end
	},
	Marco = {
		hp = function(level) return 18 + math.floor(level * 2.2) end,
		fp = function(level) return 15 + level*level end,
		attack = function(level) return 5 + math.floor(level^1.5 * 2.5) end,
		defense = function(level) return 3 + math.floor(math.sqrt(level) * 2) end,
		speed = function(level) return 10 + math.floor(level * 4) end,
		luck = function(level) return level + level end
	},
	Maria = {
		hp = function(level) return 20 + level*level end,
		fp = function(level) return 15 + level*level end,
		attack = function(level) return 5 + math.floor(level * 1.5) end,
		defense = function(level) return 3 + math.floor(level * 2) end,
		speed = function(level) return 10 + math.floor(level * 1.75) end,
		luck = function(level) return level + level end
	},
	Key = {
		hp = function(level) return 20 + level*level end,
		fp = function(level) return 15 + level*level end,
		attack = function(level) return 5 + math.floor(level * 1.5) end,
		defense = function(level) return 3 + math.floor(level * 2) end,
		speed = function(level) return 10 + math.floor(level * 1.75) end,
		luck = function(level) return level + level end
	}
}