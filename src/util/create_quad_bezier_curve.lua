-- Defines a control point between two points and returns the Bezier curve of those 3 points
---@param startX number Starting X
---@param startY number Starting Y
---@param goalX number End X
---@param goalY number End Y
---@param i integer Current point in path
---@param isTopToBottom boolean True if path of curve goes from top to bottom
---@return love.BezierCurve
return function(startX, startY, goalX, goalY, i, isTopToBottom)
  local vertices = {}

  -- Start
  table.insert(vertices, startX); table.insert(vertices, startY);

  -- Control
  local mx,my = (startX + goalX) / 2, (startY + goalY) / 2
  local dx,dy = goalX - startX, goalY - startY
  local distance = math.sqrt(dx*dx + dy*dy)
  local nx,ny = -dy / distance, dx / distance

  -- Ternary operator to decide whether to flip the control point over an axis or not
  local side = (isTopToBottom or (i == 1 and startY > goalY)) and 1 or -1

  -- Cap the arc so it doesn't go too crazy
  local arcStrength = math.min(70, distance / 2)
  local cx,cy = mx + nx * arcStrength * side, my + ny * arcStrength * side
  table.insert(vertices, cx); table.insert(vertices, cy);

  -- End
  table.insert(vertices, goalX); table.insert(vertices, goalY);

  return love.math.newBezierCurve(vertices)
end;