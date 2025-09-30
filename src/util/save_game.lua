local lume = require('libs.lume')

---@param team CharacterTeam
---@param act integer
---@param floor integer
---@param encounters table History of encounters (Combat, Event, Shop, etc.)
return function(team, act, floor, encounters)
	local data = {
		members = team.members,
		inventory = team.inventory,
		act = act,
		floor = floor,
		encounters = encounters
	}

	local serialized = lume.serialize(data)
	love.filesystem.write("savedata", serialized)
end;
