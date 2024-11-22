--! filename: pause
local pause = {}

function pause:initialize()
    -- TODO
end;

function pause:enter(previous, team)
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
    tabs = {
        'inventory',
        'team',
        'settings',
        'exit'
    }

    self.menuSprite = love.graphics.newImage('asset/sprites/pause/menu.png')
    self.menuCursor = love.graphics.newImage('asset/sprites/pause/cursor.png')
    
    self.teamInventory = team:getInventory()
end;

function pause:keypressed(key)
end;

function pause:update(dt)
end;

function pause:draw()
    love.graphics.draw(self.menuSprite, 0, 0)
    self.menuCursor:draw()
end;

return pause