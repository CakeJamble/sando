--! filename: inventory
--[[
    Inventory class
    Used in the pause gamestate menu to display inventory,
    and to equip and unequip gear. When gear is equipped,
    the Inventory class will keep track of the character who is
    using the Gear, and it will apply/remove effects of gear, consumables,
    etc. when they are used/equipped/unequipped. The character won't have
    to manage that functionality.
]]

require('class.item.gear')

Class = require 'libs.hump.class'
Inventory = Class{}

function Inventory:init(members)
    self.gears = {} -- Character and Gear
    self.tools = {}
    self.consumables = {}
    self.numConsumableSlots = 3
    self.numEquipSlots = 2
    self.numAccessories = 2
    self.money = {}
    self.displaySellOption = false
end

--[[ Equips a piece of equipment to a character's equip slot.
If there is an equipment piece there, it will unequip it and return the gear
to the calling fcn. Otherwise returns nil if the equipSlot is nil. 
note: equipSlot is an int for the index in character.equips to get the existing gear]]
function Inventory:equip(character, equipSlot, equipment) --> Gear or nil
    local replacedEquip = character.equips[equipSlot]
    character.equips[equipSlot] = equipment
    return replacedEquip
end;

--[[ Given an item that has been unequipped, returns the value of that item if 
the character argument is nil. If not, then asks the user to decide whether or not
to equip it to that character. If not, then returns the value.]]
function Inventory:unequip(equipment, character) --> number
    local value = 0
    if equipment ~= nil then
        value = equipment.value
    end
    self.displaySellOption = true
    return value
end;

function Inventory:getGears()
    return self.gears
end;

-- function Inventory:sellGear(gear)

function Inventory:draw()
    for character,gear in pairs(self.gears) do
        -- TODO: want to draw sprite only, not current animation state in draw()
        character:draw()
        gear:draw()
    end
end;