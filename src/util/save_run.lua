local bitser = require('libs.bitser')

---@param gamestate string Previous gamestate
---@param act integer
---@param floor integer
---@param encounters table History of encounters (Combat, Event, Shop, etc.)
---@param seed integer
return function(gamestate,  act, floor, encounters, seed)
	local data = {
		message = "Hello, World", 
		gamestate = gamestate,
		act = act,
		floor = floor,
		seed = seed,
	}

	bitser.dumpLoveFile('save.dat', data)
end;