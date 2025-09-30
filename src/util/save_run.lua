local lume = require('libs.lume')

---@param previous table Previous gamestate
---@param team CharacterTeam
---@param act integer
---@param floor integer
---@param encounters table History of encounters (Combat, Event, Shop, etc.)
return function(previous, team, act, floor, encounters)
	local data = {
		previous = previous,
		members = team.members,
		inventory = team.inventory,
		act = act,
		floor = floor,
		encounters = encounters
	}

	local serialized = lume.serialize(data)
	love.filesystem.write("run_savedata", serialized)
end;
