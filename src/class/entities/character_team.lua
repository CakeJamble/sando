--! filename: character team
local Team = require('class.entities.team')
local Inventory = require('class.item.inventory')
local Character = require('class.entities.character')
local ActionUI = require('class.ui.action_ui')
local Class = require('libs.hump.class')


-- testing functionality of different items (REMOVE LATER)
local loadItem = require 'util.item_loader'
local espresso = loadItem('espresso', 'consumable')

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
  self.inventory:addConsumable(espresso)
end;

---@param amount integer
function CharacterTeam:distributeExperience(amount)
  for _,member in pairs(self.members) do
    if member:isAlive() then  member:gainExp(amount) end
  end
end;

---@param amount integer
function CharacterTeam:increaseMoney(amount)
  self.money = self.money + amount
end;

---@param opts? table Optional arguments for excluding selection
---@return any
function CharacterTeam:yieldCharacterSelect(opts)
  return coroutine.yield({
    routineType = "characterChoice",
    opts = opts or {}
  })
end;

---@param incomingSkill table
---@deprecated
function CharacterTeam:startDefense(incomingSkill)
  for _,character in pairs(self.members) do
    if character:isAlive() then
      character.defenseState:setup(incomingSkill)
    end
  end
end;

function CharacterTeam:keypressed(key)
  for _,member in pairs(self.members) do
    member:keypressed(key)
  end
end;

---@param joystick love.Joystick
---@param button love.GamepadButton
function CharacterTeam:gamepadpressed(joystick, button)
  for _,member in pairs(self.members) do
    member:gamepadpressed(joystick, button)
  end
end;

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