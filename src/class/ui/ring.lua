Class = require 'libs.hump.class'
Ring = Class{}

function Ring:init(options, flipDuration)
	self.options = {
		mode = options.mode,
		x = options.x,
		y = options.y,
		r = options.r,
	}
	-- self.lineLen = options.r
	self.flipDuration = flipDuration
	self.shear = {
		kx = 0,
		ky = 0,
		scale = 1,
		angle = 0
	}
	self.offset = {x=0,y=0}
	self.peakHeight = 100
end;

function Ring:flipRing()
	-- flux.to(self.shear, self.flipDuration, {scale = -1})
		-- :ease('linear')

	local tween = flux.to(self.shear, self.flipDuration, {angle = 2 * math.pi})
		:ease('quadout')

	-- flux.to(self.shear, self.flipDuration / 2, {ky = 1.2})
	-- 	:after(self.shear, self.flipDuration/2, {ky = -1.2})
	-- 	:ease('quadout')

	flux.to(self.offset, self.flipDuration/2, {y = -100})
		:ease('quadout')
		:after(self.offset, self.flipDuration/2, {y = 0})
			:ease('quadin')

	return tween
end;



function Ring:draw()
    love.graphics.push()
    love.graphics.translate(self.options.x, self.options.y + self.offset.y)
    local angle = self.shear.angle
    local scaleY = math.cos(angle)
    local shearY = math.sin(angle) * 1.0
    love.graphics.shear(0, shearY)
    love.graphics.scale(1, scaleY)
    love.graphics.setColor(1, 0.85, 0.2)
    love.graphics.circle(self.options.mode, 0,0, self.options.r)

    if scaleY > 0 then
	    love.graphics.setColor(0.2, 0.2, 0.2, 0.4)
   	 	love.graphics.circle("fill", 0, 0, self.options.r * 0.4)
    	love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.pop()
end;