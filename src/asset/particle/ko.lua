--[[
module = {
	x=emitterPositionX, y=emitterPositionY,
	[1] = {
		system=particleSystem1,
		kickStartSteps=steps1, kickStartDt=dt1, emitAtStart=count1,
		blendMode=blendMode1, shader=shader1,
		texturePreset=preset1, texturePath=path1,
		shaderPath=path1, shaderFilename=filename1,
		x=emitterOffsetX, y=emitterOffsetY
	},
	[2] = {
		system=particleSystem2,
		...
	},
	...
}
]]
local LG        = love.graphics
local particles = {x=16, y=-76.5}

local image1 = LG.newImage("asset/particle/star.png")
image1:setFilter("nearest", "nearest")

local ps = LG.newParticleSystem(image1, 24)
ps:setColors(0.235595703125, 0.2109375, 1, 1, 0.24609375, 1, 0.27554321289063, 1, 1, 0.32421875, 0.87857055664063, 0.5, 0.95407104492188, 1, 0.16015625, 1)
ps:setDirection(-1.5707963705063)
ps:setEmissionArea("none", 0, 0, 0, false)
ps:setEmissionRate(38.54349899292)
ps:setEmitterLifetime(0.59110248088837)
ps:setInsertMode("random")
ps:setLinearAcceleration(0.01115504372865, -0.90355855226517, -0.10039539635181, -0.01115504372865)
ps:setLinearDamping(0.048010379076004, 6.2394285202026)
ps:setOffset(50, 50)
ps:setParticleLifetime(0.27562499046326, 0.68062502145767)
ps:setRadialAcceleration(0.022310087457299, -0.022310087457299)
ps:setRelativeRotation(false)
ps:setRotation(-0.97074609994888, 3.1145722866058)
ps:setSizes(0.080025315284729, 0.11674000322819, 0.026115139946342)
ps:setSizeVariation(0.50479233264923)
ps:setSpeed(64.584785461426, 130.73626708984)
ps:setSpin(1.6222501993179, 0)
ps:setSpinVariation(0.57507985830307)
ps:setSpread(4.6076693534851)
ps:setTangentialAcceleration(-106.2183303833, 16.264053344727)
table.insert(particles, {system=ps, kickStartSteps=0, kickStartDt=0, emitAtStart=0, blendMode="add", shader=nil, texturePath="star.png", texturePreset="star", shaderPath="", shaderFilename="", x=0, y=0})

return particles
