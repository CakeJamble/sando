local flux = require('libs.flux')
local Class = require('libs.hump.class')

-- TODO refactor projectile class to use animx
---@type Projectile
local Projectile = Class { drawHitboxes = true }

function Projectile:init(x, y, w, h, castsShadow, index, animation)
	self.pos = { x = x, y = y, r = 0 }
	-- self.dims = {r = 10}
	-- local r = self.dims.r
	self.hitbox = {
		x = x,
		y = y,
		w = w,
		h = h
	}

	self.ox, self.oy = self.hitbox.w / 2, self.hitbox.h / 2
	self.shadowPos = {
		x = x,
		y = y + self.hitbox.h,
		w = self.hitbox.w / 2,
		h = self.hitbox.h / 4
	}

	-- self.animation = animation
	self.isStill = false

	self.index = index
	self.castsShadow = castsShadow
	self.tweens = {}
end;

function Projectile:update(dt)
	self.hitbox.x = self.pos.x
	self.hitbox.y = self.pos.y
	self.shadowPos.x = self.pos.x
end

function Projectile:tweenShadow(duration, targetYPos)
	flux.to(self.shadowPos, duration, { y = targetYPos })
	local tween = flux.to(self.shadowPos, duration / 2, { w = self.hitbox.w / 3 })
			:ease('quadout')
			:after(duration / 2, { w = self.hitbox.w / 2 })
			:ease('quadin')
	self.tweens['shadow'] = tween
end;

function Projectile:interruptTween(tweenKey)
	self.tweens[tweenKey]:stop()
end;

function Projectile:draw()
	self:drawShadow()
	self:drawHitbox()
end;

function Projectile:drawShadow()
	if self.castsShadow then
		local x, y = self.shadowPos.x - self.ox, self.shadowPos.y - self.oy
		love.graphics.setColor(0, 0, 0, 0.4)
		love.graphics.ellipse("fill", x, y, self.shadowPos.w, self.shadowPos.h)
		love.graphics.setColor(1, 1, 1, 1)
	end
end;

function Projectile:drawHitbox()
	if Projectile.drawHitboxes then
		local x, y = self.hitbox.x - self.ox, self.hitbox.y - self.oy
		love.graphics.setColor(1, 1, 0, 0.4)
		love.graphics.rectangle("fill", x, y, self.hitbox.w, self.hitbox.h)
		love.graphics.setColor(1, 1, 1)
	end
end;

return Projectile
