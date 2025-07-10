--! file: stat_sheet
require('util.skill_sheet')

starting_stats = {
  entityName="",            -- name of character
  width=0,height=0,   -- size of character
  hp=0,
  fp=0,
  attack=0,
  defense=0,
  speed=0,
  luck=0,
  skillList = nil
 }
 
local bake_stats = {
   entityName = "Bake",
   width=64,height=64,
   hp=10,
   fp=10,
   attack=10,
   defense=2,
   speed=10,
   luck=10,
   skillList = get_bake_skills()
 }
 
 local maria_stats = {
   entityName = "Maria",
   width=80,height=80,
   hp=10,
   fp=10,
   attack=10,
   defense=10,
   speed=10,
   luck=10,
   skillList = get_maria_skills()
 }
 
local marco_stats = {
   entityName = "Marco",
   width=96,height=96,
   hp=10,
   fp=10,
   attack=10,
   defense=1,
   speed=20,
   luck=10,
   skillList = get_marco_skills()
 }
 
 local key_stats = {
   entityName = "Key",
   width=80,height=80,
   hp=10,
   fp=10,
   attack=10,
   defense=10,
   speed=10,
   luck=10,
   skillList = get_key_skills()
 }
 
local starting_character_stats = {
  bake_stats,
  marco_stats,
  maria_stats,
  key_stats
}

function get_char_stats(index)
  return starting_character_stats[index]
end;
function get_bake_stats()
  return bake_stats
end
function get_maria_stats()
  return maria_stats
end
function get_marco_stats()
  return marco_stats
end
function get_key_stats()
  return key_stats
end