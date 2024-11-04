--! file: encounter_generator
require('enemy_list')
require('entity')
require('enemy')
require('team')
require('gamestates/game')

-- Need to port over map generation techniques for weighted random creation of encounters!!!
function generateEncounter(floorNum)
  enemyTeam = Team()
  encounteredPools = {}
  if floorNum < 10 then
    -- Weighted Randomly grab from Enemy Pool 1
    -- TODO : Make this actually weighted rand
    local encounter = math.random(1, #enemyPool1)
    populateTeam(encounter, enemyTeam)
    table.insert(encounteredPools, encounter)
  elseif floorNum == 10 then
    -- Randomly grab from Boss Pool 1
    local encounter = math.random(1, #bossPool1)
    populateTeam(encounter, enemyTeam)
    table.insert(encounteredPools, encounter)
  elseif floorNum < 20 then
    -- Weighted Randomly grab from Enemy Pool 2
    -- TODO : Make this actually weighted rand
    local encounter = math.random(1, #enemyPool2)
    populateTeam(encounter, enemyTeam)
    table.insert(encounteredPools, encounter)
  elseif floorNum == 20 then
    local encounter = math.random(1, #bossPool2)
    populateTeam(encounter, enemyTeam)
    
-- PLEASE BEGIN HERE comment from 10/31/2024
  end
  return enemyTeam
end;

-- Grabs team from pools listed below
-- NOTE: completely random, needs refacor. Just for testing loading of enemies for now
function populateTeam(encounter, newTeam)
  for i=1,encounter do
    -- need a way to dynamically generate an enemy from just a name??
    -- local enemy = Enemy
end;

-- Create tables for encounter pools
enemyPool1 = {
  {
    'Sortilla',
    'Reggie',
  },
  
  {
    'Line'
  },
  
  {
    'Goki',
    'Dasbunny'
  }
}

  