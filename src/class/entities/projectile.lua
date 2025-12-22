local flux = require('libs.flux')
local Class = require('libs.hump.class')

---@class Projectile
---@field drawHitboxes boolean
local Projectile = Class{drawHitboxes = true}

---@param x integer
---@param y integer
---@param w integer
---@param h integer
---@param castsShadow boolean
---@param index integer
---@param animation table { spriteSheet: love.Image, quads: love.Quad, duration: integer, currentTime: number, spriteNum: integer, still: love.Image }
function Projectile:init(x, y, w, h, castsShadow, index, animation)
	self.pos = {x=x, y=y, r=0}
	-- self.dims = {r = 10}
	-- local r = self.dims.r
	self.hitbox = {
		x=x,y=y,
		w=w, h=h
	}

	self.ox, self.oy = self.hitbox.w/2, self.hitbox.h/2
	self.shadowPos = {
		x=x, y=y + self.hitbox.h,
		w=self.hitbox.w/2, h=self.hitbox.h/4
	}

	-- Does this prevent a shared animation?
	-- self.animation = deepCopy(animation)

	self.animation = animation
	self.isStill = false

	self.index = index
	self.castsShadow = castsShadow
	self.tweens = {}
end;

---@param dt number
function Projectile:update(dt)
	self.hitbox.x = self.pos.x
	self.hitbox.y = self.pos.y
	self.shadowPos.x = self.pos.x
	self:updateAnimation(dt)
end

---@param dt number
function Projectile:updateAnimation(dt)
	if not self.isStill then
		self.animation.currentTime = self.animation.currentTime + dt
		if self.animation.currentTime >= self.animation.duration then
			self.animation.currentTime = self.animation.currentTime - self.animation.duration
		end

		self.animation.spriteNum = math.floor(self.animation.currentTime / self.animation.duration * #self.animation.quads) + 1
		self.animation.spriteNum = math.min(self.animation.spriteNum, #self.animation.quads)
	end
end;

---@param duration integer
---@param targetYPos integer
function Projectile:tweenShadow(duration, targetYPos)
	flux.to(self.shadowPos, duration, {y = targetYPos})
	local tween = flux.to(self.shadowPos, duration / 2, {w = self.hitbox.w / 3})
		:ease('quadout')
		:after(duration / 2, {w = self.hitbox.w / 2})
			:ease('quadin')
	self.tweens['shadow'] = tween
end;

---@param tweenKey string
function Projectile:interruptTween(tweenKey)
	self.tweens[tweenKey]:stop()
end;

function Projectile:draw()
	self:drawSprite()
	self:drawShadow()
	self:drawHitbox()
end;

function Projectile:drawSprite()
	local x, y, r = self.pos.x, self.pos.y, self.pos.r
	if self.isStill then
		love.graphics.draw(self.animation.still, x, y)
	else
		love.graphics.draw(self.animation.spriteSheet, self.animation.quads[self.animation.spriteNum], x, y, r, 1, 1, self.ox, self.oy)
	end
end;

function Projectile:drawShadow()
	if self.castsShadow then
		local x,y = self.shadowPos.x - self.ox, self.shadowPos.y - self.oy
		love.graphics.setColor(0, 0, 0, 0.4)
	  love.graphics.ellipse("fill", x, y, self.shadowPos.w, self.shadowPos.h)
	  love.graphics.setColor(1, 1, 1, 1)
	end
end;

function Projectile:drawHitbox()
  if Projectile.drawHitboxes then
		local x,y = self.hitbox.x - self.ox, self.hitbox.y - self.oy
    love.graphics.setColor(1, 1, 0, 0.4)
    love.graphics.rectangle("fill", x, y, self.hitbox.w, self.hitbox.h)
    love.graphics.setColor(1, 1, 1)
  end
end;

return Projectile