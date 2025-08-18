--! filename: character team
local Team = require('class.entities.team')
local Inventory = require('class.item.inventory')
local Character = require('class.entities.character')
local ActionUI = require('class.ui.action_ui')
local Class = require('libs.hump.class')


-- testing functionality of different items (REMOVE LATER)
local loadItem = require 'util.item_loader'
local loadTool = require('util.tool_loader')
local espresso = loadItem('espresso')
-- local halfMuffin = loadTool('half_muffin')
-- local energyDrink = loadTool('energy_drink')
local waterBottle = loadTool('water_bottle')

local CharacterTeam = Class{__includes = Team}

function CharacterTeam:init(characters)
    Team.init(self, characters)


    self.koCharacters = {}
    self.inventory = Inventory(self)

    Character.inventory = self.inventory
    ActionUI.consumables = self.inventory.consumables

    -- Adding items for testing
    self.inventory:addConsumable(espresso)
    -- self.inventory:addTool(halfMuffin)
    self.inventory:addTool(waterBottle)
end;

function CharacterTeam:distributeExperience(amount)
  for _,member in pairs(self.members) do
    if member:isAlive() then  member:gainExp(amount) end
  end
end;

function CharacterTeam:increaseMoney(amount)
  self.money = self.money + amount
end;

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

function CharacterTeam:gamepadpressed(joystick, button)
  for _,member in pairs(self.members) do
    member:gamepadpressed(joystick, button)
  end
end;

function CharacterTeam:gamepadreleased(joystick, button)
  for _,member in ipairs(self.members) do
    member:gamepadreleased(joystick, button)
  end
end;

function CharacterTeam:registerKO(koCharacters)
  for _,character in ipairs(koCharacters) do
    table.insert(self.koCharacters, character)
  end
end;

return CharacterTeam