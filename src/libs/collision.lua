--! filename: collision

local Collision = {}

-- AABB collision check
function Collision.rectsOverlap(a, b)
    return a.x < b.x + b.w and
           b.x < a.x + a.w and
           a.y < b.y + b.h and
           b.y < a.y + a.h
end

-- Circle collision check
function Collision.circlesOverlap(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local distanceSquared = dx * dx + dy * dy
    local radii = a.radius + b.radius
    return distanceSquared < radii * radii
end

-- Point in rectangle
function Collision.pointInRect(px, py, rect)
    return px >= rect.x and px <= rect.x + rect.w and
           py >= rect.y and py <= rect.y + rect.h
end

-- Point in circle
function Collision.pointInCircle(px, py, circle)
    local dx = px - circle.x
    local dy = py - circle.y
    return dx * dx + dy * dy <= circle.radius * circle.radius
end

-- Generate a jump-adjusted hitbox rectangle
function Collision.getJumpAdjustedRect(baseX, baseY, baseW, baseH, jumpProgress, minH)
    local clampedProgress = math.max(0, math.min(1, jumpProgress))
    local adjustedHeight = baseH - (clampedProgress * (baseH - minH))
    return {
        x = baseX,
        y = baseY - adjustedHeight,
        w = baseW,
        h = adjustedHeight
    }
end

return Collision
