---@param vertices table Reference to vertices on bezier path
---@param x1 number Starting X
---@param y1 number Starting Y
---@param x3 number End X
---@param y3 number End Y
---@param offset integer Pixels in front/behind target to ensure smooth collision
return function(vertices, x1, y1, x3, y3, offset)
  -- Midpoint for first control point
  local mx1, my1 = (x1 + x3)/2, (y1 + y3)/2
  local dx1, dy1 = y3 - y1, x1 - x3
  local distance = math.sqrt(dx1*dx1 + dy1*dy1)
  local curvature = math.min(1, distance / 2)
  dx1, dy1 = (dx1 / distance) * curvature, (dy1 / distance) * curvature

  -- First control point: above midpoint to create arc
  local cp1x, cp1y = mx1 + dx1, my1 + dy1
  table.insert(vertices, cp1x)
  table.insert(vertices, cp1y)

	-- adding first landing point (staged out in front/behind target)
	table.insert(vertices, x3 + offset)
	table.insert(vertices, y3)

  -- Second control point: between staged point and final target
  local mx2, my2 = ((x3 + offset) + x3)/2, (y3 + y3)/2
  local cp2x, cp2y = mx2, my2 - curvature  -- lift in y for smooth drop
  table.insert(vertices, cp2x)
  table.insert(vertices, cp2y)

  -- Final landing point (center of target)
  table.insert(vertices, x3)
  table.insert(vertices, y3)
end;