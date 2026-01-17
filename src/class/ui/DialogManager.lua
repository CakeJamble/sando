local json = require('libs.json')
local Class = require('libs.hump.class')

---@type DialogManager
local DialogManager = Class{}

function DialogManager:init()
	self.pref = "data/dialog/"
	self.cache = {}
end;

function DialogManager:getText(category, key)
	if not self.cache[category] then
		local path = self.pref .. category .. ".json"
		local file = love.filesystem.read(path)
		self.cache[category] = json.decode(file)
	end

	if type(self.cache[category][key]) == "table" then
		local i = love.math.random(1, #self.cache[category][key])
		return self.cache[category][key][i]
	else
		return self.cache[category][key]
	end
end;

function DialogManager:getTextTree(category, key)
	if not self.cache[category] then
		local path = self.pref .. category .. ".json"
		local file = love.filesystem.read(path)
		self.cache[category] = json.decode(file)
	end

	if type(self.cache[category][key]) ~= "table" then
		local typeFound = type(self.cache[category][key])
		local message = "At self.cache." .. category .. '.' .. key
			.. ", found a" .. typeFound .. ", but expected a table of strings"

		error(message)
	end

	return self.cache[category][key]
end;

function DialogManager:getAll(category)
	if not self.cache[category] then
		local path = self.pref .. category .. ".json"
		print(path)
		local file = love.filesystem.read(path)
		self.cache[category] = json.decode(file)
	end
	return self.cache[category]
end;

function DialogManager:exists(category, key)
	return self.cache[category] and self.cache[category][key] ~= nil
end;

function DialogManager:getRandom(category, allKeys)
	local list = self.cache[category]
	local choices = allKeys or list
	local keys = {}

	for k in pairs(choices) do table.insert(keys, k) end
	local i = love.math.random(#keys)
	local result = choices[keys[i]]
	
	return result
end;

function DialogManager:getFormatted(category, key, vars)
	local text = self:getText(category, key)
	return (text:gsub("{(.-)}", vars))
end;

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