--! filename: button

require('class.button')

Class = require 'libs.hump.class'
SoloButton = Class{__includes = Button}

function SoloButton:init(x, y, layer, basicAttack)
  Button.init(self, x, y, layer, 'solo_lame.png')
  self.basicAttack = basicAttack
  self.scaleFactor = 1
  self.active = false
  
  Signal.register('SpinUIWheelLeft', 
    function(before, x)
      if before == 'fsd' then -- result: {left:solo, center:duo, right:flour}
        self.active = false
        self.layer = 1
        self.setTargetPos(self, x - Button.SPACER, 1)
        self.isRotatingRight = false
        self.isRotatingLeft = true
      elseif before == 'dfs' then -- result: {left:flour, center:solo, right:duo} 
        self.active = true
        self.layer = 1
        Button:setTargetPos(x, 1)
        self.isRotatingRight = false
        self.isRotatingLeft = true
      elseif before == 'sdf' then -- result: {left: duo, center: flour, right: solo}
        self.active = false
        self.layer = 3
        Button:setTargetPos(x + Button.SPACER, 2)
        self.isRotatingRight = true
        self.isRotatingLeft = false
      end
    end
  );
  
  Signal.register('SpinUIWheelRight',
    function(before, x)
      if before == 'fsd' then -- result: {left: duo, center: flour, right: solo}
        self.active = false
        self.layer = 1
        -- lets do it here instead Button:setTargetPos(x + Button.SPACER, 1)
        self.tX = x + Button.SPACER
        self.dX = Button.BASE_DX * 1
        self.isRotatingRight = true
        self.isRotatingLeft = false
      elseif before == 'dfs' then -- result: {left: solo, center: duo, right: flour}
        self.active = false
        self.layer = 3
        Button:setTargetPos(x - Button.SPACER, 2)
        self.isRotatingRight = false
        self.isRotatingLeft = true
      elseif before == 'sdf' then -- result: {left: flour, center: solo, right: duo}
        self.active = true
        self.layer = 1
        Button:setTargetPos(x, 1)
        self.isRotatingRight = true
        self.isRotatingLeft = false
      end
    end
  );
end;

function SoloButton:keypressed(key)
    -- TODO
end;
