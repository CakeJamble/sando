--! tool_manager

Class = require 'libs.hump.class'
ToolManager = Class{}

function ToolManager:init(characterTeam)
	self.toolList = {}
	self.startTurnToolList = {}
	self.pickupToolList = {}
	self.characterTeam = characterTeam

	Signal.register('OnStartTurn',
		-- Proc the effects of Turn Start Tools
		function(character)
			for i,tool in pairs(self.startTurnToolList) do
			-- Handle cases for all OnStartTurn Tools
			if tool.name == 'Dairy Pills' then -- cure lactose intolerance
				for j,debuff in pairs(character.debuffs) do
					if debuff.name == 'Lactose Intolerance' then
						table.remove(character.debuffs, j)
					end
				end
			elseif tool.name == 'Dress Shirt' then -- if turn counter is 3, 0.3 chance go twice
				if turnCount % 3 == 0 and love.math.random() >= 0.7 then
					character:modifyBattleStat('defense', 1)
				end
			elseif tool.name == 'Calendar' then -- Lose 1 HP and deal 4 damage to all enemies
				character:takeDamagePierce(1)
				character:targets.takeDamagePierce(4)
			elseif tool.name == 'Mini Whiteboard' then -- Show intents
				for _,target in pairs(character.targets) do
					target.showIntents = true
				end
			elseif tool.name == 'Motherly Doll' then -- Cannot be KOd
				character.cannotLose = true
			elseif tool.name == 'Deck of Cards' then -- Shuffle FP costs of all skills at start of turn
				local skillList = character.skillList
				for j,skill in pairs(skillList) do
					if j > 1 then -- don't change basic skill
						local k = love.math.random(1, #character.skillList)
						local cost = character.skillList[k].cost
						skillList[j].cost = cost
						table.remove(character.skillList, k)
					end
				end
				character.skillList = skillList
			elseif tool.name == 'Work Shoes' then -- Ignore start of turn hazards
				character.ignoreHazards = true
			end
		end
	)

	-- OnPickup Tools only proc once, so they pass self as an argument to manager
	Signal.register('OnPickup',
		function(tool)
			if tool.name == 'Half Muffin' then -- +8% to all members Base HP
				for _,member in self.characterTeam.members do
					member.baseStats['hp'] += (math.ceil(0.08 * member.baseStats['hp']))
				end
			elseif tool.name == 'Strainer' then -- +1 to all members Base Defense
				for _,member in self.characterTeam.members do
					member.baseStats['defense'] += 1
				end
			elseif tool.name == 'Energy Drink' then -- character gains a 50% chance to go first every turn
				self:chooseCharacter(tool, 'goFirst')
			elseif tool.name == 'Boiled Egg' then -- one move gains healing effect
				self:chooseCharacter(tool, 'enchantMoveWithHeal')
			elseif tool.name == 'Water Bottle' then -- cleanse and heal all characters (nerf me)
				for _,member in pairs(self.characterTeam.members) do
					member:heal(999)
					--TODO: Cleanse statuses (statuses/debuffs not implemented yet)
				end
			elseif tool.name == 'Piping Bag' then -- Reduce cost of FP skills by 1FP
				for _,member in pairs(self.characterTeam.members) do
					for i,skill in ipairs(member.skillList) do
						skill.cost = math.min(0, skill.cost - 1)
					end
				end
			elseif tool.name == 'Banneton' then -- Increase cost of FP skills by 1FP, and make them better
				for _,member in pairs(self.characterTeam.members) do
					for i,skill in ipairs(member.skillList) do
						if i ~= 1 then -- don't increase cost of basic attack
							skill.cost = skill.cost + 1
						end
						-- TODO: Make every skill more effective (?)
					end
				end
			elseif tool.name == 'Fake Mustache' then -- basic attack deals more damage
				for _,member in pairs(self.characterTeam.members) do
					member.skillList[1].skill.damage = member.skillList[1].skill.damage + 5
				end
			elseif tool.name == 'Coffee Mug' then -- Gain 2 consumable slots
				self.character.inventory.numConsumableSlots = self.character.inventory.numConsumableSlots + 2
			elseif tool.name == 'Soft Water' then
				for _,member in pairs(self.characterTeam) do
					member:cleanse()
				end
			elseif tool.name == 'Coffee Puck' then
				-- generate 3 random consumables
				-- spawn window to show 3 consumable items
				-- allow player to take them
			elseif tool.name == 'Desecrated Idol' then
				self.characterTeam.inventory:spend(math.floor(self.characterTeam.inventory.money / 2))
				-- table.insert(self.pickupToolList, PickupTool(Refurbished Idol dictionary))
				-- Signal.emit('OnPickup', refurbishedIdol)
			elseif tool.name == 'Picnic Basket' then -- Rest
				self.characterTeam:rest()
			elseif tool.name == 'Everything Seasoning' then -- Copy skill
				local skill = self:copySkill()
				-- choose character
				-- paste skill
			elseif tool.name == 'Loaf Loader' then
				self:chooseCharacter(tool, 'learnAnySkill')
			elseif tool.name == 'Canvas Tote' then
				-- add accessory slot to one character
			elseif tool.name == 'Azzi Manuscript' then
				-- increase uncommon and rare base chance for accessories
			elseif tool.name == 'Tassajara Bread Book' then
				-- increase uncommon and rare base chance for equipment
			elseif tool.name == 'Vampire Fangs' then
				self:chooseCharacter(tool, 'vampirism')
			elseif tool.name == 'Cinnamon Roll Center' then
				self:chooseCharacter(tool, 'dodgeMultihit')
			elseif tool.name == 'Coffee Tamper' then
				local i = love.math.random(1, #self.characterTeam.members)
				-- increase number of skill slots by 1
			elseif tool.name == 'Ambiguous Furniture' then
				-- increase base chance of item rarities
			elseif tool.name == 'Shiny Pyramid' then
				-- shuffle skill pools of all team members
					-- swap them randomly, or shuffle each skill randomly??
			end
		end
	)
end;

--[[Present the prompt for the player to choose which character they will apply the buff to.
Once selected, apply the buff and close the prompt.]]
function ToolManager:chooseCharacter(tool, buff)
	--do
end;

function ToolManager:update(dt)
	for _,tool in pairs(self.toolList) do
		tool:update(dt)
	end
end;

function ToolManager:draw()
	for _,tool in pairs(self.toolList) do
		tool:draw()
	end
end;