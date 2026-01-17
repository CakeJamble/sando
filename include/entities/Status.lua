---@meta

---@class Status
---@field name "burn"|"poison"|"paralyze"|"lactose"|"sleep"
---@field apply function? Initial effect of being afflicted with the status
---@field tick function? Effect of status existing at the beginning of a turn
---@field sleepCounter? integer Number of turns consecutively slept
Status = {}

---@param name string
---@param params {apply: function?, tick: function?, sleepCounter: integer?}
function Status:init(name, params) end