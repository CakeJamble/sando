---@meta

---@class Character: Entity
---@field EXP_POW_SCALE number
---@field EXP_MULT_SCALE integer
---@field EXP_BASE_ADD integer
---@field xCombatStart integer
---@field yPos integer
---@field xPos integer
---@field yOffset integer
---@field combatStartEnterDuration number
---@field guardActiveDur number
---@field guardCooldownDur number
---@field guardCooldownFinished boolean
---@field baseLandingLag number
---@field jumpDur number
---@field landingLag number
---@field inventory Inventory
---@field canBeDebuffed boolean
---@field numEquipSlots integer
---@field numAccessorySlots integer
---@field actionButton string
---@field skillPool table[]
---@field blockMod integer
---@field level integer
---@field growthFunctions function[]
---@field currentSkills table[]
---@field qteSuccess boolean
---@field totalExp integer
---@field experience integer
---@field experienceRequired integer
---@field currentFP integer
---@field fpCostMod integer
---@field cannotLose boolean
---@field equips {[string]: table}
---@field isGuarding boolean
---@field canGuard boolean
---@field canJump boolean
---@field isJumping boolean
---@field landingLagMods number[]
---@field hasLCanceled boolean
---@field canLCancel boolean
---@field jumpHeight integer
---@field sfx SoundManager
---@field actionUI ActionUI
local Character = {}

---@param data table
---@param actionButton string
function Character:init(data, actionButton) end

-- Sets up turn state, inits an ActionUI, and emits the `OnStartTurn` signal
function Character:startTurn() end

--[[Stores a reference to all valid targets on the field to `self.targetableEntities`
in a table of the format `{characters: Character[], enemies: Enemy[]}`]]
---@param targets { [string]: Entity[]}
---@param targetType string
function Character:setTargets(targets, targetType) end

--[[Deconstructs the Character's Action UI, moves them back to their original position,
and sets other relevant variables to a valid state for relinquishing control to the Scheduler]]
---@param duration integer
---@param stagingPos? table
---@param tweenType? string
function Character:endTurn(duration, stagingPos, tweenType) end

--[[Deconstructs the Character's Action UI, and sets other relevant variables to
a valid state for relinquishing control to the Scheduler]]
---@param duration integer
function Character:endTurn(duration) end

---@param cost integer
---@return boolean
function Character:validateSkillCost(cost) end

---@param cost integer
function Character:deductFP(cost) end

---@param status string
function Character:applyStatus(status) end

--[[Applies a stat modifier that lasts until the end of the encounter.
This function should not be used to modify HP or FP.]]
---@param stat string
---@param stage integer
---@see Character.raiseMaxHP
---@see Entity.heal
---@see Character.takeDamage
---@see Character.takeDamagePierce
---@see Character.deductFP
---@see Character.refresh
function Character:modifyBattleStat(stat, stage) end

--[[Raises the Character's Max HP by a given percentage, rounding up.
Will also restore HP to maintain the previous ratio of `battleStats.hp / baseStates.hp`]]
---@param pct number
function Character:raiseMaxHP(pct) end

--[[Raises the Character's Max HP by a given percentage, rounding up.
If Max HP falls below current HP, then current HP will be set to the new Max HP]]
---@param pct number
function Character:lowerMaxHP(pct) end

--[[Applies damage to the Character with the following checks for modifiers
and/or state changes.

  1. Is the Character guarding?
  2. Does this damage KO the Character?
  3. Apply additional defense modifiers

After taking damage, the `OnHPChanged` & `OnAttacked` signals are emitted.]]
---@param amount integer
---@param attackerLuck integer
function Character:takeDamage(amount, attackerLuck) end

-- Applies damage to the Character, bypassing all modifiers and defenses
---@param amount integer
function Character:takeDamagePierce(amount) end

-- Restores FP by the amount passed in
---@param amount integer
function Character:refresh(amount) end

function Character:removeCurses() end

-- Makes the Character flinch and take piercing damage (WIP)
---@param additionalPenalty? integer
function Character:recoil(additionalPenalty) end

--[[ Iterates over the array of landing lag modifiers
and multiplies them to a copy of the base landing lag.]]
---@return number
function Character:getLandingLag() end

---@param item table
---@param itemType string
function Character:equip(item, itemType) end

---@param itemType string
---@param pos integer
---@return { [string]: any }
function Character:unequip(itemType, pos) end

--[[ Gains exp, leveling up when applicable. Updates the following:

  - `self.totalExp`
  - `self.experience`
  - `self.level`
  - `self.experienceRequired`

Continues updating `self.level` until `self.experience` is less that `self.experienceRequired`.]]
---@param amount integer
function Character:gainExp(amount) end

--[[Increments the Character's level and boosts their stats
according to their growth functions. Preserves their HP & FP ratios.]]
---@return { string: integer } # Stats from previous level
function Character:levelUp() end

-- Gets the required exp for the next level based on polynomial scaling
---@return integer result Required amount of experience for next level up
function Character:getRequiredExperience() end

--[[Updates `self.currentSkills` and then returns a list of strings
containing the names of the skills added.]]
---@return string[]
function Character:updateSkills() end

-- Adds a new skill to `self.currentSkills`, bypassing the Character's skill pool.
---@param skill table
function Character:learnSkill(skill) end

-- WIP for interaction with learning a new skill from a list of possible choices
---@return any
function Character:yieldSkillSelect() end

--[[Raises the Character's defense by 1 stage, then starts 2 timers.
After the first timer ends, the defense is reverted to its original value.
After the second timer ends, the Character's guard cooldown ends.
Character's can begin a guard while jumping, but cannot begin a jump while guarding.]]
function Character:beginGuard() end

--[[Begins a jump, and disables jumping functionality until the landing lag after
the Character lands ends. Jumps can also be interrupted by collision.]]
---@see Character.land
---@see Character.interruptJump
function Character:beginJump() end

--[[Sets the playback speed for the landing animation based on
`self.baseLandingLag` & `self.landingLagMods`.
Performing a Fall-Cancel will hasten the duration of the landing state.]]
---@see Character.getLandingLag
function Character:land() end

--[[Usually invoked upon collision, this will stop the progress of a jump and
place the Character into a tumbling state. Fall-Cancel checks are still applied.]]
function Character:interruptJump() end

---@param dt number
function Character:updateInput(dt) end;

--[[Creates all skill animations from the Character's `self.currentSkills` table.
This is to avoid slowing down an initial load of skills that may never be used.]]
---@param dir string The directory where animations are located
---@param actor table Reference to eh AnimX actor object housing animations
function Character:createSkillAnimations(dir, actor) end

---@param dt number
function Character:update(dt) end

function Character:draw() end
