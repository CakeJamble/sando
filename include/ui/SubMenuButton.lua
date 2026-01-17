---@meta

---@alias ListOptions {container: {mode: string, x: integer, y: integer, width: integer, height: integer}, separator: {x1: integer, y1: integer, x2: integer, y2: integer}[]}
---@alias Preview {name: string, description: string, targetType: string}

---@class SubMenuButton: Button
---@field actionButton string
---@field actionList table[]
---@field displayList boolean
---@field numItemsInPreview integer
---@field listOptions ListOptions
---@field listUI Preview[]
---@field previewPos {x: integer, y: integer}
---@field previewOffset integer
---@field listIndex integer
---@field selectedAction table
---@field preview Preview
SubMenuButton = {}

---@param pos {x: integer, y: integer, scale: number}
---@param index integer
---@param path string
---@param actionButton string
---@param actionList table[]
function SubMenuButton:init(pos, index, path, actionButton, actionList) end

---@return ListOptions
function SubMenuButton:populateList() end

---@return Preview[]
function SubMenuButton:populatePreviews() end

function SubMenuButton:drawListUI() end

function SubMenuButton:drawElems() end

-- Should be refactored to return a list of strings instead of 1 big string
---@return string
function SubMenuButton:actionListToStr() end

function SubMenuButton:setDescription() end

---@param dt number
function SubMenuButton:update(dt) end

function SubMenuButton:draw() end