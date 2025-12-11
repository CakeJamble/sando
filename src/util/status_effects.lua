local Effects = {}

Effects.burn = {
	---@param statMods table
	---@return string, integer
	apply = function(statMods)
		return "attack", statMods.attack - 0.5
	end,
	---@param maxHP integer
	---@return number newHP
	tick = function(maxHP)
		local damage = math.floor(maxHP * 0.08)
		return damage
	end,
	resist = 0
}

Effects.poison = {
	apply = nil,
	---@param maxHP integer
	---@return integer
	tick = function(maxHP)
		local damage = math.ceil(maxHP * 0.08)
		return damage
	end
}

Effects.paralyze = {
	---@param statMods table
	---@return string, number
	apply = function(statMods)
		return "speed", statMods.speed - 0.5
	end,
	---@return boolean true for Full Paralysis
	tick = function()
		return love.math.random() >= 0.6
	end
}

Effects.lactose = {
	---@param statMods table
	---@return string, number
	apply = function(statMods)
		return "defense", statMods.defense - 0.25
	end,
	tick = nil
}

Effects.sleep = {
	apply = nil,
	---@param sleepCounter integer Number of consecutive turns slept
	---@return boolean, integer
	tick = function(sleepCounter)
		if sleepCounter > 2 or love.math.random() >= 0.5 then
			return true, 0
		else
			return false, sleepCounter + 1
		end
	end,
	sleepCounter = 0
}

return Effects