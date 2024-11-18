--! Animation Frame Counts

local bake_animations = {
  idle = 3,
  moveX = 4,
  moveY = 4,
  moveXY = 4,
  flinch = 6,
  ko = 8
}

local maria_animations = {
  idleFrames = 5,
  moveXFrames = 4,
  moveYFrames = 4,
  moveXYFrames = 4,
  flinchFrames = 6,
  koFrames = 8
}

local marco_animations = {
  idle = 5,
  moveX = 4,
  moveY = 4,
  moveXY = 4,
  flinch = 6,
  ko = 8
}


local key_animations = {
  idleFrames = 5,
  moveXFrames = 4,
  moveYFrames = 4,
  moveXYFrames = 4,
  flinchFrames = 6,
  koFrames = 8
}

local butter_animations = {
  idleFrames = 5,
  moveXFrames = 4,
  moveYFrames = 4,
  moveXYFrames = 4,
  flinchFrames = 6,
  koFrames = 8
}

local line_animations = {
  idle = 10,
  moveX = 10,
  moveY = 10,
  moveXY = 10,
  flinch = 7,
  ko = 7
}


function get_state_animations(entityName)
  if entityName == 'Bake' then
    return bake_animations
  elseif entityName == 'Maria' then
    return maria_animations
  elseif entityName == 'Marco' then
    return marco_animations
  elseif entityName == 'Key' then
    return key_animations
  elseif entityName == 'Butter' then
    return butter_animations
  elseif entityName == 'Line' then
    return line_animations
  end
end;


  
  