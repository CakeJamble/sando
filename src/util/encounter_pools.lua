--! file: encounter_generator
require('util.enemy_list')
require('class.entities.entity')
require('class.entities.enemy')
require('class.entities.character_team')
require('class.entities.enemy_team')

testPool = { 
  {'Line', 'Line'}, 
  {'Line'}
}

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
enemyPool2 = {
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


elitePool1 = {
  {
    'Mama',
    'Papa',
  },
  
  {
    'Buttler',
    'Crusty',
    'Crusty',
  },
  
  {
    'Mischi',
    'Boba',
    'Boba',
    'Boba',
  }
}

bossPool1 = {
  {
    'Hae',
  },
  
  {
    'Veji',
    'Reji',
  },
  
  {
    'Buglun',
  }
  
}

bossPool2 = {
  {
    'Daikoku',
  },
  
  {
    'Spira',
  }
}

  