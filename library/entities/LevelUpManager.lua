---@meta

---@class LevelUpManager
---@field characterTeam CharacterTeam
---@field levelUpUI { [string]: table }
---@field duration number
---@field windowWidth integer
---@field windowHeight integer
---@field coroutines table
---@field i integer
---@field isDisplayingNotification boolean
---@field textBox table
---@field isActive boolean
LevelUpManager = {}

---@param characterTeam CharacterTeam
function LevelUpManager:init(characterTeam) end

--[[Distributes the amount to each member of the team without dividing it.
Distribution is done one Character at a time using coroutines.]]
---@param amount integer
function LevelUpManager:distributeExperience(amount) end

--[[Adds the exp to the character and procs level ups and new skill learning interactions.
When a level up occurs, a stat bonus interaction is also triggered here.
Bypasses the Character method for gaining exp and modifies it directly here.
A decision needs to be made whether this calls the Character method or does it directly.]]
---@param member Character
---@param amount integer
---@return thread
---@see Character.gainExp
function LevelUpManager:createExpCoroutine(member, amount) end

--[[Controller for `self.coroutines`. Once all coroutines are finished,
it emits the `OnExpDistributionComplete` signal, which will cause the
LevelUpManager to relinquish control of the program to the calling object.]]
function LevelUpManager:resumeCurrent() end

--[[Simple abstraction for formatting the text and triggering the SYSL-text handler
to show the text box and handle player input.]]
---@param character Character
---@param callback fun(): string
function LevelUpManager:displayNotification(character, callback) end

---@deprecated Uses the deprecated `frameWidth` & `frameHeight` variables
---@param members Character[]
---@return { [string]: table }
function LevelUpManager.initUI(members) end

---@param dt number
function LevelUpManager:update(dt) end

function LevelUpManager:draw() end