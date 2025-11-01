local flux = require('libs.flux')
local deepCopy = require('util.table_utils').deepCopy
local Class = require('libs.hump.class')

---@class Projectile
---@field drawHitboxes boolean
local Projectile = Class{drawHitboxes = false}

---@param x integer
---@param y integer
---@param w integer
---@param h integer
---@param castsShadow boolean
---@param index integer
---@param animation table { spriteSheet: love.Image, quads: love.Quad, duration: integer, currentTime: number, spriteNum: integer, still: love.Image }
function Projectile:init(x, y, w, h, castsShadow, index, animation)
	self.pos = {x=x, y=y}
	-- self.dims = {r = 10}
	-- local r = self.dims.r
	self.hitbox = {
		x=x-w/2,y=y-h/2,
		w=w, h=h
	}
	self.shadowPos = {
		x=x, y=y + self.hitbox.h,
		w=self.hitbox.w/2, h=self.hitbox.h/4
	}

	-- Does this prevent a shared animation?
	self.animation = deepCopy(animation)
	self.isStill = false

	self.index = index
	self.castsShadow = castsShadow
	self.tweens = {}
end;

---@param dt number
function Projectile:update(dt)
	local r = self.dims.r
	self.hitbox.x = self.pos.x - r
	self.hitbox.y = self.pos.y - r
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

---@param pos table Position table of owner of projectiles
function Projectile:draw(pos)
	local ox,oy = pos.ox, pos.oy
	self:drawSprite(ox, oy)

	if self.castsShadow then
		love.graphics.setColor(0, 0, 0, 0.4)
	  love.graphics.ellipse("fill", self.shadowPos.x - ox, self.shadowPos.y - oy, self.shadowPos.w, self.shadowPos.h)
	  love.graphics.setColor(1, 1, 1, 1)
	end

  if Projectile.drawHitboxes then
    love.graphics.setColor(1, 1, 0, 0.4)
    love.graphics.rectangle("fill", self.hitbox.x - ox, self.hitbox.y - oy, self.hitbox.w, self.hitbox.h)
    love.graphics.setColor(1, 1, 1)
  end
end;

---@param ox number Origin X offset for drawing centered projectile
---@param oy number Origin Y offset for drawing centered projectile
function Projectile:drawSprite(ox, oy)
	local x, y = self.pos.x - ox, self.pos.y - oy

	if self.isStill then
		love.graphics.draw(self.animation.still, x, y)
	else
		local spriteNum = math.floor(self.animation.currentTime / self.animation.duration * #self.animation.quads) + 1
		spriteNum = math.min(spriteNum, #self.animation.quads)

		love.graphics.draw(self.animation.spriteSheet, self.animation.quads[spriteNum], x, y)
	end
end;

return Projectile