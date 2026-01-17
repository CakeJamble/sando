---@meta

---@class ItemButton: SubMenuButton
---@field description string
ItemButton = {}

---@param pos { [string]: number }
---@param index integer
---@param itemList table[]
---@param actionButton string
function ItemButton:init(pos, index, itemList, actionButton) end

---@param dt number
function ItemButton:update(dt) end