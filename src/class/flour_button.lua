--! filename: flour button
require('class.button')
Class = require 'libs.hump.class'
FlourButton = Class{__includes = Button}

function FlourButton:init(x, y, layer, skillList)
  Button.init(self, x, y, layer, 'flour.png')
  self.skillList = skillList
  self.skillListString = FlourButton.skillListToStr(self)
  self.skillIndex = 1
  -- self.skillListHolder = love.graphics.newImage(path/to/image)
  -- self.skillListCursor = love.graphics.newImage(path/to/image)
  self.selectedSkill = nil
  self.displaySkillList = false
  self.skillPreview = skillList[1].description
  self.pickableSkillIndices = {}
  for i=1,#self.skillList do
    self.pickableSkillIndices[i] = false
  end
    
  Signal.register('SpinUIWheelLeft', 
    function(before, x)
      if before == 'fsd' then -- after == {left:solo, center:duo, right:flour}
        self.active = false
        self.layer = 3
        Button:setTargetPos(x + Button.SPACER, 2)
        self.isRotatingRight = true
        self.isRotatingLeft = false
      elseif before == 'dfs' then -- result: {left:flour, center:solo, right:duo} 
        self.active = false
        self.layer = 3
        Button:setTargetPos(x - Button.SPACER, 1)
        self.isRotatingRight = false
        self.isRotatingLeft = true
      elseif before == 'sdf' then -- result: {left: duo, center: flour, right: solo}
        self.active = true
        self.layer = 1
        Button:setTargetPos(x, 1)
        self.isRotatingRight = false
        self.isRotatingLeft = true
      end
    end
  );
  
  Signal.register('SpinUIWheelRight',
    function(before, x)
      if before == 'fsd' then -- result: {left: duo, center: flour, right: solo}
        print('flour button settting position')

        self.active = true
        self.layer = 1
        Button:setTargetPos(x, 1)
        self.isRotatingRight = true
        self.isRotatingLeft = false
      elseif before == 'dfs' then -- result: {left: solo, center: duo, right: flour}
        self.active = false
        self.layer = 1
        Button:setTargetPos(x + Button.SPACER, 1)
        self.isRotatingRight = true
        self.isRotatingLeft = false
      elseif before == 'sdf' then -- result: {left: flour, center: solo, right: duo}
        self.active = false
        self.layer = 3
        Button:setTargetPos(x - Button.SPACER, 2)
        self.isRotatingRight = false
        self.isRotatingLeft = true
      end
    end
    );
    
end;

function FlourButton:skillListToStr()
  local result = ''
  for i=1,#self.skillList do
    result = result .. self.skillList[i].skill['skill_name'] .. self.skillList[i].skill['cost'] .. '\n'
  end
  return result
end;

function FlourButton:setSkillPreview()
  self.skillPreview = self.skillList[self.skillIndex].description
end;

function FlourButton:validateSkillCosts(currentFP)
  for i=1,#self.skillList do
    self.pickableSkillIndices[i] = (self.skillList[i].cost < currentFP)
  end
end;

function FlourButton:keypressed(key)
  if key == 'down' then
    self.skillIndex = math.max(1, (self.skillIndex + 1) % #self.skillList)
  elseif key == 'up' then
    if self.skillIndex > 1 then self.skillIndex = self.skillIndex - 1 else self.skillIndex = #self.skillList end
  elseif key == 'z' then
    if self.pickableSkillIndices then
      -- TODO: Switch to active state with Character:offenseState
    else
      -- show some message that you don't have enough FP
      print('error - cost exceeds fp')  -- STUB
    end
  end
end;

function FlourButton:draw()
  Button.draw(self)
  if self.isActiveButton and self.displaySkillList then
    for i=1,#self.skillList do
      if self.pickableSkillLists[i] then
        -- Print skill as usual
        love.graphics.print(self.skillString, self.x, self.y + i * self.textOffset)
      else
        -- Print skill with a disabled text font (TODO)
        love.graphics.print(self.skillString, self.x, self.y + i * self.textOffset)
      end
    end
    
    -- draw cursor @ offset based on position & self.skillIndex
  end
end;