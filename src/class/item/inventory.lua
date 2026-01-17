local ToolManager = require('class.item.ToolManager')
local EquipManager = require('class.item.EquipManager')
local AccessoryManager = require('class.item.AccessoryManager')

local Class = require 'libs.hump.class'

---@type Inventory
local Inventory = Class{
    cabinetPath = 'asset/sprites/pause/2cabinet.png',
    consumableMult = 1
}

---@param characterTeam CharacterTeam
function Inventory:init(characterTeam)
    self.gears = {}
    self.toolManager = ToolManager(characterTeam)
    self.equipManager = EquipManager(characterTeam)
    self.accessoryManager = AccessoryManager(characterTeam)
    self.consumables = {}
    self.numConsumableSlots = 3
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

function Inventory:gainMoney(amount)
    self.money = self.money + amount

    -- tween UI
    -- play sfx
end;

function Inventory:loseMoney(amount)
    self.money = math.max(0, self.money - amount)
    -- tween UI
    -- play sfx
end;

function Inventory:addItem(item, itemType)
    if itemType == "tool" then
        self.toolManager:addItem(item)
    elseif itemType == "equip" then
        self.equipManager:addItem(item)
    elseif itemType == "accessory" then
        self.accessoryManager:addItem(item)
    else
        self:addConsumable(item)
    end
end;

function Inventory:popItem(item, itemType)
    local item = {}
    if itemType == "tool" then
        item = self.toolManager:popItem(item)
    elseif itemType == "equip" then
        item = self.equipManager:addItem(item)
    elseif itemType == "accessory" then
        item = self.accessoryManager:addItem(item)
    -- else
        -- item = self:popConsumable(item)
    end

    return item
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

function Inventory:draw()
    self:drawUI()
    for character,gear in pairs(self.gears) do
        -- TODO: want to draw sprite only, not current animation state in draw()
        character:draw()
        gear:draw()
    end
end;

return Inventory