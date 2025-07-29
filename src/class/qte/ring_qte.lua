RingQTE = Class{__includes =  QTE}

function RingQTE:init(data)
	QTE.init(self, data)
	self.options = data.options
	self.flipDuration = data.flipDuration
	self.ring = Ring(data.options, self.flipDuration)
	self.numSlices = data.numSlices
	self.sliceLenRange = {min = data.sliceLenRange.min, max = data.sliceLenRange.max}
	self.slices = {}
end;

function RingQTE:setActionButton(actionButton, buttonUI)
	self.actionButton = actionButton
	self.buttonUI = buttonUI
	self.instructions = "Press " .. string.upper(actionButton) .. " in the highlighted positions."
end;

function RingQTE:beginQTE()
	-- Begin tweening of line over the ring
	flipTween = ring:flipRing()

	flipTween:oncomplete(
		function()
			for i=1, self.numSlices do
				local angleMod = love.math.random(self.sliceLenRange.min, self.sliceLenRange.max)
				local angle = math.pi / angleMod

				local angleStart = love.math.random(0, (2 * math.pi) - angle)
				local angleEnd = angleStart + angle

				local vertices = self:buildArc(self.options.r, angleStart, angleEnd)
				self.slices[i] = vertices
			end
		end)
end;

function RingQTE:draw()
	love.graphics.push()
	love.graphics.translate(self.options.x, self.options.y)

	-- shear factor set in ring class
	self.ring:draw()

	if self.doneWaiting then
		for i,vertices in ipairs(self.slices) do
			love.graphics.polygon('fill', vertices)
		end
	end

	love.graphics.pop()
end;

function RingQTE:buildArc(radius, angleStart, angleEnd, segments)
    local vertices = { 0, 0 } -- center of the fan
    for i = 0, segments do
        local angle = angleStart + i * (angleEnd - angleStart) / segments
        local x = math.cos(angle) * radius
        local y = math.sin(angle) * radius
        table.insert(vertices, x)
        table.insert(vertices, y)
    end
    return vertices
end