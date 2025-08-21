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

-- local Gear = require('class.item.gear')
local ToolManager = require('class.item.tool_manager')
-- local EquipManager = require('class.item.equip_manager')
-- local AccessoryManager = require('class.item.accessory_manager')

local Class = require 'libs.hump.class'
local Inventory = Class{
    cabinetPath = 'asset/sprites/pause/2cabinet.png',
    consumableMult = 1
}

function Inventory:init(characterTeam)
    self.gears = {}
    self.toolManager = ToolManager(characterTeam)
    -- self.equipManager = EquipManager(characterTeam)
    -- self.accessoryManager = AccessoryManager(characterTeam)
    self.consumables = {}
    self.numConsumableSlots = 3
    self.numEquipSlots = 2
    self.numAccessories = 2
    self.money = 0
    self.displaySellOption = false
    self.cabinetImage = love.graphics.newImage(Inventory.cabinetPath)

    local width,height = 640,360
    width,height = width * 0.8, height * 0.8
    self.window = {
        mode = 'line',
        x = 60, y = 20,
        width = width, height = height
    }
    self.textXStart = 60
    self.textOffset = 170
    self.cabinetRotate = math.pi/2
end

function Inventory:setMoney(amount)
    self.money = math.max(0, amount)

    -- then play animation or sound something (or in a purchase/sell fcn that calls this)
end;

--[[ Equips a piece of equipment to a character's equip slot.
If there is an equipment piece there, it will unequip it and return the gear
to the calling fcn. Otherwise returns nil if the equipSlot is nil.
note: equipSlot is an int for the index in character.equips to get the existing gear]]
function Inventory:equip(character, equipSlot, equipment) --> Gear or nil
    local replacedEquip = character.equips[equipSlot]
    character.equips[equipSlot] = equipment
    return replacedEquip
end;

function Inventory:addConsumable(item)
    if #self.consumables >= self.numConsumableSlots then
        return false
    else
        item.amount = item.amount * Inventory.consumableMult
        table.insert(self.consumables, item)
        return true
    end
end;

function Inventory:popConsumable(index)
    if #self.consumables == 0 then
        error('cannot pop off empty table')
    end
    return table.remove(self.consumables, index)
end;

function Inventory:addTool(tool)
    self.toolManager:addTool(tool)
end;

function Inventory:popTool(tool)
    return self.toolManager:popTool(tool)
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

function Inventory:sellGear(gear)
    --do
end;

function Inventory:drawUI()
    -- Menu Container
    love.graphics.rectangle(self.window.mode, self.window.x, self.window.y, self.window.width, self.window.height)

    -- 1. team cabinet
    love.graphics.draw(self.cabinetImage, self.window.x + 150, 50, self.cabinetRotate, 3.5, 4)
    love.graphics.print("Team", self.window.x + 60, 30)
    -- 2. tools cabinet
    love.graphics.draw(self.cabinetImage, self.window.x + 320, 50, self.cabinetRotate, 3.5, 4)
    love.graphics.print('Tools', self.window.x + 230, 30)
    -- 3. settings cabinet
    love.graphics.draw(self.cabinetImage, self.window.x + 500, 50, self.cabinetRotate, 3.5, 4)
    love.graphics.print('Settings', self.window.x + 400, 30)

end;
--[[
    Draws own menu, and containers for each part of inventory
]]
function Inventory:draw()
    self:drawUI()
    for character,gear in pairs(self.gears) do
        -- TODO: want to draw sprite only, not current animation state in draw()
        character:draw()
        gear:draw()
    end
end;

return Inventory