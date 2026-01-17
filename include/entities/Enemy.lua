---@meta

---@class Enemy: Entity
---@field xPos integer
---@field yPos integer
---@field yOffset integer
---@field enemyType string `common`, `elite`, or `boss`
---@field expReward integer
---@field moneyReward integer
---@field lootReward {[string]: number}
---@field procAI function
---@field sfx SoundManager
---@field phaseData table Current phase of Enemy. Nil if not a multiphase Enemy
local Enemy = {}

---@param data table
function Enemy:init(data) end

-- Sets valid targets
---@param targets { [string]: Entity[] }
---@param targetType string
function Enemy:setTargets(targets, targetType) end

-- WIP Basic piercing damage with disappearing on KO
---@param amount integer
function Enemy:takeDamagePierce(amount) end

-- WIP Basic fainting
function Enemy:startFainting() end

---@param rewardsDistribution integer[]
---@return { [string]: integer}
function Enemy.setRewardsDistribution(rewardsDistribution) end

--[[Uses behavior tree defined in their logic file to select an action on their turn.
After an action is selected, emits the `TargetConfirm` signal.]]
---@param validTargets table{ characters: Character[], enemies: Enemy[] }
function Enemy:setupOffense(validTargets) end

-- Initiates a phase change when conditions are met
function Enemy:checkPhase() end

---@deprecated
---@param targetType string
---@param  isSingleTarget boolean
function Enemy:targetSelect(targetType, isSingleTarget) end

---@deprecated Should be using ai logic files (or decision trees)
---@param skillPool table
---@param numValidTargets integer
function Enemy.getRandomSkill(skillPool, numValidTargets) end

---@return table
function Enemy:getRewards() end