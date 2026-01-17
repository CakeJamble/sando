---@meta

---@class Projectile
---@field drawHitboxes boolean
---@field pos {x: integer, y: integer, r: number}
---@field hitbox {x: integer, y: integer, w: integer, h: integer}
---@field ox integer
---@field oy integer
---@field shadowPos {x: integer, y: integer, w: integer, h: integer}
---@field tweens table
---@field castsShadow boolean
---@field index integer
---@field isStill boolean
Projectile = {}

---@param x integer
---@param y integer
---@param w integer
---@param h integer
---@param castsShadow boolean
---@param index integer
---@param animation table { spriteSheet: love.Image, quads: love.Quad, duration: integer, currentTime: number, spriteNum: integer, still: love.Image }
function Projectile:init(
    x, y, w, h,
     castsShadow, index, animation) end

---@param duration integer
---@param targetYPos integer
function Projectile:tweenShadow(duration, targetYPos) end

---@param tweenKey string
function Projectile:interruptTween(tweenKey) end

---@param dt number
function Projectile:update(dt) end

function Projectile:draw() end

function Projectile:drawShadow() end

function Projectile:drawHitbox() end