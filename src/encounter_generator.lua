--! file: encounter_generator
require('enemy_list')
require('team')

function generateEncounter(floorNum)
  team = Team()
  encounteredPools = {}
  if floorNum < 10 then
    -- Weighted Randomly grab from Enemy Pool 1
    -- TODO : Make this actually weighted rand
    local encounter = math.random(1, 10)
    populateTeam(encounter, team)
    table.insert(encounteredPools, encounter)
  elseif floorNum == 10 then
    -- Randomly grab from Boss Pool 1
    local encounter = math.random(1, 4)
    populateTeam(encounter, team)
    table.insert(encounteredPools, encounter)
  elseif floorNum < 20 then
    -- Weighted Randomly grab from Enemy Pool 2
    -- TODO : Make this actually weighted rand
    local encounter = math.random(11, 20)
    populateTeam(encounter, team)
    table.insert(encounteredPools, encounter)
  elseif floorNum == 20 then
    -- Randomly grab from Boss Pool 2
  
  return team
end;

function populateTeam(encounter, team)
  