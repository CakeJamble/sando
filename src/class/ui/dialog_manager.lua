local json = require('libs.json')
local Class = require('libs.hump.class')

---@class DialogManager
local DialogManager = Class{}

function DialogManager:init()
	self.pref = "data/dialog/"
	self.cache = {}
end;

---@param category string File name without extension
---@param key string Selection of text in file
---@return string
function DialogManager:getText(category, key)
	if not self.cache[category] then
		local path = self.pref .. category .. ".json"
		local file = love.filesystem.read(path)
		self.cache[category] = json.decode(file)
	end
	return self.cache[category][key]
end;

---@param category string File name without extension
---@return { [string]: string }
function DialogManager:getAll(category)
	if not self.cache[category] then
		local path = self.pref .. category .. ".json"
		print(path)
		local file = love.filesystem.read(path)
		self.cache[category] = json.decode(file)
	end
	return self.cache[category]
end;

---@param category string File name without extension
---@param key string Selection of text in file
---@return boolean
function DialogManager:exists(category, key)
	return self.cache[category] and self.cache[category][key] ~= nil
end;

---@param category string
---@param allKeys? { [string]: string }
function DialogManager:getRandom(category, allKeys)
	local list = self.cache[category]
	local choices = allKeys or list
	local keys = {}

	for k in pairs(choices) do table.insert(keys, k) end
	local i = love.math.random(#keys)
	local result = choices[keys[i]]
	
	return result
end;

---@param category string File name without extension
---@param key string Selection of text in file
---@param vars table k,v pairs for text strings to switch with vars in json (ex: {name="Marco"})
function DialogManager:getFormatted(category, key, vars)
	local text = self:getText(category, key)
	return (text:gsub("{(.-)}", vars))
end;

---@param category string File name without extension
function DialogManager:reload(category)
	self.cache[category] = nil
	self:getAll(category)
end;

function DialogManager:reloadAll()
	for cat,_ in pairs(self.cache) do
		self.cache[cat] = self:getAll(cat)
	end
end;

return DialogManager