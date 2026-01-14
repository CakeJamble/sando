local Team = require('class.entities.Team')
local Inventory = require('class.item.Inventory')
local Character = require('class.entities.Character')
local ActionUI = require('class.ui.ActionUI')
local Class = require('libs.hump.class')

---@class CharacterTeam: Team
---@field rarityMod number Percentage added to weighted distributions of rarity events
---@field discount number Percentage off for price of items during transactions
---@field koCharacters Character[]
---@field inventory Inventory
---@field usingFirstConsumable boolean
---@field koGetsExp boolean
local CharacterTeam = Class{__includes = Team}

---@param characters Character[]
---@param inventory? Inventory
function CharacterTeam:init(characters, inventory)
  Team.init(self, characters)
  self.rarityMod = 0
  self.discount = 0

  self.koCharacters = {}
  self.inventory = inventory or Inventory(self)

  Character.inventory = self.inventory
  ActionUI.consumables = self.inventory.consumables
  self.usingFirstConsumable = true

  self.koGetsExp = false

  -- Adding items for testing
  -- self.inventory:addConsumable(espresso)
end;

-- Distributes Exp to all Characters that are not KO'd.
---@param amount integer
function CharacterTeam:distributeExperience(amount)
  for _,member in pairs(self.members) do
    if member:isAlive() then  member:gainExp(amount) end
  end
end;

-- WIP for character select interaction with a tool
---@param opts? table Optional arguments for excluding selection
---@return any
function CharacterTeam:yieldCharacterSelect(opts)
  return coroutine.yield({
    routineType = "characterChoice",
    opts = opts or {}
  })
end;

-- Adds a Character to `self.koCharacters`
---@param koCharacters Character[]
function CharacterTeam:registerKO(koCharacters)
  for _,character in ipairs(koCharacters) do
    table.insert(self.koCharacters, character)
  end
end;

-- Restores 40% of HP to each Character, rounding up. Also heals KO'd members
function CharacterTeam:rest()
  for _,character in ipairs(self.members) do
    local amount = math.floor(0.5 + character.baseStats.hp * 0.4)
    character:heal(amount)
    character:cleanse()
  end
end;

-- WIP for saving/loading
function CharacterTeam:serialize()
  local teamData = {
    members = {}, 
    inventory = self.inventory:serialize()
  }
  for _,member in ipairs(self.members) do
    local memberData = member:serialize()
    table.insert(teamData.members, memberData)
  end

  return teamData
end;


return CharacterTeam