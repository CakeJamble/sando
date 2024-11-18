--! filename: dup button
require('class.button')
Class = require('libs.hump.class')
DuoButton = Class{__includes = Button}

function DuoButton:init(x, y, currentDP, skillList)
    Button.init(self, x, y, Button.BUTTON_PATH .. 'duo.png')
    self.skillList = skillList
    self.currentDP = currentDP
    -- self.skillListHolder = love.graphics.newImage(path/to/image)
    -- self.skillListCursor = love.graphics.newImage(path/to/image)
    self.selectedSkill = nil
end;

function DuoButton:formatSkillList() --> string
    result = ''
    -- TODO
    return result
end;

function DuoButton:keypressed(key)
    -- TODO
end;

function DuoButton:update(dt)
    Button:update(dt)
end;

function DuoButton:draw()
    Button:draw()
    -- TODO : draw the skill list & cursor
end;