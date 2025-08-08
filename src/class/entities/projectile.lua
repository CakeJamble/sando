Projectile = Class{}

function Projectile:init(x, y, index)
	self.pos = {x=x, y=y}
	self.dims = {r = 10}
	self.hitbox = {
		x=x,y=y,w=2*self.dims.r, h=2*self.dims.r
	}
	self.index = index
end;

function Projectile:update(dt)
	self.hitbox.x = self.pos.x
	self.hitbox.y = self.pos.y
end

function Projectile:draw()
	love.graphics.setColor(1,0,0,1) --red
	love.graphics.circle('fill', self.pos.x, self.pos.y, self.dims.r)
	love.graphics.setColor(1,1,1)

	-- shadow
	 love.graphics.setColor(0, 0, 0, 0.4)
  love.graphics.ellipse("fill", self.pos.x, self.pos.y + self.hitbox.h, self.hitbox.w / 2, self.hitbox.h / 4)
  love.graphics.setColor(1, 1, 1, 1)
end;