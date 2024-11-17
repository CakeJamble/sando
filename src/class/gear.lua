--! filename: gear
require("class.equip")
local class = require 'libs/middleclass'
Gear = class('Gear')

function Gear:initialize()
    self.equips = {}        -- 1 accessory, 1 equipment
    self.equipOffset = 40   -- pixels between equips
    self.hasEquip = false
    self.hasAccessory = false
end;

function Gear:equip(equip)
-- Check if equip type is already in equips list
    if equip['equipType'] == 'accessory' then
        if self.hasAccessory then
            print('You already have an accessory')
        else
            table.insert(self.equips, equip)
            self.hasAccessory = true
        end
    elseif self.hasEquip then
            print('You already have an equipment')
    else
        table.insert(self.equips, equip)
        self.hasEquip = true
    end
end;

function Gear:unequip(equip)
    for i,e in pairs(self.equips) do
        if e['name'] == equip['name'] then
            table.remove(self.equips, i)
            if e['type'] == 'accessory' then
                self.hasAccessory = false
            else
                self.hasEquip = false
            end
        end
    end
end;

function Gear:getEquip(equipName) --> Equip
    for _,equip in pairs(self.equips) do
        if equip['name'] == equipName then
            return equip
        end
    end
end;

function Gear:getEquips()
    return self.equips
end;

function Gear:draw()
    for _,equip in pairs(self.equips) do
        equip:draw()
    end
end;