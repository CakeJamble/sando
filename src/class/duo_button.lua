--! filename: dup button
require('class.button')
Class = require('libs.hump.class')
DuoButton = Class{__includes = Button}

function DuoButton:init(x, y, layer, skillList)
    Button.init(self, x, y, layer, 'duo_lame.png')
    self.skillList = skillList
    -- self.skillListHolder = love.graphics.newImage(path/to/image)
    -- self.skillListCursor = love.graphics.newImage(path/to/image)
    self.selectedSkill = nil
    self.displaySkillList = false
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
    Button.update(self, dt)
end;

function DuoButton:draw()
    Button.draw(self)
    -- TODO : draw the skill list & cursor
end;