--!: file: tool pool

local toolPool = 
{
    common = {
        {
            toolName = 'Half Muffin',
            description = 'On pickup, increase all members\' HP by 8%',
            flavorText = 'Microwaved to perfection',
            rarity = 'common',
            path = '',
            procType = 'OnPickup',
            proc =  function(characterTeam)
                        for _,member in pairs(characterTeam.members) do
                            member.baseStats['hp'] = member.baseStats['hp'] + (math.ceil(0.08 * member.baseStats['hp']))
                        end
                    end
        },
        {
            toolName = 'Strainer',
            description = 'On pickup, increase all member\'s defense by 1',
            flavorText = 'No clumps',
            rarity = 'common',
            proc =  function(characterTeam)
                        for _,member in pairs(characterTeam.members) do
                            member.baseStats['defense'] = member.baseStats['defense'] + 1
                        end
                    end
        },
        {
            toolName = 'Energy Drink',
            description = 'On pickup, assigned character has a 50% chance to take their turn first',
            flavorText = 'For the baker with nothing left to give',
            rarity = 'common',
            proc =  function(characterTeam)
                        -- signal for choosing a character to go first
                    end
        },
        {
            toolName = 'Smart Watch',
            description = 'PLACEHOLDER',
            flavorText = 'Steps add up',
            rarity = 'common',
            proc = 'PLACEHOLDER'
        },
        {
            toolName = 'Boiled Egg',
            description = 'On pickup, enchant a move of one character with healing',
            flavorText = 'It\'s close to hatching',
            rarity = 'common',
            proc =  function(characterTeam)
                        -- signal for choosing character and move
                    end
        },
        {
            toolName = 'Splatter Guard',
            description = 'Further reduces damage blocked by guarding by a small amount',
            flavorText = 'For the baker with nothing left to give',
            rarity = 'common',
            proc =  function(character)
                        if character.defenseState.bonusApplied then -- if signal if emitted in defense state, we don't need this check
                            character.blockMod = character.blockMod + 1
                        end
                    end
        },
        {
            toolName = 'Water Bottle',
            description = 'On pickup, heal all members and status conditions',
            flavorText = 'Why is it always empty',
            rarity = 'common',
            proc =  function(characterTeam)
                        for _,member in pairs(characterTeam.members) do
                            member:heal(999)
                        end
                    end
        },
        {
            toolName = 'Piping Bag',
            description = 'On pickup, all current Flour Skill costs are reduced by 1 FP',
            flavorText = 'CUSTARD',
            rarity = 'common',
            proc =  function(characterTeam)
                        for _,member in pairs(characterTeam.members) do
                            for i,skill in ipairs(member.skillList) do
                                if i ~= 1 then
                                    skill.cost = math.min(0, skill.cost - 1)
                                end
                            end
                        end
                    end
        },
        {
            toolName = 'Banneton',
            description = 'On pickup, increase FP for all current Flower Skills by 1, and increase their effectiveness',
            flavorText = 'Every boule deserves a viking funeral',
            rarity = 'common',
            proc =  function(characterTeam)
                        for _,member in pairs(characterTeam.members) do
                            for i,skill in ipairs(member.skillList) do
                                if i ~= 1 then
                                    skill.cost = skill.cost + 1
                                    -- TODO: increase effectiveness somehow?
                                end
                            end
                        end
                    end
        },
        {
            toolName = 'Hard Water',
            description = 'On level up, roll a bonus stat reward',
            flavorText = 'Good ole tap water',
            rarity = 'common',
            proc =  function(character)
                        Character.statRollsOnLevel = Character.statRollsOnLevel + 1
                    end;
        },
        {
            toolName = 'Ancient Interface',
            description = 'Your first attack each battle always gets the QTE bonus',
            flavorText = 'There\'s a satisfying clack to the keys',
            rarity = 'common',
            proc =  function(enemy)
                        -- check if turn counter == 1
                        -- grant QTE bonus
                    end
        },
        {
            toolName = 'Misshapen Beignet',
            description = 'Enemies cannot escape',
            flavorText = '???', -- revise
            rarity = 'common',
            proc = 'PLACEHOLDER'
        },
        {
            toolName = 'Dirty Dishes',
            description = 'Slow enemies at the start of battle',
            flavorText = 'The kitchen can\'t move when the sink is full',
            rarity = 'common',
            proc =  function(enemyTeam, characterTeam)
                        for i,enemy in ipairs(enemyTeam) do
                            -- apply slow
                        end
                    end
        },
        {
            toolName = 'Fake Mustache',
            description = 'Basic attacks deal more damage',
            flavorText = 'revise',
            rarity = 'common',
            proc =  function(characterTeam)
                        for _,member in pairs(characterTeam.members) do
                            member.skillList[1].skill.damage = member.skillList[1].skill.damage + 5
                        end
                    end
        },
        {
            toolName = 'Decroded Mitts',
            description = 'You cannot be debuffed during your turn',
            flavorText = 'Heat has worn away the fingertips',
            rarity = 'common',
            proc =  function(skill)
                        -- need some way to grant status invul during attack
                    end
        },
        {
            toolName = 'Dairy Pills',
            description = 'Cures lactose intolerance at the start of your turn',
            flavorText = 'I\'m so bloated',
            rarity = 'common',
            proc =  function(character)
                        for i,debuff in ipairs(character.debuffs) do
                            if debuff.name == 'Lactose Intolerance' then
                                table.remove(character.debuffs, i)
                            end
                        end
                    end
        },
        {
            toolName = 'Dough Hook',
            description = 'Increase damage for each empty or cursed skill slot',
            flavorText = 'It starts with a good mix',
            rarity = 'common',
            proc =  function(skill)
                        -- need some way to get the number of open slots
                        local numFreeSlots = 3 -- for example
                        local bonus = 2
                        skill.damage = skill.damage + (bonus * numFreeSlots)
                        -- make sure skill is reset after turn
                    end
        },
        {
            toolName = 'Basque Cheesecake',
            description = 'Gain additional EXP when defeating burnt enemies',
            flavorText = 'It\'s not burnt! Okay, it is burnt, but it\'s supposed to look like that.',
            rarity = 'common',
            proc =  function(characterTeam, enemyTeam)
                        -- need specific dying enemy for this one to add exp
                    end

        },
        {
            toolName = 'Refurbished Idol',
            description = 'Gain additional money from enemies, equal to your level',
            flavorText = 'Their beauty was a spark that started an ancient war',
            rarity = 'common',
            proc = 'OnKO'   -- need specific dying enemy for this one to add money
        },
        {
            toolName = 'Water Cup',
            description = 'Restore a small amount of FP when you sell equipment',
            flavorText = 'Someone filled it with soda',
            rarity = 'common',
            proc =  function(equip, characterTeam)
                        -- restore slight amount of fp
                    end
        },
        {
            toolName = 'Bottomless Fries',
            description = 'Restore a small amount of HP when purchasing an item',
            flavorText = 'It takes way too long for this to get refilled',
            rarity = 'common',
            proc = function(characterTeam)
                        -- restore slight amount of hp
                    end
        },
        {
            toolName = 'Tip Jar',
            description = 'Get slightly more money when selling accessories',
            flavorText = 'Money goes in, tips come out. You can\'t explain that',
            rarity = 'common',
            proc = 'OnAccSell'
        },
        {
            toolName = 'Chew Toy',
            description = 'Weaken all enemies at the start of battle',
            flavorText = 'Whoever this belonged to loved this thing',
            rarity = 'common',
            proc = 'OnStartBattle'
        },
        {
            toolName = 'Dress Shirt',
            description = 'Every 3 turns, the team members have a slight chance to extra damage',
            flavorText = 'Lets you make a first impression twice!',
            rarity = 'common',
            proc =  function(character)
                        if turnCount % 3 == 0 and love.math.random() >= 0.7 then
                            character:modifyBattleStat('defense', 1)
                        end
                    end
        },
        {
            toolName = 'Calendar',
            description = 'Start of turn, lose 1 HP every turn and deal 4 damage to all enemies',
            flavorText = 'Closed on Mondays and Tuesdays',
            rarity = 'common',
            proc =  function(character)
                        character:takeDamagePierce(1)
                        character.targets:takeDamagePierce(4)
                    end
        },
        {
            toolName = 'Grease of Ruin',
            description = 'Grounded enemies have a small chance to have their attack lowered after attacking',
            flavorText = 'Non-slip shoes required',
            rarity = 'common',
            proc =  function(enemy)
                        local chance = 0.25
                        if love.math.random() <= chance then
                            enemy:takeDamagePierce(2)
                        end
                    end
        },
        {
            -- idea: change to on learning a new skill?
            toolName = 'Dragonscale Ring',
            description = 'Take half damage from recoil',
            flavorText = 'Cool to the touch',
            rarity = 'common',
            proc =  function(skill)
                        -- check if skill has recoil
                        -- if skill has recoil, then halve recoil amount
                        -- reset recoil damage after
                    end
        },
        {
            toolName = 'Bansho Fan',
            description = 'Enemies spread statuses to adjacent enemies on defeat',
            flavorText = 'A single swing wiped out a great fire, along with the castle that was burning',
            rarity = 'common',
            proc = 'OnKO'
        },
        {
            toolName = 'Land Cucumber',
            description = 'On defeating a character, attacking enemies take damage equal to damage they dealt',
            flavorText = 'Like a cornered mouse',
            rarity = 'common',
            proc = 'OnDefeat'
        },
        {
            toolName = 'Display Loaf',
            description = 'Attacks with a base power under 5 deal extra damage',
            flavorText = 'The crumb structure reveals the fine attention paid to the details in the baking process',
            rarity = 'common',
            proc = 'OnAttack'
        },
        {
            toolName = 'Bread Board',
            description = 'Paralysis has no effect on speed',
            flavorText = 'Why was this here?',
            rarity = 'common',
            proc = 'OnDebuffed'
        },
        {
            toolName = 'LOVE',
            description = 'Gain an additional small amount of gold at the end of each battle for each surviving team member',
            flavorText = 'We take care of our own here',
            rarity = 'common',
            proc = 'OnEndBattle'
        },
        {
            toolName = 'Blindfold of the Unburdened',
            description = 'At the start of battle, characters without equipment or accessories have higher crit chance and speed',
            flavorText = 'See without eyes',
            rarity = 'common',
            proc = 'OnStartBattle'
        },
        {
            toolName = 'Pita',
            description = 'A random team member starts each battle with burn',
            flavorText = 'Take the evil you know over the evils you don\'t',
            rarity = 'common',
            proc = 'OnStartBattle'
        },
    },

    uncommon = {
        {
            toolName = 'Charging Cable',
            description = 'Level ups double the FP restored',
            flavorText = 'If the phone dies, all the recipes go with it',
            rarity = 'uncommon',
            proc = 'OnLevelUp'
        },
        {
            toolName = 'Face Roller',
            description = 'Blocking physical attacks nullifies status effect procs',
            flavorText = 'Keeping up the streak enhances dough structure',
            rarity = 'uncommon',
            proc = 'OnBlock'
        },
        {
            toolName = 'Sunscreen',
            description = 'You can no longer be burned',
            flavorText = 'PA+++++',
            rarity = 'uncommon',
            proc = 'OnDebuffed'
        },
        {
            toolName = 'Mini Whiteboard',
            description = 'Enemy intents are visible',
            flavorText = 'It\'s full of percentages',
            rarity = 'uncommon',
            proc =  function(character)
                        for _,target in pairs(character.targets) do
                            target.showIntents = true
                        end
                    end
        },
        {
            toolName = 'Coffee Mug',
            description = 'On pickup, gain 2 consumable slots',
            flavorText = 'A milky blob remains where a shakily drawn tulip once existed',
            rarity = 'uncommon',
            proc =  function(characterTeam)
                        characterTeam.inventory.numConsumableSlots = characterTeam.inventory.numConsumableSlots + 2
                    end
        },
        {
            toolName = 'Milk Pitcher',
            description = 'Using a consumable increases you Max HP slightly',
            flavorText = 'It chirps with the sound of milk being stretched',
            rarity = 'uncommon',
            proc = 'OnConsumableUse'
        },
        {
            toolName = 'Meat Press',
            description = 'Deal more damage to vulnerable enemies',
            flavorText = 'It\'s just a small cast iron pan',
            rarity = 'uncommon',
            proc = 'OnAttack'
        },
        {
            toolName = 'Mummified Grapes',
            description = 'Summoned enemies start weakened',
            flavorText = 'Raisins?',
            rarity = 'uncommon',
            proc = 'OnSummon'
        },
        {
            toolName = 'Soft Water',
            description = 'On pickup, cleanse all curses',
            flavorText = 'The good stuff. Only for the dough, not for us',
            rarity = 'uncommon',
            proc =  function(characterTeam)
                        for _,member in pairs(characterTeam.members) do
                            member:cleanse()
                        end
                    end
        },
        {
            toolName = 'Coffee Puck',
            description = 'Get 3 random consumables',
            flavorText = 'Rock solid, showing signs of overextraction',
            rarity = 'uncommon',
            proc =  function(characterTeam)
                        -- generate 3 random consumables
                        -- spawn window/interface to display them
                        -- have player take all/some/none
                    end
        },
        {
            toolName = 'Thermometer',
            description = 'At the start of battle, inflict vulnerable on all enemies',
            flavorText = 'For tracking, and giving up on tracking, fermentation',
            rarity = 'uncommon',
            proc = 'OnStartBattle'
        },
        {
            toolName = 'Crushed Can',
            description = 'Gain additional money at the end of combat',
            flavorText = 'Hi! Me 5¢ ;P',
            rarity = 'uncommon',
            proc = 'OnEndBattle'
        },
        {
            toolName = 'Pizza Spire',
            description = 'Swapping party members restores a small amount of FP',
            flavorText = 'One of our chefs left to slay this, but never returned',
            rarity = 'uncommon',
            proc = 'OnSwapMembers'
        },
        {
            toolName = 'Portafilter',
            description = 'An additional consumable is found after every battle',
            flavorText = 'Massive, thick, heavy, and far too rough',
            rarity = 'uncommon',
            proc = 'OnEndBattle'
        },
        {
            toolName = 'Preserved Pastry',
            description = 'Basic Attacks deal more damage when FP is below 25%',
            flavorText = 'Made with Ancient Grains',
            rarity = 'uncommon',
            proc = 'OnAttack'
        },
        {
            toolName = 'Potted Plant',
            description = 'You get a free luck roll on every level up',
            flavorText = 'It\'s plastic, but the mental health benefits are undeniable',
            rarity = 'uncommon',
            proc = 'OnLevelUp'
        },
        {
            toolName = 'Desecrated Idol',
            description = 'On pickup, lose half your money and convert this into a Refurbished Idol',
            flavorText = 'It is sealed in what appears to be wax',
            rarity = 'uncommon',
            proc =  function(characterTeam)
                        characterTeam.inventory:spend(math.floor(self.characterTeam.inventory.money / 2))
                        -- need to figure out how to insert into the list from here
                        -- table.insert(self.pickupToolList, PickupTool(Refurbished Idol dictionary))
                        -- Signal.emit('OnPickup', refurbishedIdol)
                    end
        },
        {
            toolName = 'Shutter Key',
            description = 'Heal slightly at the beginning of battles',
            flavorText = 'Unlocks a place to cool off between shifts',
            rarity = 'uncommon',
            proc = 'OnStartBattle'
        },
        {
            toolName = 'Parking Permit',
            description = 'Cannot be stunned',
            flavorText = 'Valid only in Lot 4, except on cloudy Thursdays after 5pm',
            rarity = 'uncommon',
            proc = 'OnDebuffed'
        },
        {
            toolName = 'Cat Teaser',
            description = 'On Level Up, roll an additional bonus for Speed',
            flavorText = 'More feathers is more fun',
            rarity = 'uncommon',
            proc = 'OnLevelUp'
        },
        {
            toolName = 'Points Card',
            description = 'Insufficient FP for a skill is supplemented by using HP',
            flavorText = 'It\'s warm to the touch',
            rarity = 'uncommon',
            proc = 'OnTargetConfirm'
        },
        {
            toolName = 'Folded Filter',
            description = 'On consumable use, lower a random stat one stage and then raise a different stat two stages',
            flavorText = 'Great coffee requires sacrifices',
            rarity = 'uncommon',
            proc = 'OnConsumableUse'
        },
        {
            toolName = 'Stolen Rug',
            description = 'The first shop item you purchase is free, then all prices are raised by 1.5x in that shop',
            flavorText = 'The rug was not for sale',
            rarity = 'uncommon',
            proc = 'OnPurchase'
        },
    },

    rare = {
        {
            toolName = 'Pastry Brush',
            description = 'Doubles Crit Chance for skills with crit bonuses',
            flavorText = 'Delicate, elegant, egg-washed',
            rarity = 'rare',
            proc = 'OnQTESuccess'
        },
        {
            toolName = 'Floury Marker',
            description = 'Removing a curse also heals a small amount of HP',
            flavorText = 'It\'s caked in flour, but still writes just fine',
            rarity = 'rare',
            proc = 'OnCurseCleanse'
        },
        {
            toolName = 'Double Helix',
            description = 'Adds +1 to multihit attacks',
            flavorText = 'One strand short of a beautiful braid. The first strand-like tool',
            rarity = 'rare',
            proc = 'OnSkillSelected'
        },
        {
            toolName = 'To-Go Bag',
            description = 'You gain slightly more EXP from battles',
            flavorText = 'The name is illegible',
            rarity = 'rare',
            proc = 'OnEndBattle'
        },
        {
            toolName = 'Proofer',
            description = 'Elites have less Base HP',
            flavorText = 'It\'s warm and humid inside, the dough is relaxing',
            rarity = 'rare',
            proc = 'OnStartBattle'
        },
        {
            toolName = 'Picnic Basket',
            description = 'On pickup, rest',
            flavorText = 'There are crumbs on it from last time, they look edible',
            rarity = 'rare',
            proc =  function(characterTeam)
                        characterTeam:rest()
                    end
        },
        {
            toolName = 'Croissant Flakes',
            description = 'Consumables are slightly more effective',
            flavorText = 'Saving them for later',
            rarity = 'rare',
            proc = 'OnConsumableUse'
        },
        {
            toolName = 'Scraper',
            description = 'Adds +40% to crit bonuses',
            flavorText = 'Never leave home without it',
            rarity = 'rare',
            proc = 'OnQTESuccess'
        },
        {
            toolName = 'Everything Seasoning',
            description = 'On pickup, copy a skill of any character to another character',
            flavorText = 'A beautiful dress for a perfect bagel',
            rarity = 'rare',
            proc =  function(characterTeam)
                        -- get skill from a character
                        -- choose character to receive skill
                        -- paste skill
                        -- remove preexisting skill if slot is full
                    end
        },
        {
            toolName = 'Motherly Doll',
            description = 'You cannot be KOd during your turn',
            flavorText = 'You can do this better than mama',
            rarity = 'rare',
            proc =  function(character)
                        character.cannotLose = true
                    end
        },
        {
            toolName = 'Deck of Cards',
            description = 'At the start of your turn, shuffle the FP costs of all skills',
            flavorText = 'It\'s full of jokers',
            rarity = 'rare',
            proc =  function(character)
                        local skillList = character.skillList
                        for i,skill in ipairs(skillList) do
                            if i > 1 then -- don't change basic skill
                                local j = love.math.random(1, #character.skillList)
                                local cost = character.skillList[j].cost
                                skillList[i].cost = cost
                                table.remove(character.skillList, k)
                            end
                        end
                        character.skillList = skillList
                    end
        },
        {
            toolName = 'Loaf Loader',
            description = 'On pickup, one character can learn any skill',
            flavorText = 'The bread shinkanse',
            rarity = 'rare',
            proc =  function(characterTeam)
                        -- choose character
                        -- choose skill
                        -- paste skill
                        -- remove preexisting skill if slot is full
                    end
        },
        {
            toolName = 'Pot of Ghee',
            description = 'Buffs are more effective',
            flavorText = 'Clarity',
            rarity = 'rare',
            proc = 'OnTargetConfirm'
        },
        {
            toolName = 'Work Shoes',
            description = 'Grants immunity to start of turn hazards',
            flavorText = 'The secure feeling of non-slip shoes fills you with determination',
            rarity = 'rare',
            proc =  function(character)
                        character.ignoreHazards = true
                    end
        },
        {
            toolName = 'Canvas Tote',
            description = 'Gain an additional accessory slot',
            flavorText = 'Simple but effective',
            rarity = 'rare',
            proc =  function(characterTeam)
                        -- choose a character
                        -- add accessory slot to one character
                    end
        },
        {
            toolName = 'Cold Brew Pitcher',
            description = '+5% Crit chance whenever you gain speed',
            flavorText = 'It\'s just a pitcher, but it\'s been called on for greater purposes',
            rarity = 'rare',
            proc = 'OnBuff'
        },
        {
            toolName = 'Memory Foam Mattress',
            description = 'Healing skills are more effective',
            flavorText = 'This is my hole! It was made for me!',
            rarity = 'rare',
            proc = 'OnTargetConfirm'
        },
        {
            toolName = 'Whetstone',
            description = 'Restore a small amount of FP when an enemy raises their stats',
            flavorText = 'Caught them monologuing',
            rarity = 'rare',
            proc = 'OnBuff'
        },
        {
            toolName = 'Sticky Notes',
            description = 'On team member KO, the enemy\'s stats are all decreased by one stage',
            flavorText = 'It\'s full of logins and passwords',
            rarity = 'rare',
            proc = 'OnDefeat'
        },
        {
            toolName = 'Tardy Treat',
            description = 'At the start of battle, slow a random teammate for 2 turns, then boost all of their stats one stage on turn 3',
            flavorText = 'You were late, but you did the right thing',
            rarity = 'rare',
            proc = 'OnStartBattle'
        },
    },

    event = {
        {
            toolName = 'Meat Grinder',
            description = 'Enemies in the next 3 encounters have 1 HP',
            flavorText = 'Good prep pays off',
            rarity = 'event',
            proc = 'OnStartBattle'
        },
        {
            toolName = 'Electric Kettle',
            description = 'On entering a shop, restore a moderate amount of HP',
            flavorText = 'DO NOT run this when the dish washer is going',
            rarity = 'event',
            proc = 'OnEnterShop'
        },
        {
            toolName = 'Necronominom',
            description = 'On selling an equipment, a random equipment becomes more effective',
            flavorText = 'It hungers',
            rarity = 'event',
            proc = 'OnEquipSell'
        },
        {
            toolName = 'Azzi Manuscript',
            description = 'You are more likely to find uncommon and rare accessories',
            flavorText = 'A survival guide for the pixel world',
            rarity = 'event',
            proc =  function(characterTeam)
                        -- increase base uncommon and rare chance for accessories
                    end
        },
        {
            toolName = 'Tassajara Bread Book',
            description = 'You are more likely to find uncommon and rare equipment',
            flavorText = 'The pages are worn and well-loved',
            rarity = 'event',
            proc =  function(characterTeam)
                        -- increase base uncommon and rare chance for equipment
                    end
        },
        {
            toolName = 'Levain of Theseus',
            description = 'Summoned enemies spawn with addiitonal health, but reward more EXP and money',
            flavorText = 'Is this the same levain that it was last week?',
            rarity = 'event',
            proc = 'OnSummon'
        },
        {
            toolName = 'Puff\'s Codex',
            description = 'The first consumable you use each battle goes off twice',
            flavorText = 'A cookbook from a distant kingdom that loves mushrooms',
            rarity = 'event',
            proc = 'OnConsumableUse'
        },
        {
            toolName = 'Massage Gun',
            description = 'Speed modifiers also affect critical chance',
            flavorText = 'Revitalizes muscles to the strength of the First Generation',
            rarity = 'event',
            proc = 'OnBuff'
        },
        {
            toolName = 'Shoe Charm',
            description = 'Attacks have an cosmetic affect added',
            flavorText = 'So cute!',
            rarity = 'event',
            proc = 'OnAttack'
        },
        {
            toolName = 'Test Oracle',
            description = 'You quack at the start of battle, reducing stats randomly across enemies',
            flavorText = 'It cannot speak, but when you ask for help, you receive the guidance you were seeking',
            rarity = 'event',
            proc = 'OnStartBattle'
        },
        {
            toolName = 'Lin\'s Insurance',
            description = 'On stats being lowered, gain a small amount of money',
            flavorText = 'Who would have thought we would need fire insurance in a bakery?',
            rarity = 'event',
            proc = 'OnDebuffed'
        },
        {
            toolName = 'Lin\'s Ledger',
            description = 'When a stat is lowered, raise a random stat of another teammate',
            flavorText = 'A skilled baker can even cook the books',
            rarity = 'event',
            proc = 'OnDebuffed'
        },
        {
            toolName = 'Vampire Fangs',
            description = 'Set Max HP to 50%. Attacks lifesteal for 25% of damage dealt',
            flavorText = 'Makes it harder to eat bread',
            rarity = 'event',
            proc =  function(characterTeam)
                        -- choose character
                        -- give vampirism effect
                    end
        }

    },
    shop = {
        {
            toolName = 'Recipe Book',
            description = 'Team members gain EXP even when they are KOd',
            flavorText = 'Full of drawings and messy handwriting',
            rarity = 'shop',
            proc = 'OnEndBattle'
        },
        {
            toolName = 'Baking Soda',
            description = 'Taking damage has a chance to remove burn',
            flavorText = 'Expired',
            rarity = 'shop',
            proc = 'OnDamaged'
        },
        {
            toolName = 'Cinnamon Roll Center',
            description = 'On pickup, choose a character. They dodge multihit attacks automatically.',
            flavorText = 'It spins unceasingly, observing the enemy',
            rarity = 'shop',
            proc =  function(characterTeam)
                        -- choose character
                        -- give dodgeMultihit ability
                    end
        },
        {
            toolName = 'Coffee Tamper',
            description = 'On pickup, a random character gains an additional skill slot',
            flavorText = 'Packs tightly, with even pressure across the surface of the portafilter',
            rarity = 'shop',
            proc =  function(characterTeam)
                        local i = love.math.random(1, #characterTeam.members)
                        -- increase number of skill slots by 1
                    end
        },
        {
            toolName = 'Ambiguous Furniture',
            description = 'Increase base chance of item rarities',
            flavorText = 'A popular item for completionists',
            rarity = 'shop',
            proc =  function(characterTeam)
                        -- increase base chance of item rarities
                    end
        },
        {
            toolName = 'Shiny Pyramid',
            description = 'On pickup, shuffe the skill pools of all team members',
            flavorText = 'The paralysis of choice',
            rarity = 'shop',
            proc =  function(characterTeam)
                        -- shuffle skill pools of all team members
                            -- swap entire pools, or skills all swapped individually at random?
                    end
        },
        {
            toolName = 'Forgotten Placeholder',
            description = 'Escaping enemies become vulnerable',
            flavorText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
            rarity = 'shop',
            proc = 'OnEscape'
        },
    }
}

function GetToolPool()
    return toolPool
end;

function GetCommonToolPool()
    return toolPool.common
end;

function GetUncommonToolPool()
    return toolPool.uncommon
end;

function GetRareToolPool()
    return toolPool.rare
end;

function GetEventToolPool()
    return toolPool.event
end;

function GetShopToolPool()
    return toolPool.shop
end;
