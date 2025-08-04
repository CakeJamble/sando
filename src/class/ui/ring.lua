Class = require 'libs.hump.class'
Ring = Class{}

function Ring:init(options, flipDuration, slicesData, qteDuration)
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
	self.numSlices = slicesData.numSlices
	self.sliceLenRange = slicesData.sliceLenRange
	self.slices = self:buildSlices()
	self.line = {
		angle = 0,
		duration = qteDuration,
		length = options.r,
		isActive = false
	}
	self.revolutionTween = nil
	self.showSlices = false

	-- local ringShaderCode = [[
	-- 	extern number shearFactor;

	-- 	vec4 effect(vec4 color, Image texture, vec2 texCoords, vec2 screenCoords) {
    -- 	vec4 pixel = Texel(texture, texCoords);
    
    -- 	// Lighting multiplier: darkens bottom, lightens top based on shearFactor
    -- 	float lighting = mix(0.6, 1.0, texCoords.y) * shearFactor + (1.0 - shearFactor);
    
    -- 	return pixel * color * vec4(vec3(lighting), 1.0);
	-- 	}
	-- ]]

	-- self.ringShader = love.graphics.newShader(ringShaderCode)
end;

function Ring:flipRing()
	local randShearMod = love.math.random(50, 75)
	local randShear = randShearMod / 100
	local flipTween = flux.to(self.shear, self.flipDuration, {angle = 2 * math.pi + randShear})
		:onupdate(function()
			self.shear.ky = math.sin(self.shear.angle) * 1.0
			self.shear.scale = math.cos(self.shear.angle)
		end)
		:ease('quadout')

	flux.to(self.offset, self.flipDuration/2, {y = -100})
		:ease('quadout')
		:oncomplete(function() 
			self.showSlices = true 
			self.line.isActive = true
		end)
		:after(self.offset, self.flipDuration/2, {y = 0})
			:ease('quadin')
	return flipTween
end;

function Ring:buildSlices()
	local slices = {}
	local spacing = math.rad(5)
	local maxArc = math.pi * (self.sliceLenRange.max / 100)
	local minArc = math.pi * (self.sliceLenRange.min / 100)
	local twoPi = 2 * math.pi
	local startAngles = {}
	for i=1, self.numSlices do
		table.insert(startAngles, love.math.random() * twoPi)
	end
	table.sort(startAngles)

	for i=1, #startAngles do
		local aStart = startAngles[i]
		local nextAngle = startAngles[i+1] or (startAngles[1] + twoPi)
		local availableArc = (nextAngle - aStart - spacing) % twoPi

		if availableArc >= minArc then
			local arcLen = love.math.random() * (self.sliceLenRange.max - self.sliceLenRange.min)
			arcLen = minArc + (arcLen / 100) * math.pi

			if arcLen > availableArc then
				arcLen = availableArc
			end

			local aEnd = (aStart + arcLen) % twoPi
			local vertices = self:buildArc(self.options.r, aStart, aEnd)

			table.insert(slices, {
				vertices = vertices,
				angleStart = aStart,
				angleEnd = aEnd
			})
		end
	end
	self.numSlices = #slices
	return slices
end;
-- 	for i=1, self.numSlices do
-- 		local angleMod = love.math.random(self.sliceLenRange.min, self.sliceLenRange.max)
-- 		local angle = prevAngle + math.pi * (angleMod / 100)

-- 		local angleStart = love.math.random() * ((2 * math.pi) - angle)
-- 		local angleEnd = angleStart + angle
-- 		local vertices = self:buildArc(self.options.r, angleStart, angleEnd)
-- 		local prevAngle = angle
-- 		slices[i] = {
-- 			vertices = vertices,
-- 			angleStart = angleStart % (2 * math.pi),
-- 			angleEnd = angleEnd % (2 * math.pi)
-- 		}
-- 	end

-- 	return slices
-- end;

function Ring:buildArc(radius, angleStart, angleEnd, segments)
    local vertices = { 0, 0 }
    local segments = segments or 32
    for i = 0, segments do
        local angle = angleStart + i * (angleEnd - angleStart) / segments
        local x = math.cos(angle) * radius
        local y = math.sin(angle) * radius
        table.insert(vertices, x)
        table.insert(vertices, y)
    end
    return vertices
end

function Ring:startRevolution()
	local flipTween = self:flipRing()
	flipTween:oncomplete(function() 
		self.line.angle = 0

		self.revolutionTween = flux.to(self.line, self.line.duration, {angle = 2 * math.pi})
			:ease('linear')
			:delay(0.25)
			:onstart(function()
				self.revActive = true
			end)
			:oncomplete(function()
				self.revActive = false
			end)
	end)
end;

function Ring:isInHitBox()
	local angle = self.line.angle % (2 * math.pi)

	for i,slice in ipairs(self.slices) do
		local start = slice.angleStart
		local stop = slice.angleEnd
		if angle >= start and angle <= stop then
			return true
		end
	end
	return false
end;

function Ring:draw()
	-- love.graphics.setShader(self.ringShader)
    love.graphics.push()
    love.graphics.translate(self.options.x, self.options.y + self.offset.y)

    love.graphics.shear(0, self.shear.ky)
    love.graphics.scale(1, self.shear.scale)
    love.graphics.setColor(1, 0.85, 0.2)
    love.graphics.circle(self.options.mode, 0,0, self.options.r)

    if self.shear.scale > 0 then
	    love.graphics.setColor(0.2, 0.2, 0.2, 0.4)
   	 	love.graphics.circle("fill", 0, 0, self.options.r * 0.4)
    	love.graphics.setColor(1, 1, 1, 1)
    end

	if self.showSlices then
		for i,slice in ipairs(self.slices) do
			love.graphics.polygon('fill', slice.vertices)
		end
	end

	if self.line.isActive then
		local cx,cy = 0,0
		local lAngle = self.line.angle
		local length = self.line.length
		local ex = cx + math.cos(lAngle) * length
		local ey = cy + math.sin(lAngle) * length

		love.graphics.setColor(1, 0.2, 0.2)
		love.graphics.line(cx,cy,ex,ey)

		love.graphics.setColor(1,1,1)
	end

	love.graphics.pop()
	-- love.graphics.setShader()
end;