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
   name = "Bake",
   width=80,height=80,
   hp=10,
   fp=10,
   attack=10,
   defense=10,
   speed=10,
   luck=10,
 }
 
 local maria_stats = {
   name = "Maria",
   width=80,height=80,
   hp=10,
   fp=10,
   attack=10,
   defense=10,
   speed=10,
   luck=10,
 }
 
local marco_stats = {
   name = "Marco",
   width=96,height=96,
   hp=10,
   fp=10,
   attack=10,
   defense=10,
   speed=10,
   luck=10,
 }
 
 local key_stats = {
   name = "Key",
   width=80,height=80,
   hp=10,
   fp=10,
   attack=10,
   defense=10,
   speed=10,
   luck=10,
 }
 
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