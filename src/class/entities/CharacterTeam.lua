local Team = require('class.entities.Team')
local Inventory = require('class.item.Inventory')
local Character = require('class.entities.Character')
local ActionUI = require('class.ui.ActionUI')
local Class = require('libs.hump.class')

---@type CharacterTeam
local CharacterTeam = Class{__includes = Team}

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

function CharacterTeam:distributeExperience(amount)
  for _,member in pairs(self.members) do
    if member:isAlive() then  member:gainExp(amount) end
  end
end;

function CharacterTeam:yieldCharacterSelect(opts)
  return coroutine.yield({
    routineType = "characterChoice",
    opts = opts or {}
  })
end;

function CharacterTeam:registerKO(koCharacters)
  for _,character in ipairs(koCharacters) do
    table.insert(self.koCharacters, character)
  end
end;

function CharacterTeam:rest()
  for _,character in ipairs(self.members) do
    local amount = math.floor(0.5 + character.baseStats.hp * 0.4)
    character:heal(amount)
    character:cleanse()
  end
end;

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