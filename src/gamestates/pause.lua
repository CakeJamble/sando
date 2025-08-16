--! filename: pause
local pause = {}

function pause:initialize()
    -- TODO
end;

function pause:enter(previous, inventory)
    --[[
        TODO: set up pause menu (class? yea probably easiest to make it a class)
        inventory
            character - gear
        team
            stats
            skills
        settings
        exit
    ]]
    self.tabs = {
        'inventory',
        'team',
        'settings',
        'exit'
    }

    self.menuSprite = love.graphics.newImage('asset/sprites/pause/menu.png')
    self.menuCursor = love.graphics.newImage('asset/sprites/pause/cursor.png')

    self.inventory = inventory
end;

function pause:keypressed(key)
    if key == 'p' then
        return Gamestate.pop()
    end
end;

function pause:update(dt)
end;

function pause:draw()
    push:start()
    -- love.graphics.draw(self.menuSprite, 0, 0)
    -- love.graphics.draw(self.menuCursor, 0, 0)
    self.inventory:draw()
    push:finish()
end;

return pause