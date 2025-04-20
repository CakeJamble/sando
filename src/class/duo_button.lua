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
    
  Signal.register('SpinUIWheelLeft', 
    function(before, x)
      if before == {'flour', 'solo', 'duo'} then -- after == {left:solo, center:duo, right:flour}
        self.active = true
        self.layer = 2
        Button:setTargetPos(x, 1)
      elseif before == {'duo', 'flour', 'solo'} then -- result: {left:flour, center:solo, right:duo} 
        self.active = false
        self.layer = 3
        Button:setTargetPos(x + Button.SPACER, 2)
      elseif before == {'solo', 'duo', 'flour'} then -- result: {left: duo, center: flour, right: solo}
        self.active = false
        self.layer = 1,
        Button:setTargetPos(x - Button.SPACER, 1)
      end
    end
  );
  
  Signal.register('SpinUIWheelRight',
    function(before, x)
      if before == {'flour', 'solo', 'duo'} then -- result: {left: duo, center: flour, right: solo}
        self.active = false
        self.layer = 1
        Button:setTargetPos(x - Button.SPACER, 2)
      elseif before == {'duo', 'flour', 'solo'} then -- result: {left: solo, center: duo, right: flour}
        self.active = true
        self.layer = 1
        Button:setTargetPos(x, 1)
      elseif before == {'solo', 'duo', 'flour'} then -- result: {left: flour, center: solo, right: duo}
        self.active = false
        self.layer = 1
        Button:setTargetPos(x + Button.SPACER, 1)
      end
    end
    );
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