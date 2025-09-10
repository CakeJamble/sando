local json = require('libs.json')

---@return table Item file names for each item type and rarity
local function initItemPool()
  local pref = "data/item/"
  local pools = {
    "common", "uncommon", "rare",
    "shop", "event"
  }
  local itemTypes = {"accessory", "consumable", "equip", "tool"}
  local result = {}
  for _,itemType in ipairs(itemTypes) do
    result[itemType] = {}

    for _,pool in ipairs(pools) do
      local path = pref .. itemType .. "/" .. pool .. "_pool.json"
      local raw = love.filesystem.read(path)
      local data = json.decode(raw)

      result[itemType][pool] = data
    end
  end

  return result
end;

return initItemPool