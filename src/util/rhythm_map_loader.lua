local MidiParser = require('class.ui.MidiParser')
local HitChart = require('class.ui.HitChart')
local parser = MidiParser()

---@param dir string
---@param t table
function loadRhythmMaps(dir, t)
	local items = love.filesystem.getDirectoryItems(dir)
	for _,item in ipairs(items) do
		local fp = dir .. "/" .. item
		local info = love.filesystem.getInfo(fp)

		if info.type == "file" then
	    local name = item:match("(.+)%..+$")
	    local ext  = item:match("^.+(%..+)$")

	    if name then
        t[name] = t[name] or {}

	    	if ext == ".wav" or ext == ".ogg" or ext == ".mp3" then
	        local src = love.audio.newSource(fp, "stream")
	        t[name].song = src
	      elseif ext == ".mid" then
	      	local midi = parser:parse(fp)
	      	local hitChart = HitChart(midi, 5) -- replace magic number later
	      	t[name].chart = hitChart
	      end
	    end
		elseif info.type == "directory" then
			t[item] = {}
			loadRhythmMaps(fp, t[item])
		end
	end
end;

return loadRhythmMaps