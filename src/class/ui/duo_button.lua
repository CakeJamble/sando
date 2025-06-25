--! filename: dup button
require('class.ui.button')
Class = require('libs.hump.class')
DuoButton = Class{__includes = Button}

function DuoButton:init(x, y, layer, skillList)
    Button.init(self, x, y, layer, 'duo_lame.png')
    self.skillList = skillList
    -- self.skillListHolder = love.graphics.newImage(path/to/image)
    -- self.skillListCursor = love.graphics.newImage(path/to/image)
    self.selectedSkill = nil
    self.displaySkillList = false
    self.description = 'Consume BP to use a powerful teamup skill'
    
  Signal.register('SpinUIWheelLeft', 
    function(before, x)
      if before == 'fsd' then -- after == {left:solo, center:duo, right:flour}
        self.active = true
        self.layer = 2
        self.tX = x
        self.dX = Button.BASE_DX

      elseif before == 'dfs' then -- result: {left:flour, center:solo, right:duo} 
        self.active = false
        self.layer = 3
        self.tX = x + Button.SPACER
        self.dX = Button.BASE_DX * 2

      elseif before == 'sdf' then -- result: {left: duo, center: flour, right: solo}
        self.active = false
        self.layer = 1
        self.tX = x - Button.SPACER
        self.dX = Button.BASE_DX

      end
    end
  );
  
  Signal.register('SpinUIWheelRight',
    function(before, x)
      if before == 'fsd' then -- result: {left: duo, center: flour, right: solo}
        self.active = false
        self.layer = 1
        self.tX = x - Button.SPACER
        self.dX = Button.BASE_DX * 2

      elseif before == 'dfs' then -- result: {left: solo, center: duo, right: flour}
        self.active = true
        self.layer = 1
        self.tX = x
        self.dX = Button.BASE_DX

      elseif before == 'sdf' then -- result: {left: flour, center: solo, right: duo}
        self.active = false
        self.layer = 1
        self.tX = x + Button.SPACER
        self.dX = Button.BASE_DX

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

function DuoButton:draw()
    Button.draw(self)
    -- TODO : draw the skill list & cursor
end;