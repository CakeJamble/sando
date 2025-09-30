local ItemRandomizer = require('util.item_randomizer')
local Signal = require('libs.hump.signal')

-- Signal: OnPickup
---@param characterTeam CharacterTeam
return function(characterTeam)
	local bonus = characterTeam.rarityMod
	local itemType = {"consumable"}
	local itemPools = {"common", "uncommon", "rare"}
	local rarities = {uncommon = 0.3 + bonus, rare = 0.1 + bonus}
	local consumables = ItemRandomizer.getRandomItems(3, itemType, itemPools, rarities)

	local function onDecision(choice)
		characterTeam.inventory:addConsumable(choice)
	end

	Signal.emit("ShowOfferUI", consumables, onDecision)
end;