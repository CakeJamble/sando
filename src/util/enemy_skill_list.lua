--! filename: Enemy Skill List

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

}


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
  return lineSkills
end;

