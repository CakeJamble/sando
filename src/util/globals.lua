SEED = math.randomseed(math.random(1, math.huge))

CHARACTER_TEAM = {}

function saveCharacterTeam(team)
  CHARACTER_TEAM = team
end;

function loadCharacterTeam()
  return CHARACTER_TEAM
end;
