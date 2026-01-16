---@meta

-- Base class that handles the flow between turns during combat.
---@class Scheduler
---@field characterTeam CharacterTeam
---@field enemyTeam EnemyTeam
---@field isBenchEnabled boolean
---@field bench? {character: Character[], enemy: Enemy[]}
---@field combatants { characters: Character[], enemies: Enemy[] }
---@field cameraPosX integer
---@field cameraPosY integer
---@field qteManager QTEManager
---@field combatHazards {characterHazards: table, enemyHazards: table}
---@field signalHandlers table
---@field rewards table
Scheduler = {}

---@param characterTeam CharacterTeam
---@param enemyTeam EnemyTeam
---@param config table
function Scheduler:init(characterTeam, enemyTeam, config) end

function Scheduler:enter() end

---@param name string
---@param f fun(...)
function Scheduler:registerSignal(name, f) end

function Scheduler:removeSignals() end

-- Creates and returns a queue of all the Entities that will participate in this combat.
---@param characterMembers Character[]
---@param enemyMembers Enemy[]
---@return { characters: Character[], enemies: Enemy[] }
function Scheduler:populateCombatants(characterMembers, enemyMembers) end

-- Returns all the living members in combat
---@return { characters:Character[], enemies: Enemy[] }
function Scheduler:getValidTargets() end

---@param duration integer
function Scheduler:resetCamera(duration) end

--[[Removes KO'd entities from battle and returns the longest animation that
needs to be completed before ending the KO sequence.]]
---@param activeEntity? Entity
---@return integer Duration of time for longest faint animation
function Scheduler:removeKOs(activeEntity) end

---@param activeEntity? Entity
---@param koCharacters Character[]
---@param koEnemies Enemy[]
function Scheduler:emitDeathSignals(activeEntity, koCharacters, koEnemies) end

-- Checks if the fight should end. If the player won, transitions to `Reward`.
-- Currently no implementation for handling a loss
---@return boolean
function Scheduler:winLossConsMet() end

---@param dt number
function Scheduler:update(dt) end

function Scheduler:draw() end

