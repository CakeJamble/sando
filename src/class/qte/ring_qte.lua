RingQTE = Class{__includes =  QTE}

function RingQTE:init(data)
	QTE.init(data)
	self.options = data.options
	self.flipDuration = data.flipDuration
	self.ring = Ring(data.options, self.flipDuration)
end;

function RingQTE:setActionButton(actionButton, buttonUI)
	self.actionButton = actionButton
	self.buttonUI = buttonUI
	self.instructions = "Press " .. string.upper(actionButton) .. " in the highlighted positions."
end;

function RingQTE:beginQTE()
	flipTween = ring:flipRing()

	flipTween:after()
end;

function RingQTE:draw()
	self.ring:draw()
end;