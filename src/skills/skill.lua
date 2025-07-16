-- see data.skills.README.md for documentation on skill data

local function newSkill(data)
  return {
    name            = data.name,
    damage          = data.damage,
    isOffensive 		= data.isOffensive,
    targetType 			= data.targetType,
    effects         = data.effects,
    chance          = data.chance or 0,
    cost            = data.cost,
    spritePath      = data.spritePath,
    soundPath       = data.soundPath,
    duration        = data.duration,
    stagingTime     = data.stagingTime,
    stagingType     = data.stagingType,
    qteType         = data.qteType,
    qteBonus        = data.qteBonus,
    description     = data.description,
    unlockedAtLvl		= data.unlockedAtLvl,
    beginTweenType  = data.beginTweenType,
    returnTweenType = data.returnTweenType,
    isDodgeable     = data.isDodgeable,
    hasProjectile   = data.hasProjectile,
    proc            = data.proc
  }
end

return newSkill
