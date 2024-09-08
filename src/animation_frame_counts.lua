--! Animation Frame Counts

local bake_animations = {
  idle_frames = 5,
  move_x_frames = 4,
  move_y_frames = 4,
  move_xy_frames = 4,
  flinch_frames = 6,
  ko_frames = 8
}

local maria_animations = {
  idle_frames = 5,
  move_x_frames = 4,
  move_y_frames = 4,
  move_xy_frames = 4,
  flinch_frames = 6,
  ko_frames = 8
}

local marco_animations = {
  idle_frames = 5,
  move_x_frames = 4,
  move_y_frames = 4,
  move_xy_frames = 4,
  flinch_frames = 6,
  ko_frames = 8
}


local key_animations = {
  idle_frames = 5,
  move_x_frames = 4,
  move_y_frames = 4,
  move_xy_frames = 4,
  flinch_frames = 6,
  ko_frames = 8
}

local butter_animations = {
  idle_frames = 1
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
  end
end;


  
  