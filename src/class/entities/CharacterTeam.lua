--! filename: character team
local Team = require('class.entities.Team')
local Inventory = require('class.item.Inventory')
local Character = require('class.entities.Character')
local ActionUI = require('class.ui.ActionUI')
local Class = require('libs.hump.class')

---@class CharacterTeam: Team
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

---@param amount integer
function CharacterTeam:distributeExperience(amount)
  for _,member in pairs(self.members) do
    if member:isAlive() then  member:gainExp(amount) end
  end
end;

---@param opts? table Optional arguments for excluding selection
---@return any
function CharacterTeam:yieldCharacterSelect(opts)
  return coroutine.yield({
    routineType = "characterChoice",
    opts = opts or {}
  })
end;

---@deprecated Use update with baton to handle inputs
---@param key string
function CharacterTeam:keypressed(key)
  for _,member in pairs(self.members) do
    member:keypressed(key)
  end
end;

---@deprecated Use update with baton to handle inputs
---@param joystick love.Joystick
---@param button love.GamepadButton
function CharacterTeam:gamepadpressed(joystick, button)
  for _,member in pairs(self.members) do
    member:gamepadpressed(joystick, button)
  end
end;

---@deprecated Use update with baton to handle inputs
---@param joystick love.Joystick
---@param button love.GamepadButton
function CharacterTeam:gamepadreleased(joystick, button)
  for _,member in ipairs(self.members) do
    member:gamepadreleased(joystick, button)
  end
end;

---@param koCharacters Character[]
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


return CharacterTeam