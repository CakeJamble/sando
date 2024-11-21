--! filename: Enemy Skill List
require('util.enemy_list')
local placeholderSkillList = {}

function getplaceholderSkillList()
  return placeholderSkillList
end;

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
  

-- Deprecated, enemy_list dictionaries call the direct enemy skill list getter instead of this linear lookup
-- result of change : O(n^2) -> O(n). Solved because we know the assoc. skill list when we instantiate an enemy.
function getSkillsByName(enemyName, enemyType) --> Table
  if(enemyType == 'Enemy') then
    -- go through enemy table and find match
    local enemyTable = getAllEnemies()
    for i,v in ipairs(enemyTable) do
      if(v['enemyName'] == enemyName) then
        return v
      end
    end
  elseif(enemyType == 'Elite') then
    -- go through elite table and find match
    local eliteTable = getAllElites()
    for _,v in pairs(eliteTable) do
      if(v['enemyName'] == enemyName) then
        return v
      end
    end
  else
    -- go through boss table and find match
    local bossTable = getAllBosses()
    for i,v in ipairs(bossTable) do
      if(v['enemyName'] == enemyName) then
        return v
      end
    end
  end
  
  return nil    -- critical error
end;


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

