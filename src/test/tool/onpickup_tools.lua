local T = require('libs.knife.test')
local loadCharacterData = require('util.character_loader')
local Character = require('class.entities.character')
local CharacterTeam = require('class.entities.character_team')
local loadItem = require('util.item_loader')
local json = require('libs.json')

T('Given a Character Team', function(T)
	local bake = Character(loadCharacterData('bake'), 'a')
	local marco = Character(loadCharacterData('marco'), 'x')
	local team = CharacterTeam({bake, marco})

	T('Load every Tool', function(T)
		local OnPickup = {}
		local pref = 'data/item/tool/'
		local rawCommon = love.filesystem.read(pref .. 'common_pool.json')
		local rawUncommon = love.filesystem.read(pref .. 'uncommon_pool.json')
		local rawRare = love.filesystem.read(pref .. 'rare_pool.json')
		local rawEvent = love.filesystem.read(pref .. 'event_pool.json')
		local rawShop = love.filesystem.read(pref .. 'shop_pool.json')

		local common = json.decode(rawCommon)
		local uncommon = json.decode(rawUncommon)
		local rare = json.decode(rawRare)
		local event = json.decode(rawEvent)
		local shop = json.decode(rawShop)
		local toolPools = {common = common, uncommon = uncommon, rare = rare,
			event = event, shop = shop}

		for pool,toolNames in pairs(toolPools) do
			for _,toolName in ipairs(toolNames) do
				local tool = loadItem(toolName, 'tool')
				if tool and tool.signal == 'OnPickup' then
						table.insert(OnPickup, tool)
				end
			end
		end

		-- Make sure every OnPickup tool has a proc() definition
		local toolManager = team.inventory.toolManager
		for _,tool in ipairs(OnPickup) do
			local status, err = pcall(function() toolManager:addItem(tool) end)
			T:assert(status, "OnPickup proc failed for tool: " .. tool.name .. "\nError: " .. tostring(err))
		end
	end)
end)