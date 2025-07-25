--! filename: Enemy Skill List
local Collision = require 'libs.collision'

local baguetteSkills = {
  {
    skill_name = 'Basic Attack',
    damage = 0,
    damage_type = 'physical',
    attack_type = 'solo',
    target_type = 'single',
    effects = nil,
    proc = nil,
    partners = nil,
    sprite_path = nil,
    is_dodgeable = true,
    is_projectile = false
  },
  
  {
    skill_name = 'Roll',
    damage = 0,
    damage_type = 'physical',
    attack_type = 'solo',
    target_type = 'team',
    effects = nil,
    proc = nil,
    partners = nil,
    sprite_path = nil,
    is_dodgeable = true,
    is_projectile = false
  },
  
  {
    skill_name = 'Missile',
    damage = 5,
    damage_type = 'physical',
    attack_type = 'solo',
    target_type = 'single',
    effects = "crit",
    proc = 0.2,
    partners = nil,
    sprite_path = nil,
    is_dodgeable = true,
    is_projectile = false
  },
}

local briocheSkills = {
  {
    skill_name = 'Basic Attack',
    damage = 0,
    damage_type = 'physical',
    attack_type = 'solo',
    target_type = 'single',
    effects = nil,
    proc = nil,
    partners = nil,
    sprite_path = nil,
    is_dodgeable = true,
    is_projectile = false
  },
  
  {
    skill_name = 'Sticky Buns',
    damage = 0,
    damage_type = 'physical',
    attack_type = 'solo',
    target_type = 'single',
    effects = "steal_money",
    proc = 1,
    partners = nil,
    sprite_path = nil,
    is_dodgeable = true,
    is_projectile = false
  },
}

local buttlerSkills = {
  {
    skill_name = 'Basic Attack',
    damage = 0,
    damage_type = 'physical',
    attack_type = 'solo',
    target_type = 'single',
    effects = nil,
    proc = nil,
    partners = nil,
    sprite_path = nil,
    is_dodgeable = true,
    is_projectile = false
  },
  
  {
    skill_name = 'Butter Roll',
    damage = 0,
    damage_type = 'physical',
    attack_type = 'solo',
    target_type = 'multihit_random',
    effects = 'slip',
    proc = 1,
    partners = nil,
    sprite_path = nil,
    is_dodgeable = true,
    is_projectile = true
  },
  
  { -- this one will need some more programming logic to implement :/
    skill_name = 'Butter Wave',
    damage = 0,
    damage_type = 'physical',
    attack_type = 'solo',
    target_type = 'single',
    effects = 'slip',
    proc = 1,
    partners = nil,
    sprite_path = nil,
    is_dodgeable = true,
    is_projectile = true
  },
  
}

local croissantSkills = {
  {
    skill_name = 'Basic Attack',
    damage = 0,
    damage_type = 'physical',
    attack_type = 'solo',
    target_type = 'single',
    effects = nil,
    proc = nil,
    partners = nil,
    sprite_path = nil,
    is_dodgeable = true,
    is_projectile = false
  },
  
  {
    skill_name = 'Mini Croissant Throw',
    damage = 0,
    damage_type = 'physical',
    attack_type = 'solo',
    target_type = 'multihit_random',
    effects = nil,
    proc = nil,
    partners = nil,
    sprite_path = nil,
    is_dodgeable = true,
    is_projectile = true
  },
  
  {
    skill_name = 'Summon Damande',
    damage = 0,
    damage_type = 'summon',
    attack_type = 'solo',
    target_type = 'self',
    effects = 'proc *= 0.5',
    proc = 1,
    partners = nil,
    sprite_path = nil,
    is_dodgeable = true,
    is_projectile = false
  },
  
}

local lineSkills = {
  -- {
  --   skill_name = 'Basic Attack',
  --   damage = 0,
  --   damage_type = 'physical',
  --   attack_type = 'solo',
  --   target_type = 'single',
  --   effects = nil,
  --   proc = nil,
  --   partners = nil,
  --   sprite_path = nil,
  --   is_dodgeable = false,
  --   is_projectile = false,
  --   sprite_path = 'asset/sprites/entities/Enemy/Line/basic.png',
  --   duration = 60,
  --   qte_window = {5, 59},
  --   sound_path = 'asset/audio/entities/character/marco/basic.wav'
  -- },
  {
    skill_name = 'Charge',
    damage = 0,
    damage_type = 'physical',
    attack_type = 'solo',
    target_type = 'single',
    effects = nil,
    partners = nil,
    is_dodgeable = true,
    is_projectile = false,
    sprite_path = 'asset/sprites/entities/Enemy/Line/basic.png',
    duration = 0.5,
    qte_window = nil,
    stagingTime = 1,
    stagingPos = 'near',
    sound_path = 'asset/audio/entities/character/marco/basic.wav',
    proc =  function(ref) -- is this going to need a ref to the entity proc'ing the skill?
              local duration = 0.5
              local goalX, goalY = ref.tPos.x, ref.tPos.y
              local stagingPos = {x = ref.pos.x, y = ref.pos.y}
              local delay = 0.5
              local tweenType = 'linear'
              local hasCollided = false
              local damage = 0 + ref.battleStats['attack']

              -- Attack by charging from right to left
              flux.to(ref.pos, duration, {x = goalX - 80, y = goalY}):ease('linear')
                :onupdate(function()
                  if not hasCollided and Collision.rectsOverlap(ref.hitbox, ref.target.hitbox) then
                    print('collision detected')
                    ref.target:takeDamage(damage)
                    hasCollided = true
                  end
                end)
                :oncomplete(function() tweenToStagingPosThenStartingPos(ref.pos, stagingPos, ref.oPos, duration, delay, tweenType) end)
            end
  }
}

--[[ After a skill is completed, if the current position is different from the staging pos,
  tween back to the staging pos. Then after a short delay, tween back to where
  the skill user started the turn. Then return control to the turn manager
]]
function tweenToStagingPosThenStartingPos(pos, stagingPos, oPos, duration, delay, tweenType)
  flux.to(pos, duration, {x = stagingPos.x, y = stagingPos.y}):after(
    pos, duration, {x = oPos.x, y = oPos.y}):delay(delay):oncomplete(
    function()
      Signal.emit('NextTurn')
    end)
end

function getButtlerSkills()
  return buttlerSkills
end;

function getCroissantSkills()
  return croissantSkills
end;

function getBaguetteSkills()
  return baguetteSkills
end;

function getBriocheSkills()
  return briocheSkills
end;

function getLineSkills()
  local skills = {}
  for i=1,#lineSkills do
    skills[i] = Skill(lineSkills[i], 80, 80)
  end
  return skills
end;

