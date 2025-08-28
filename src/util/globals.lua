--! filename: globals

-- global variables
SEED = math.randomseed(math.random(1, math.huge))

CHARACTER_TEAM = {}
turnCounter = 1

statStageCap = 6

-- global functions
---@param team Team
function saveCharacterTeam(team)
  CHARACTER_TEAM = team
end;

---@return CharacterTeam
function loadCharacterTeam()
  return CHARACTER_TEAM
end;

---@param original table
---@return table
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

---@param T table
function sortLayers(T)
	table.sort(T,
		function(first, second)
			return first.layer > second.layer
		end
	)
end

-- current implementation doesn't account for flying attacks
---@param tweenType string
---@param entityType string
---@return { [string]: number }
function calcSpacingFromTarget(tweenType, entityType)
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