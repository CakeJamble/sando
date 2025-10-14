local Class = require('libs.hump.class')

---@class ScrollingTexture
local ScrollingTexture = Class{}

---@param texturePath string
---@param maskPath string
---@param speed number
function ScrollingTexture:init(texturePath, maskPath, speed)
	self.texture = love.graphics.newImage(texturePath)
	self.texture:setWrap("repeat", "repeat")
	self.speed = speed or 10
	self.xOffset, self.yOffset = 0, 0

	self.mask = love.graphics.newImage(maskPath)
	self.w, self.h = self.mask:getWidth(), self.mask:getHeight()
	self.quad = love.graphics.newQuad(0,0, self.w, self.h,
		self.texture:getWidth(), self.texture:getHeight())
end;

---@param dt number
function ScrollingTexture:update(dt)
	self.xOffset = (self.xOffset + self.speed * dt) % self.texture:getWidth()
	self.yOffset = (self.yOffset + self.speed * 0.5 * dt) % self.texture:getHeight()
	self.quad:setViewport(self.xOffset, self.yOffset, self.w, self.h, self.texture:getWidth(), self.texture:getHeight())
end;

---@param x number
---@param y number
function ScrollingTexture:draw(x, y)
	love.graphics.stencil(function() love.graphics.draw(self.mask, x, y) end,
	"replace", 1)

	love.graphics.setStencilTest("equal", 1)
	love.graphics.draw(self.texture, self.quad, x, y)
	love.graphics.setStencilTest()
end;

return ScrollingTexture