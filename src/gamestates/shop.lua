local Shop = {}
local DialogManager = require('libs.ui.dialog_manager')

function Shop:init()
	self.dialogManager = DialogManager()
	self.dialogManager:getAll('shop')
	self.textbox = Text.new("left",
	{
    color = {0.9,0.9,0.9,0.95},
    shadow_color = {0.5,0.5,1,0.4},
    character_sound = true,
    sound_every = 2,
	})
	self.hasVisited = false
end;

---@param previous table
---@param characterTeam CharacterTeam
function Shop:enter(previous, characterTeam)
	self.characterTeam = characterTeam
	self.greeting = self.getGreeting(self.hasVisited)
end;

---@param hasVisited boolean
---@return string
function Shop.getGreeting(hasVisited)
	local result

	if not hasVisited then
		result = self.dialogManager:getText('shop', 'firstVisit')
		self.hasVisited = true
	else
		result = self.dialogManager:getText('shop', 'returnVisit')
	end

	return result
end;

return Shop