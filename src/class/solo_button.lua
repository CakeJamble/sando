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
      print('test signal in SoloButton')
      if before == {'flour', 'solo', 'duo'} then -- result: {left:solo, center:duo, right:flour}
        self.active = false
        self.layer = 1
        Button:setTargetPos(x - Button.SPACER, 1)
      elseif before == {'duo', 'flour', 'solo'} then -- result: {left:flour, center:solo, right:duo} 
        self.active = true
        self.layer = 1
        Button:setTargetPos(x, 1)
      elseif before == {'solo', 'duo', 'flour'} then -- result: {left: duo, center: flour, right: solo}
        self.active = false
        self.layer = 3
        Button:setTargetPos(x + Button.SPACER, 2)
      end
    end
  );
  
  Signal.register('SpinUIWheelRight',
    function(before, x)
      print('test signal in SoloButton')

      if before == {'flour', 'solo', 'duo'} then -- result: {left: duo, center: flour, right: solo}
        self.active = false
        self.layer = 1
        Button:setTargetPos(x + Button.SPACER, 1)
      elseif before == {'duo', 'flour', 'solo'} then -- result: {left: solo, center: duo, right: flour}
        self.active = false
        self.layer = 3
        Button:setTargetPos(x - Button.SPACER, 2)
      elseif before == {'solo', 'duo', 'flour'} then -- result: {left: flour, center: solo, right: duo}
        self.active = true
        self.layer = 1
        Button:setPos(x, 1)
      end
    end
  );
end;

function SoloButton:keypressed(key)
    -- TODO
end;

function SoloButton:update(dt)
  Button.update(self, dt)
end;
