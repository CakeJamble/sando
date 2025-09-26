-- Defines a control point between two points and returns the Bezier curve of those 3 points
---@param startX number Starting X
---@param startY number Starting Y
---@param goalX number End X
---@param goalY number End Y
---@return love.BezierCurve
return function(startX, startY, goalX, goalY)
  local vertices = {}

  -- Start
  table.insert(vertices, startX); table.insert(vertices, startY);

  -- Control
  local mx,my = (startX + goalX) / 2, (startY + goalY) / 2
  local dx,dy = goalX - startX, goalY - startY
  local distance = math.sqrt(dx*dx + dy*dy)
  local nx,ny = -dy / distance, dx / distance
  local side = -1
  if startY > goalY then side = 1 end

  local arcStrength = math.min(50, distance / 2)
  local cx,cy = mx + nx * arcStrength * side, my + ny * arcStrength * side
  table.insert(vertices, cx); table.insert(vertices, cy);

  -- End
  table.insert(vertices, goalX); table.insert(vertices, goalY);

  return love.math.newBezierCurve(vertices)
end;