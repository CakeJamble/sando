local Class = require('libs.hump.class')

-- Manages sound effects and music for gamestates
	-- Other objects are responsible for their own sfx
---@class SoundManager
local SoundManager = Class{}

function SoundManager:init(state)
	local dir = 'asset/audio/' .. state
	self.sfx = {}
	self:loadSFX(dir)
	self.music = {}
end;

---@param dir string
function SoundManager:loadSFX(dir)
	local items = love.filesystem.getDirectoryItems(dir)

	for _,item in ipairs(items) do
		local fp = dir .. "/" .. item
		local info = love.filesystem.getInfo(fp)

		if info == "file" then
			local ext = item:match("^.+(%..+)$")
			local key = fp:gsub("%.%w+$", "")
			local src = love.audio.newSource(fp, "static")
			if not self.sfx[key] then self.sfx[key] =
			table.insert(self.sfx[key], src)
		elseif info == "directory" then
			self:loadSFX(fp)
		end
	end
end;

---@param dir string
function SoundManager.loadMusic(dir)
end;

return SoundManager