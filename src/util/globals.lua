--! filename: globals

-- global variables
SEED = math.randomseed(math.random(1, math.huge))

CHARACTER_TEAM = {}
turnCounter = 1

-- global functions
function saveCharacterTeam(team)
  CHARACTER_TEAM = team
  -- writeTableToJSON(team)
end;

-- function writeTableToJSON(t)
--   local function serialize(t)
--     local result = {}
--     for k, v in pairs(t) do
--       local formattedKey
--       if type(k) == 'string' then
--         formattedKey = string.format('%q', k) -- escape sequence characters
--       else
--         formattedKey = tostring(k)
--       end

--       if type(v) == 'table' then
--         result[#result + 1] = string.format('%s:%s', formattedKey, serialize(v))
--       elseif type(v) == 'string' then
--         result[#result + 1] = string.format('%s:%q', formattedKey, v)
--       elseif type(v) == 'number' or type(v) == 'boolean' then
--         result[#result + 1] = string.format('%s:%s', formattedKey, tostring(v))
--       elseif type(v) == 'userdata' then
--         result[#result + 1] = string.format('%s:%q', formattedKey, tostring(v))
--       else
--         error('Unsupported type: ' .. type(v))
--       end
--     end
--     return '{' .. table.concat(result, ',') .. '}'
--   end
  
--   if type(t) ~= 'table' then
--     error('Expected table, got ' .. type(t))
--   end
--   return serialize(t)
-- end


function loadCharacterTeam()
  return CHARACTER_TEAM
end;

function deepCopy(original)
  local copy
  if type(original) == 'table' then
    copy = {}
    for k,v in pairs(original) do
      copy[k] = deepCopy(v)
    end
  else
    copy = original
  end
  return copy
end;

function sortLayers(T)
	table.sort(T,
		function(first, second)
			return first.layer < second.layer
		end
	)
end

-- current implementation doesn't account for flying attacks
function calcSpacingFromTarget(tweenType, entityType)
  local space = {x = 0, y = 0}
  local isCharacter = entityType == 'character'
  local baseSpace = 120
  
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