--! file: Character
require("skill_sheet")
require("stat_sheet")
require("entity")
Class = require "libs.hump.class"

Team = {}

Character = Class{__includes = Entity,
  init = function(self, stats, skills)
    character = Entity(stats, skills)
    table.insert(Team, character)
  end;
}
bake = Character(get_bake_stats(), get_bake_skills())
marco = Character(get_marco_stats(), get_marco_skills())
maria = Character(get_maria_stats(), get_maria_skills())
key = Character(get_key_stats(), get_key_skills())