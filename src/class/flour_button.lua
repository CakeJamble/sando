--! filename: flour button
require('class.button')
Class = require 'libs.hump.class'
FlourButton = Class{__includes = Button}

function FlourButton:init(x, y, currentFP, skillList)
    Button:init(x, y, Button.BUTTON_PATH .. 'flour.png')
    self.skillList = skillList
    self.currentFP = currentFP
    -- self.skillListHolder = love.graphics.newImage(path/to/image)
    -- self.skillListCursor = love.graphics.newImage(path/to/image)
    self.selectedSkill = nil
end;

function FlourButton:formatSkillList() --> string
    result = ''
    -- TODO
    return result
end;

function FlourButton:keypressed(key)
    -- TODO
end;

function FlourButton:update(dt)
    Button:update(dt)
end;

function FlourButton:draw()
    Button:draw()
    -- TODO : draw the skill list & cursor
end;