local ProjectileUtils = {}

---@param data { path: string, width: integer, height: integer, duration: number, stillSprite: string|nil }
---@return {spriteSheet: love.Image, quads: love.Quad, duration: number, currentTime: number, still: love.Image|nil} animation
ProjectileUtils.createProjectileAnimations = function(data)
	local image = love.graphics.newImage(data.path)
	local height, width = data.height, data.width
	local animation = {}
	animation.spriteSheet = image
	animation.quads = {}

	for y = 0, image:getHeight() - height, height do
		for x = 0, image:getWidth() - width, width do
			table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
		end
	end

	animation.duration = data.duration or 1
	animation.currentTime = 0
	animation.spriteNum = 0

	if data.stillSprite then
		local still = love.graphics.newImage(data.stillSprite)
		animation.still = still
	end

	return animation
end;

---@param projectilesData { path: string, width: integer, height: integer, duration: number, stillSprite: string|nil }[]
---@return {spriteSheet: love.Image, quads: love.Quad, duration: number, currentTime: number, still: love.Image|nil}[] projectiles Animations for each projectile, indexed by projectile name
ProjectileUtils.initProjectiles = function(projectilesData)
	local projectiles = {}
	for name,projectileData in pairs(projectilesData) do
		local projectile = ProjectileUtils.createProjectileAnimations(projectileData)
		projectiles[name] = projectile
	end

	return projectiles
end;

return ProjectileUtils