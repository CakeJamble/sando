--! file: stat_sheet

starting_stats = {
  name="",            -- name of character
  width=0,height=0,   -- size of character
  hp=0,
  fp=0,
  attack=0,
  defense=0,
  speed=0,
  luck=0,
 }
 
local bake_stats = {
   entity_name = "Bake",
   width=80,height=80,
   hp=10,
   fp=10,
   attack=10,
   defense=10,
   speed=10,
   luck=10,
 }
 
 local maria_stats = {
   entity_name = "Maria",
   width=80,height=80,
   hp=10,
   fp=10,
   attack=10,
   defense=10,
   speed=10,
   luck=10,
 }
 
local marco_stats = {
   entity_name = "Marco",
   width=96,height=96,
   hp=10,
   fp=10,
   attack=10,
   defense=10,
   speed=10,
   luck=10,
 }
 
 local key_stats = {
   entity_name = "Key",
   width=80,height=80,
   hp=10,
   fp=10,
   attack=10,
   defense=10,
   speed=10,
   luck=10,
 }
 
 local butter_stats = {
   entity_name = "Butter",
   width = 96, height = 96,
   hp = 5,
   attack=5,
   defense=0,
   speed=4,
   luck=0
 }
 
 function get_butter_stats()
   return butter_stats
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