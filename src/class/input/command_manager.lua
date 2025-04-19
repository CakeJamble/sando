--! filename: command manager
require('class.input.guard_command')
require('class.input.jump_command')
require('class.input.select_command')
require('class.input.toggle_command')
require('class.input.cancel_command')

Class = require('libs.hump.class')
CommandManager = Class{}

function CommandManager:init()
  -- self.config = GetXboxConfig()
  self.listeners = {}
  self.guardCommand = GuardCommand()
  self.jumpCommand = JumpCommand()
  self.selectCommand = SelectCommand()
  self.cancelCommand = CancelCommand()
  self.toggleCommand = ToggleCommand()
end;


function CommandManager:addListener(listener)
  table.insert(self.listeners, listener)
end;

function CommandManager:removeLister(listener)
  table.remove(self.listeners, listener)
end;

function CommandManager:notifyListeners(command)
  for i=1,self.listeners do
    command:execute()
  end
end;

--TODO: this should be implemented in each controller interface, then abstracted here
function CommandManager:gamepadpressed(joystick, button)
  if button == 'a' then
    CommandManager:notifyListeners()
  end
end;
