--! filename: enemy list

function GenerateEnemy(name, enemyType, health, cr, attack, defense, speed, luck)
  return {
    "name" = name,
    "enemyType" = enemyType,
    "HP" = health,
    "CR" = cr,
    "Attack" = attack,
    "Defense" = defense,
    "Speed" = speed,
    "Luck" = luck
  }
end;

