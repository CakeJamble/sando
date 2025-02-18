SEED = math.randomseed(math.random(1, math.huge))

CHARACTER_TEAM = {}

function saveCharacterTeam(team)
  CHARACTER_TEAM = team
  writeToJSON(team)
end;

function writeTableToJSON(t)
  local function serialize(t)
    local result = {}
    for k,v in pairs(t) do
      local formattedKey
      if type(k) == 'string' then
        formattedKey = string.format('%q', k) -- esc seq. characters
      else
        formattedKey = tostring(key)
      end
      
      if type(v) == 'table' then
        result[#result + 1] = string.format('%s:%s', formattedKey, serialize(v))
      elseif type(v) == 'string' then
        result[#result + 1] = string.format('%s:%q', formattedKey, v)
      elseif type(v) == 'number' or type(v) == 'boolean' then
        result[#result + 1] = string.format('%s:%s', formattedKey, tostring(v))        
      else
        error('not type table, string, or number. If this is a custom data type, check that you have implemented a serialize fcn in the class: ' .. type(v))
      end
    end
    return '{' .. table.concat(result, ',') .. '}'
  end;
  
  if type(t) ~= 'table' then
    error('not a table')
  end
  return serialize(t)
end;

function loadCharacterTeam()
  return CHARACTER_TEAM
end;

function deepCopy(original)
  local copy
  if type(orig) == 'table' then
    copy = {}
    for k,v in pairs(orig) do
      copy[k] = deepCopy(v)
    end
  else
    copy = orig
  end
  return copy
end;
