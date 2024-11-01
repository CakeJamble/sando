--! file: encounter_generator
require('enemy_list')
require('team')

-- Need to port over map generation techniques for weighted random creation of encounters!!!
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
-- PLEASE BEGIN HERE comment from 10/31/2024
  end
  return team
end;

-- Grabs team from pools listed below
function populateTeam(encounter, team)
end;

-- Create tables for encounter pools
