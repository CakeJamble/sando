--! file: skill_sheet

local marco_skills = {
  basic_attack = {
    name = 'Basic Attack',
    damage = 0,
    damage_type = 'physical',
    target_type = 'single',
    effects = nil,
    proc = nil,
    participants = 'marco',
    sprite_path = "../asset/characters/marco/basic_attack",
    duration = 120,
    qte_window = 20,
    qte_type = "BUTTON_PRESS",
    description = 'Deals physical damage to a single target twice',
  },
  
  score = {
    name = 'Score',
    damage = 5,
    damage_type = 'physical',
    target_type = 'single',
    effects = 'crit',
    proc = 0.6,
    participants = 'marco',
    sprite_path = "../asset/characters/marco/score",
    duration = 300,
    qte_window = 240,
    qte_type = 'STICK_MOVE',
    description = 'Phase behind enemy, dealing physical damage. Higher chance for crititical strike.'
    }
}

local bake_skills = {
  basic_attack = {
    name = 'Basic Attack',
    damage = 0,
    damage_type = 'physical',
    target_type = 'single',
    effects = nil,
    proc = nil,
    participants = 'bake',
    sprite_path = '../asset/characters/bake/basic_attack',
    duration = 60,
    qte_window = 25,
    qte_type = "BUTTON_PRESS",
    description = "Deals physical damage to a single target once"
  }
}

local maria_skills = {
  basic_attack = {
    name = 'Basic Attack',
    damage = 0,
    damage_type = 'physical',
    target_type = 'single',
    effects = nil,
    proc = nil,
    participants = 'maria',
    sprite_path = '../asset/characters/maria/basic_attack',
    duration = 60,
    qte_window = 25,
    qte_type = "BUTTON_PRESS",
    description = "Deals physical damage to a single target once"
  }
}  

local key_skills = {
  basic_attack = {
    name = 'Basic Attack',
    damage = 0,
    damage_type = 'physical',
    target_type = 'multi',
    effects = nil,
    proc = nil,
    participants = 'bake',
    sprite_path = '../asset/characters/key/basic_attack',
    duration = 60,
    qte_window = 25,
    qte_type = "BUTTON_PRESS",
    description = "Deals physical damage to a random target four times"
  }
}


function get_marco_skills() 
  return marco_skills
end
function get_bake_skills()
  return bake_skills
end
function get_maria_skills()
  return maria_skills
end
function get_key_skills()
  return key_skills
end
