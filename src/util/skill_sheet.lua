--! file: skill_sheet

local skillTypes = {
  'BUTTON_PRESS',
  'STICK_MOVE',
}

local marco_skills = {
  {
    skill_name = 'Basic Attack',
    damage = 0,
    damage_type = 'physical',
    target_type = 'single',
    effects = nil,
    proc = nil,
    cost = 0,
    attack_type = 'solo',
    partners = nil,
    sprite_path = "asset/sprites/entities/character/marco/basic.png",
    duration = 70,
    qte_window = {55, 65},
    qte_type = "SINGLE_BUTTON_PRESS",
    qte_bonus_type = 'damage',
    qte_bonus = 1,
    description = 'Deals physical damage to a single target twice',
    instructions = 'Press A just before landing the attack!',
    unlock = nil,
    sound_path = 'asset/audio/entities/character/marco/basic.wav'
  },

  {
    skill_name = 'Score',
    damage = 5,
    damage_type = 'physical',
    target_type = 'single',
    effects = 'crit',
    proc = 0.6,
    cost = 3,
    attack_type = 'solo',
    partners = nil,
    sprite_path = "asset/sprites/entities/character/marco/basic.png",    --FIXME LATER
    duration = 300,
    qte_window = 240,
    qte_type = 'STICK_MOVE',
    qte_bonus = 1,
    description = 'Phase behind enemy, dealing physical damage. Higher chance for crititical strike.',
    unlock = nil,
    sound_path = 'asset/audio/entities/character/marco/basic.wav'
  }
}

local bake_skills = {
  {
    skill_name = 'Basic Attack',
    damage = 0,
    damage_type = 'physical',
    target_type = 'single',
    effects = nil,
    proc = nil,
    cost = 0,
    attack_type = 'solo',
    partners = nil,
    sprite_path = 'asset/sprites/entities/character/bake/basic.png',
    duration = 70,
    qte_window = {45, 65},
    qte_type = "SINGLE_BUTTON_PRESS",
    qte_bonus_type = 'damage',
    qte_bonus = 1,
    description = "Deals physical damage to a single target once",
    instructions = '',
    unlock = nil,
    sound_path = 'asset/audio/entities/character/marco/basic.wav'
  }
  
}

local maria_skills = {
  {
    skill_name = 'Basic Attack',
    damage = 0,
    damage_type = 'physical',
    attack_type = 'solo',
    target_type = 'single',
    effects = nil,
    proc = nil,
    cost = 0,
    partners = nil,
    sprite_path = 'asset/sprites/entities/character/maria/basic.png',
    duration = 60,
    qte_window = 25,
    qte_type = "BUTTON_PRESS",
    description = "Deals physical damage to a single target once",
    unlock = nil,
    sound_path = 'asset/audio/entities/character/marco/basic.wav'
  }
}  

local key_skills = {
  {
    skill_name = 'Basic Attack',
    damage = 0,
    damage_type = 'physical',
    attack_type = 'solo',
    target_type = 'multi',
    effects = nil,
    proc = nil,
    cost = 0,
    partners = nil,
    sprite_path = 'asset/sprites/entities/character/key/basic.png',
    duration = 60,
    qte_window = 25,
    qte_type = "BUTTON_PRESS",
    description = "Deals physical damage to a random target four times",
    unlock = nil,
    sound_path = 'asset/audio/entities/character/marco/basic.wav'
  }
}

function getSkillTypes()
  return skillTypes
end;
  
function get_marco_skills() 
  local marcoSkills = {}
  for i=1,#marco_skills do
    marcoSkills[i] = Skill(marco_skills[i], 96, 96)
  end
  return marcoSkills
end

function get_bake_skills()
  local bakeSkills = {}
  for i=1,#bake_skills do
    bakeSkills[i] = Skill(bake_skills[i], 64, 64)
  end
  return bakeSkills
end
function get_maria_skills()
  local mariaSkills = {}
  for i=1,#maria_skills do
    mariaSkills[i] = Skill(maria_skills[i], 80, 80)
  end
  return mariaSkills
end
function get_key_skills()
  local keySkills = {}
  for i=1,#key_skills do
    keySkills[i] = Skill(key_skills[i], 80, 80)
  end
  return keySkills
end
