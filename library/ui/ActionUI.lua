---@meta

-- This class needs another refactor to cut out the redundant member variables
---@class ActionUI
---@field ICON_SPACER integer
---@field X_OFFSET integer
---@field Y_OFFSET integer
---@field TARGET_CURSOR_PATH string
---@field active boolean
---@field x integer
---@field y integer
---@field pos {x: integer, y: integer}
---@field actionButton string
---@field numTargets integer
---@field uiState string
---@field iconSpacer integer
---@field targetableEntities Entity[]
---@field skillList table[]
---@field selectedSkill table
---@field selectedItem table
---@field soloButton SoloButton
---@field flourButton FlourButton
---@field duoButton DuoButton
---@field itemButton ItemButton
---@field backButton BackButton
---@field passButton PassButton
---@field easeType string
---@field buttons Button[]
---@field activeButton Button
---@field targets {characters: Character[], enemies: Enemy[] }
---@field targetType string
---@field tIndex integer
---@field targetCursor love.Image
---@field buttonTweenDuration number
---@field buttonDims {w: integer, h: integer }
---@field landingPositions {x: integer, y: integer, scale: number}[]
ActionUI = {}

-- The ActionUI position (self.x, self.y) is at the coordinates of the center of the button wheel
---@param charRef Character
---@param characterMembers Character[]
---@param enemyMembers Enemy[]
function ActionUI:init(charRef, characterMembers, enemyMembers) end

---@param characterMembers Character[]
---@param enemyMembers Enemy[]
function ActionUI:setTargets(characterMembers, enemyMembers) end

---@param charRef Character
function ActionUI:set(charRef) end

---@return table[]
function ActionUI:setButtonLandingPositions() end

-- button indexes and layers get changed before this tween goes off, so we know where they will land
function ActionUI:tweenButtons() end

function ActionUI:unset() end

function ActionUI:deactivate() end

-- Issue: This function should check for button press before the other checks
---@param dt number
function ActionUI:update(dt) end

function ActionUI:draw() end