---@meta

---@class DialogManager
---@field pref string
---@field cache table
DialogManager = {}

function DialogManager:init() end

-- Returns text at key. Returns a random index if the key points to a table
---@param category string File name without extension
---@param key string Selection of text in file
---@return string
function DialogManager:getText(category, key) end

-- Returns table of texts at key. Raises an error when a table is not found
---@param category string File name without extensions
---@param key string selection of text in file
---@return string[]
function DialogManager:getTextTree(category, key) end

---@param category string File name without extension
---@return { [string]: string }
function DialogManager:getAll(category) end

---@param category string File name without extension
---@param key string Selection of text in file
---@return boolean
function DialogManager:exists(category, key) end

---@param category string
---@param allKeys? { [string]: string }
function DialogManager:getRandom(category, allKeys) end

---@param category string File name without extension
---@param key string Selection of text in file
---@param vars table k,v pairs for text strings to switch with vars in json (ex: {name="Marco"})
function DialogManager:getFormatted(category, key, vars) end

---@param category string File name without extension
function DialogManager:reload(category) end

function DialogManager:reloadAll() end