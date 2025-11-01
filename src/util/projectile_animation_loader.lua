local ProjectileUtils = {}

---@param data table { path: string, width: integer, height: integer, duration: number }
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
	-- animation.spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads)

	local still = love.graphics.newImage(data.stillSprite)
	animation.still = still

	return animation
end;

---@param projectilesData table[] { path: string, width: integer, height: integer, duration: number }
---@return table[] A table of animations for each projectile, indexed by projectile name
ProjectileUtils.initProjectiles = function(projectilesData)
	local projectiles = {}
	for _,projectileData in ipairs(projectilesData) do
		local name = projectileData.name
		local projectile = createProjectileAnimations(projectileData)
		projectiles[name] = projectile
	end

	return projectiles
end;

return ProjectileUtils