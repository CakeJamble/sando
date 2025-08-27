local flux = require('libs.flux')
local Class = require('libs.hump.class')

---@class Projectile
local Projectile = Class{drawHitboxes = false}

function Projectile:init(x, y, castsShadow, index)
	self.pos = {x=x, y=y}
	self.dims = {r = 10}
	local r = self.dims.r
	self.hitbox = {
		x=x-r,y=y-r,w=2*self.dims.r, h=2*self.dims.r
	}
	self.shadowPos = {
		x=x, y=y + self.hitbox.h,
		w=self.hitbox.w/2, h=self.hitbox.h/4
	}

	self.index = index
	self.castsShadow = castsShadow
	self.tweens = {}
end;

function Projectile:update(dt)
	local r = self.dims.r
	self.hitbox.x = self.pos.x - r
	self.hitbox.y = self.pos.y - r
	self.shadowPos.x = self.pos.x
end

function Projectile:tweenShadow(duration, targetYPos)
	flux.to(self.shadowPos, duration, {y = targetYPos})
	local tween = flux.to(self.shadowPos, duration / 2, {w = self.hitbox.w / 3})
		:ease('quadout')
		:after(duration / 2, {w = self.hitbox.w / 2})
			:ease('quadin')
	self.tweens['shadow'] = tween
end;

function Projectile:interruptTween(tweenKey)
	self.tweens[tweenKey]:stop()
end;

function Projectile:draw()
	love.graphics.setColor(1,0,0,1) --red
	love.graphics.circle('fill', self.pos.x, self.pos.y, self.dims.r)
	love.graphics.setColor(1,1,1)

	if self.castsShadow then
		love.graphics.setColor(0, 0, 0, 0.4)
	  love.graphics.ellipse("fill", self.shadowPos.x, self.shadowPos.y, self.shadowPos.w, self.shadowPos.h)
	  love.graphics.setColor(1, 1, 1, 1)
	end

  if Projectile.drawHitboxes then
    love.graphics.setColor(1, 1, 0, 0.4)
    love.graphics.rectangle("fill", self.hitbox.x, self.hitbox.y, self.hitbox.w, self.hitbox.h)
    love.graphics.setColor(1, 1, 1)
  end
end;

return Projectile