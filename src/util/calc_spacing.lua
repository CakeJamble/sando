-- current implementation doesn't account for flying attacks
---@param tweenType string
---@param entityType string
---@return { [string]: number }
return function(tweenType, entityType)
  local space = {x = 0, y = 0}
  local isCharacter = entityType == 'character'
  local baseSpace = 80

  if tweenType == 'near' then
    space.x = baseSpace
  elseif tweenType == 'mid' then
    space.x = 2 * baseSpace
  else -- tweenType == 'far'
    space.x = 3 * baseSpace
  end

  if isCharacter then
    space.x = -1 * space.x
  end

  return space
end;