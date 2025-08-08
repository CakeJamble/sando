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
local particles = {x=32.792076977526, y=1.1932426932523}

local image1 = LG.newImage("asset/particle/lightBlur.png")
image1:setFilter("nearest", "nearest")
local image2 = LG.newImage("asset/particle/light.png")
image2:setFilter("nearest", "nearest")

local ps = LG.newParticleSystem(image1, 218)
ps:setColors(1, 1, 1, 0.087719298899174, 0.42105263471603, 0.72576177120209, 1, 0.80000001192093, 1, 0.97063714265823, 0.4421052634716, 0.72280699014664, 1, 0.3789473772049, 0, 0)
ps:setDirection(-1.4020462036133)
ps:setEmissionArea("none", 0, 0, 0, false)
ps:setEmissionRate(369.7809753418)
ps:setEmitterLifetime(-1)
ps:setInsertMode("top")
ps:setLinearAcceleration(0, 0, 0, 0)
ps:setLinearDamping(0, 0)
ps:setOffset(60, 60)
ps:setParticleLifetime(0.28070175647736, 0.56140351295471)
ps:setRadialAcceleration(0, 0)
ps:setRelativeRotation(false)
ps:setRotation(0, 0)
ps:setSizes(0.042623475193977)
ps:setSizeVariation(0)
ps:setSpeed(2.4701690673828, 97.194007873535)
ps:setSpin(0, 0)
ps:setSpinVariation(0)
ps:setSpread(0.22046263515949)
ps:setTangentialAcceleration(0, 0)
table.insert(particles, {system=ps, kickStartSteps=0, kickStartDt=0, emitAtStart=0, blendMode="add", shader=nil, texturePath="lightBlur.png", texturePreset="lightBlur", shaderPath="", shaderFilename="", x=0, y=0})

local ps = LG.newParticleSystem(image2, 60)
ps:setColors(1, 1, 1, 0, 1, 1, 1, 0.30303031206131, 1, 1, 1, 0.37878787517548, 1, 1, 1, 0.068181820213795, 1, 1, 1, 0)
ps:setDirection(-1.4020462036133)
ps:setEmissionArea("none", 0, 0, 0, false)
ps:setEmissionRate(35.140586853027)
ps:setEmitterLifetime(-1)
ps:setInsertMode("top")
ps:setLinearAcceleration(0, 0, 0, 0)
ps:setLinearDamping(0, 0)
ps:setOffset(75, 75)
ps:setParticleLifetime(1.1214953660965, 1.6199376583099)
ps:setRadialAcceleration(0, 0)
ps:setRelativeRotation(false)
ps:setRotation(0, 0)
ps:setSizes(0.034525014460087)
ps:setSizeVariation(0)
ps:setSpeed(10.799334526062, 102.91010284424)
ps:setSpin(0, 0)
ps:setSpinVariation(0)
ps:setSpread(0.24250890314579)
ps:setTangentialAcceleration(0, 0)
table.insert(particles, {system=ps, kickStartSteps=0, kickStartDt=0, emitAtStart=0, blendMode="subtract", shader=nil, texturePath="light.png", texturePreset="light", shaderPath="", shaderFilename="", x=0, y=0})

return particles
