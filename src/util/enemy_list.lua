--! filename: enemy list
require('util.enemy_skill_list')
-- WARNING : STATS ARE PLACE HOLDERS BESIDES NAME AND ENTITY TYPE

-- trying with nested tables because we want to do random encounters
local enemyTable = {  
  {
    entityName="Boba",
    entityType="Enemy",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },

  {
    entityName="Boole",
    entityType="Enemy",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
  {
    entityName = "Sortilla",
    entityType = "Enemy",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
  {
    entityName = "Reggie",
    entityType = "Enemy",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
  {
    entityName = "Goki",
    entityType = "Enemy",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
  {
    entityName = "Line",
    entityType = "Enemy",
    width=80,height=80,
    hp=11,
    cr=2,
    attack=10,
    defense=10,
    speed=5,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = getLineSkills()
  },
  
  {
    entityName = "Pain",
    entityType = "Enemy",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
  {
    entityName = "Dour Flour",
    entityType = "Enemy",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
  {
    entityName = "Pinny",
    entityType = "Enemy",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
  {
    entityName = "Dasbuny",
    entityType = "Enemy",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
  {
    entityName = "Crusty",
    entityType = "Enemy",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
  {
    entityName = "Helly",
    entityType = "Enemy",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
  {
    entityName = "OiOil",
    entityType = "Enemy",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
  {
    entityName = "Carrakot",
    entityType = "Enemy",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
  {
    entityName = "Glutopus",
    entityType = "Enemy",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
  {
    entityName = "Biscuit",
    entityType = "Enemy",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
  {
    entityName = "Clogg Cog",
    entityType = "Enemy",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
  {
    entityName = "Kit",
    entityType = "Enemy",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  }
}

    
local eliteTable = {
  {
    entityName = "Buttler",
    entityType = "Elite",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = getButtlerSkills()
  },
  
  {
    entityName = "Egg Wash",
    entityType = "Elite",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
  {
    entityName = "Mischi",
    entityType = "Elite",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
  {
    entityName = "Vanitay",
    entityType = "Elite",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
  {
    entityName = "Mama",
    entityType = "Elite",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
  {
    entityName = "Papa",
    entityType = "Elite",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
  {
    entityName = "Peter",
    entityType = "Elite",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
  {
    entityName = "Dewsi",
    entityType = "Elite",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
  {
    entityName = "Donatsu",
    entityType = "Elite",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
  {
    entityName = "Marasa",
    entityType = "Elite",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },

}

local bossTable = {
  {
    entityName = "Hae",
    entityType = "Boss",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
  {
    entityName = "Veji",
    entityType = "Boss",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
   {
    entityName = "Daikoku",
    entityType = "Boss",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
   {
    entityName = "Buglun",
    entityType = "Boss",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
  
   {
    entityName = "Spira",
    entityType = "Boss",
    width=80,height=80,
    hp=10,
    cr=2,
    attack=10,
    defense=10,
    speed=10,
    luck=10,
    experienceReward = 10,
    moneyReward = 8,
    skillList = nil
  },
}

function getAllEnemies() --> Table of Tables
  return enemyTable
end;

function getAllElites() --> Table of Tables
  return eliteTable
end;

function getAllBosses() --> Table of Tables
  return bossTable
end;

-- Returns enemy/elite/boss through array-like access
function getAt(index, enemyType) --> Table
  if(enemyType == 'Enemy') then
    return enemyTable[index]
  elseif(enemyType == 'Elite') then
    return eliteTable[index]
  else
    return bossTable[index]
  end
end;

-- Returns enemy/elite/boss through linear search with associated name
function getStatsByName(enemyName, enemyType) --> Table
  if(enemyType == 'Enemy') then
    -- go through enemy table and find match
    for i,v in ipairs(enemyTable) do
      if(v['entityName'] == enemyName) then
        return v
      end
    end
  elseif(enemyType == 'Elite') then
    -- go through elite table and find match
    for i,v in ipairs(eliteTable) do
      if(v['entityName'] == enemyName) then
        return v
      end
    end
  else
    -- go through boss table and find match
    for i,v in ipairs(bossTable) do
      if(v['entityName'] == enemyName) then
        return v
      end
    end
  end
  
  return nil    -- critical error
end;

