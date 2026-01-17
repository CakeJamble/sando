---@class (exact) Stats
---@field hp integer
---@field fp integer
---@field attack integer
---@field defense integer
---@field speed integer
---@field luck integer
---@field growthRate integer Rate at which required EXP raises between levels

---@class (exact) StatusResists
---@field burn number
---@field poison number
---@field sleep number
---@field lactose number
---@field paralyze number
---@field ohko number
---@field late number

---@class Entity
---@field movementTime integer
---@field drawHitboxes boolean
---@field drawHitboxPositions boolean
---@field tweenHP boolean
---@field isATB boolean
---@field hideProgressBar boolean
---@field type string
---@field entityName string
---@field baseStats Stats
---@field battleStats Stats
---@field statStages Stats
---@field statuses Status[]
---@field statusResist StatusResists
---@field debuffImmune boolean
---@field lowerAfterSkillUse table
---@field statMods {[string]: integer}
---@field critMult number
---@field skillPool table[]
---@field skill table
---@field selectedSkill table
---@field projectiles table[]
---@field pos table
---@field hbXOffset integer
---@field hbYOffset integer
---@field hitbox {x: integer, y: integer, w: integer, h: integer}
---@field tPos {x: integer, y: integer}
---@field oPos {x: integer, y: integer}
---@field actor table AnimX Actor class
---@field opacity number [0..1]
---@field shadowDims {x: integer, y: integer, w: integer, h:integer}
---@field tweens {[string]: function}
---@field isFocused boolean
---@field targets {characters: Character[], enemies: Enemy[]}
---@field target Entity
---@field targetableEntities Entity[]
---@field hasUsedAction boolean
---@field turnFinish boolean
---@field state string
---@field moveBackTimerStarted boolean
---@field hazards table Placeholder for future Hazard class
---@field ignoreHazards boolean
---@field progressBar ProgressBar
---@field isResumingTurn boolean
---@field tRate number
---@field statStageCap integer
Entity = {}

---@param data table
---@param x integer
---@param y integer
---@param entityType string
function Entity:init(data, x, y, entityType) end

-- Returns a deep copy of the stats table passed into it
---@param stats Stats
---@return Stats
function Entity.copyStats(stats) end

--[[Sets relevant variables to valid turn-state status,
ticks statuses, and begins pb tween if we are in an ATB scheduler]]
function Entity:startTurn() end

--[[Emits an `OnEndTurn` signal after validating the state of the Entity for turn flow]]
---@param duration integer Length of time the tween(s) take
function Entity:endTurn(duration) end

--[[If alive, the Entity moves back to their `oPos`.
Emits an `OnEndTurn` signal after validating the state of the Entity for turn flow]]
---@param duration integer Length of time the tween(s) take
---@param stagingPos? {[string]: number}
---@param tweenType? string
function Entity:endTurn(duration, stagingPos, tweenType) end

-- Makes a copy of the targets (which is still a reference to the Entities)
---@param targets {characters: Character[], enemies: Enemy[]}
function Entity:setTargets(targets) end

-- Resets variables that maintain state during turn flow
function Entity:reset() end

---@param tag string
---@param tween fun()
function Entity:addTween(tag, tween) end

---@param tag string
function Entity:stopTween(tag) end

-- Stops the attack and immediately ends the Entity's turn
function Entity:attackInterrupt() end

---@param t integer?
---@param displacement integer
function Entity:goToStagingPosition(t, displacement) end

---@param duration integer
---@param stagingPos? { [string]: number }
---@param tweenType? string
---@deprecated
function Entity:tweenToStagingPosThenStartingPos(duration, stagingPos, tweenType) end

function Entity:getPos() end

function Entity:getSpeed() end

function Entity:getHealth() end

function Entity:getMaxHealth() end

function Entity:isAlive() end

---@return table
function Entity:getMultdStats() end

---@param stats table
function Entity.setStatStages(stats) end

-- Changes the stat stage of an Entity within the bounds of `[-self.statStageCap .. self.statStageCap]
---@param statName string
---@param stage integer
function Entity:modifyBattleStat(statName, stage) end

-- Called after setting current_stats HP to reflect damage taken during battle
function Entity:resetStatModifiers() end

-- Intended to be called by a skill with a stat-lowering tradeoff
---@param statName string
---@param stage integer
function Entity:lowerAfterSkillResolves(statName, stage) end

-- Checks for immunities, resistances, and current statuses. Then applies a status if possible
---@param status string
function Entity:applyStatus(status) end

-- Procs logic for any tickable statuses the Entity has (burn, poison, sleep)
function Entity:tickStatuses() end

-- Entity wakes up from sleep status
function Entity:wakeUp() end

-- I don't remember what this was intended for.
function Entity:snooze() end

-- Applies a DOT (Damage Over Time) effect
---@param status string
---@param damage integer
function Entity:tickDOT(status, damage) end

-- Checks whether the Entity already has the status
---@param status string
---@return boolean
function Entity:isAlreadyAfflicted(status) end

-- Raises the Entity's resistance to the statuses passed
---@param statuses string[]
---@param amount integer
function Entity:raiseResist(statuses, amount) end

-- After healing the Entity, the `OnHPChanged` signal is emitted
---@param amount integer
function Entity:heal(amount) end

-- Removes ALL statuses from the Entity
function Entity:cleanse() end

-- Removes one status from the Entity
---@param statusToCleanse string
function Entity:cleanseOne(statusToCleanse) end

-- Revives the Entity, handling the animation transition(s)
---@param pct? number (0,1] Percentage of health to revive with
function Entity:revive(pct) end

--[[Deals damage, accounting for defense, critical hit.
Will also transition to a KO'd state if HP falls to 0.]]
---@param amount integer
---@param attackerLuck integer
function Entity:takeDamage(amount, attackerLuck) end

-- Bypasses checks and deals damage directly.
---@param amount integer
function Entity:takeDamagePierce(amount) end

---@param attackerLuck integer
---@return boolean
function Entity:isCrit(attackerLuck) end

--[[Calculates if hit is a critical hit as a function of the attacker's luck and this Entity's luck.
Critical hit chances range is `[1..100]`.]]
---@param attackerLuck integer
---@return number
function Entity:calcCritChance(attackerLuck) end

function Entity:startFainting() end

-- Creates an empty Actor, loops over the paths in `animationData`,
-- creating each animation from its sprite sheet and XML file,
-- then adds it to the Actor
---@param animations string[]
---@param dir string Path to this character's directory
---@return table actor
function Entity:createActor(animations, dir) end

-- TODO: Need handling for animation state diagram (ex: `get_up` -> `idle`)
---@param animations string[] Array of animation names
---@param dir string The directory where animations are located
---@param actor table Reference to the AnimX actor object housing animations
function Entity:createBaseAnimations(animations, dir, actor) end

--[[Creates all skill animations up front from the Entity's skill pool.
Animation state changes are handled in the skill's logic file.
NOTE: Character class should not use this to create animations up front!]]
---@param dir string The directory where animations are located
---@param actor table Reference to the AnimX actor object housing animations
function Entity:createSkillAnimations(dir, actor) end

---@param path string
---@param baseSFXTypes string[]
---@deprecated
function Entity:setSFX(path, baseSFXTypes) end

---@param dt number
function Entity:update(dt) end

-- Adjusts the hitbox offsets and x,y position based on the current animation state
function Entity:updateHitbox() end

function Entity:updateShadow() end

---@param dt number
function Entity:updateProjectiles(dt) end

function Entity:draw() end

function Entity:drawShadow() end

function Entity:drawProjectiles() end

function Entity:drawProgressBar() end

-- ATB Functionality
---@param onComplete fun() Emits OnTurnReady(entity) signal
function Entity:tweenProgressBar(onComplete) end

function Entity:stopProgressBar() end

function Entity:setProgressBarPos() end
