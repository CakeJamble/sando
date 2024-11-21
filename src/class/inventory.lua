--! filename: inventory
--[[
    Inventory class
    Used in the pause gamestate menu to display inventory,
    and to equip and unequip gear.
]]

require('class.gear')

Class = require 'libs.hump.class'
Inventory = Class{}

function Inventory:init(members)
    self.gears = {} -- Character and Gear
end

function Inventory:equip(character, equip) --> number
    local profit = 0
    for _,g in pairs(self.gears) do
        if g['name'] == equip['name'] and g['gearType'] == equip['gearType'] then
            print('Gear or Gear Type already in inventory')
            -- TODO: option to replace and sell old gear
            -- profit = g['value']
        end
    end
    
    character:equip(equip)
    table.insert(self.gears[character:getEntityName()], equip)
    
    print('Added ' .. equip['name'] .. ' to inventory')
    return profit
end;

function Inventory:unequip(character, equip) --> number
    local value = 0
    for _,g in pairs(self.gears) do
        if g['name'] == equip['name'] then
            character:unequip(g)
            print('Sold ' .. equip['name'] .. ' from inventory')
            print('Profit: ' .. g['value'])
            value = g['value']
        end
    end
    return value
end;

function Inventory:getGears()
    return self.gears
end;

function Inventory:draw()
    for character,gear in pairs(self.gears) do
        -- TODO: want to draw sprite only, not current animation state in draw()
        character:draw()
        gear:draw()
    end
end