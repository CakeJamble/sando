Projectile = Class{}

function Projectile:init(x, y)
	self.pos = {x=x, y=y}
	self.dims = {r = 1}
end;

function Projectile:draw()
	love.graphics.circle('fill', self.pos.x, self.pos.x, self.dims.r)
end;