Projectile = Class{drawHitboxes = false}

function Projectile:init(x, y, index)
	self.pos = {x=x, y=y}
	self.dims = {r = 10}
	local r = self.dims.r
	self.hitbox = {
		x=x-r,y=y-r,w=2*self.dims.r, h=2*self.dims.r
	}
	self.index = index
end;

function Projectile:update(dt)
	local r = self.dims.r
	self.hitbox.x = self.pos.x - r
	self.hitbox.y = self.pos.y - r
end

function Projectile:draw()
	love.graphics.setColor(1,0,0,1) --red
	love.graphics.circle('fill', self.pos.x, self.pos.y, self.dims.r)
	love.graphics.setColor(1,1,1)

	-- shadow
	 love.graphics.setColor(0, 0, 0, 0.4)
  love.graphics.ellipse("fill", self.pos.x, self.pos.y + self.hitbox.h, self.hitbox.w / 2, self.hitbox.h / 4)
  love.graphics.setColor(1, 1, 1, 1)

  if Projectile.drawHitboxes then
    love.graphics.setColor(1, 1, 0, 0.4)
    love.graphics.rectangle("fill", self.hitbox.x, self.hitbox.y, self.hitbox.w, self.hitbox.h)
    love.graphics.setColor(1, 1, 1)
  end
end;