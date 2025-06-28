--! filename: TurnStartTool
require('util.globals')
require('class.item.tool')
Class = require 'libs.hump.class'
TurnStartTool = Class{__includes = Tool}

function TurnStartTool:init()
	Tool.init(self)

	Signal.register('OnStartTurn',
		-- Proc the effects of the tool when a turn starts
		function(character)
			-- Handle cases for all OnStartTurn Tools
			if self.name == 'Dairy Pills' then -- cure lactose intolerance
				for i,debuff in pairs(character.debuffs) do
					if debuff.name == 'Lactose Intolerance' then
						table.remove(character.debuffs, i)
					end
				end
			elseif self.name == 'Dress Shirt' then -- if turn counter is 3, 0.3 chance go twice
				if turnCount % 3 == 0 and love.math.random() >= 0.7 then
					character:modifyBattleStat('defense', 1)
				end
			elseif self.name == 'Calendar' then -- Lose 1 HP and deal 4 damage to all enemies
				self.takeDamagePierce(1)
				self.targets.takeDamagePierce(4)
			elseif self.name == 'Mini Whiteboard' then -- Show intents
				for _,target in pairs(character.targets) do
					target.showIntents = true
				end
			elseif self.name == 'Motherly Doll' then -- Cannot be KOd
				character.cannotLose = true
			elseif self.name == 'Deck of Cards' then -- Shuffle FP costs of all skills at start of turn
				local skillList = character.skillList
				for i,skill in pairs(skillList) do
					if i > 1 then -- don't change basic skill
						local j = love.math.random(1, #character.skillList)
						local cost = character.skillList[j].cost
						skillList[i].cost = cost
						table.remove(character.skillList, j)
					end
				end
				character.skillList = skillList
			elseif self.name == 'Work Shoes' then -- Ignore start of turn hazards
				character.ignoreHazards = true
			end
		end
	)
end;