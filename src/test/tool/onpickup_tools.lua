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

	T('Load every OnPickup Tool', function(T)
		local OnPickup = {}
		local pref = 'data/item/tool/'
		local rawCommon = love.filesystem.read(pref .. 'common_pool.json')
		local rawUncommon = love.filesystem.read(pref .. 'uncommon_pool.json')
		local rawRare = love.filesystem.read(pref .. 'rare_pool.json')

		local common = json.decode(rawCommon)
		local uncommon = json.decode(rawUncommon)
		local rare = json.decode(rawRare)
		local toolPools = {common = common, uncommon = uncommon, rare = rare}

		for pool,toolNames in pairs(toolPools) do
			for _,toolName in ipairs(toolNames) do
				local success, tool = pcall(function() loadItem(toolName, 'tool') end)
				T:assert(success, "Failed to load tool: " .. toolName .. "\nError: " .. tostring(tool))
				if success and tool and tool.signal == "OnPickup" then
					table.insert(OnPickup, tool)
				end
			end
		end

		T('Then proc each OnPickup tool by adding to Inventory')
		local toolManager = team.inventory.toolManager
		for _,tool in ipairs(OnPickup) do
			local status, err = pcall(function() toolManager:addItem(tool) end)
			T:assert(status, "OnPickup proc failed for tool: " .. tool.name .. "\nError: " .. tostring(err))
		end
	end)
end)