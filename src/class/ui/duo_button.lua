--! filename: dup button
require('class.ui.button')
Class = require('libs.hump.class')
DuoButton = Class{__includes = Button}

function DuoButton:init(pos, index, skillList)
    Button.init(self, pos, index, 'duo_lame.png')
    self.skillList = skillList
    -- self.skillListHolder = love.graphics.newImage(path/to/image)
    -- self.skillListCursor = love.graphics.newImage(path/to/image)
    self.selectedSkill = nil
    self.displaySkillList = false
    self.description = 'Consume BP to use a powerful teamup skill'
end;

function DuoButton:formatSkillList() --> string
    result = ''
    -- TODO
    return result
end;

function DuoButton:keypressed(key)
    -- TODO
end;

function DuoButton:draw()
    Button.draw(self)
    -- TODO : draw the skill list & cursor
end;