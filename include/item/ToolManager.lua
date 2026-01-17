---@meta

--[[Some technical debt here.
Decided not to refactor for inheritence with Acc Manager to save time.
Should definitely come back and do that, and make a generic ItemManager class instead.]]
---@class ToolManager
---@field characterTeam CharacterTeam
---@field tools { [string]: table }
---@field indices { [string]: integer }
---@field signalHandlers table
ToolManager = {}

---@param characterTeam CharacterTeam
function ToolManager:init(characterTeam) end

---@param tool table
function ToolManager:addItem(tool) end

---@param tool table
---@return table
function ToolManager:popItem(tool) end

--[[ Defines all the different names of signals that a tool can emit.
This essentially translates into the different tool "types" in the game.]]
---@return { [string]: table}
function ToolManager.initToolLists() end

---@param tools { [string]: table }
---@return { [string]: integer }
function ToolManager.initIndices(tools) end

---@param name string
---@param f fun(...)
function ToolManager:registerSignal(name, f) end

-- Registers all the different signals this class needs to respond to
function ToolManager:registerSignals() end