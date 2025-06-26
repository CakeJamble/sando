--!: file: tool pool

local toolPool = 
{
    common = {
        {
            toolName = 'Half Muffin',
            description = 'On pickup, increase all members\' HP by 8%',
            flavorText = 'Microwaved to perfection',
            rarity = 'common'
        },
        {
            toolName = 'Strainer',
            description = 'On pickup, increase all member\'s defense by 1',
            flavorText = 'No clumps',
            rarity = 'common'
        },
        {
            toolName = 'Energy Drink',
            description = 'On pickup, assigned character has a 50% chance to take their turn first',
            flavorText = 'For the baker with nothing left to give',
            rarity = 'common',
        },
        {
            toolName = 'Smart Watch',
            description = 'PLACEHOLDER',
            flavorText = 'Steps add up',
            rarity = 'common',
        },
        {
            toolName = 'Boiled Egg',
            description = 'On pickup, enchant a move of one character with healing',
            flavorText = 'It\'s close to hatching',
            rarity = 'common',
        },
        {
            toolName = 'Splatter Guard',
            description = 'Further reduces damage blocked by guarding by a small amount',
            flavorText = 'For the baker with nothing left to give',
            rarity = 'common',
        },
        {
            toolName = 'Water Bottle',
            description = 'On pickup, heal all members and status conditions',
            flavorText = 'Why is it always empty',
            rarity = 'common',
        },
        {
            toolName = 'Piping Bag',
            description = 'Flour Attacks cost 1 less Flour Point',
            flavorText = 'CUSTARD',
            rarity = 'common',
        },
        {
            toolName = 'Banneton',
            description = 'Flower attacks cost 1 more FP but are more effective',
            flavorText = 'Every boule deserves a viking funeral',
            rarity = 'common',
        {
            toolName = 'Hard Water',
            description = 'On level up, roll a bonus stat reward',
            flavorText = 'Good ole tap water',
            rarity = 'common',
        },
        {
            toolName = 'Ancient Interface',
            description = 'Your first attack each battle always gets the QTE bonus',
            flavorText = 'There\'s a satisfying clack to the keys',
            rarity = 'common',
        },
        {
            toolName = 'Misshapen Beignet',
            description = 'Enemies cannot escape',
            flavorText = '???', -- revise
            rarity = 'common',
        },
        {
            toolName = 'Dirty Dishes',
            description = 'Slow enemies at the start of battle',
            flavorText = 'The kitchen can\'t move when the sink is full',
            rarity = 'common',
        },
        {
            toolName = 'Fake Mustache',
            description = 'Basic attacks deal more damage',
            flavorText = 'revise',
            rarity = 'common',
        },
        {
            toolName = 'Decroded Mitts',
            description = 'You cannot be debuffed during your turn',
            flavorText = 'Heat has worn away the fingertips',
            rarity = 'common',
        },
        {
            toolName = 'Dairy Pills',
            description = 'Cures lactose intolerance',
            flavorText = 'I\'m so bloated',
            rarity = 'common',
        },
        {
            toolName = 'Dough Hook',
            description = 'Increase damage for each empty or cursed skill slot',
            flavorText = 'It starts with a good mix',
            rarity = 'common'
        },
        {
            toolName = 'Basque Cheesecake',
            description = 'Gain additional EXP when defeating burnt enemies',
            flavorText = 'It\'s not burnt! Okay, it is burnt, but it\'s supposed to look like that.',
            rarity = 'common'
        },
        {
            toolName = 'Refurbished Idol',
            description = 'Gain additional money from enemies, equal to your level',
            flavorText = 'Their beauty was a spark that started an ancient war',
            rarity = 'common'
        },
        {
            toolName = 'Water Cup',
            description = 'Restore a small amount of FP when you sell equipment',
            flavorText = 'Someone filled it with soda',
            rarity = 'common'
        },
        {
            toolName = 'Bottomless Fries',
            description = 'Restore a small amount of HP when purchasing an item',
            flavorText = 'It takes way too long for this to get refilled',
            rarity = 'common'
        },
        {
            toolName = 'Tip Jar',
            description = 'Get slightly more money when selling accessories',
            flavorText = 'Money goes in, tips come out. You can\'t explain that',
            rarity = 'common'
        },
        {
            toolName = 'Chew Toy',
            description = 'Weaken all enemies at the start of battle',
            flavorText = 'Whoever this belonged to loved this thing',
            rarity = 'common'
        },
        {
            toolName = 'Dress Shirt',
            description = 'Every 3 turns, the first character goes twice',
            flavorText = 'Lets you make a first impression twice!',
            rarity = 'common'
        },
        {
            toolName = 'Calendar',
            description = 'Start of turn, lose 1 HP every turn and deal 4 damage to all enemies',
            flavorText = 'Closed on Mondays and Tuesdays',
            rarity = 'common'
        },
        {
            toolName = 'Grease of Ruin',
            description = 'Grounded enemies have a small chance to have their attack lowered after attacking',
            flavorText = 'Non-slip shoes required',
            rarity = 'common'
        },
        {
            toolName = 'Dragonscale Ring',
            description = 'Take half damage from recoil',
            flavorText = 'Cool to the touch',
            rarity = 'common'
        },
        {
            toolName = 'Bansho Fan',
            description = 'Enemies spread statuses to adjacent enemies on defeat',
            flavorText = 'A single swing wiped out a great fire, along with the castle that was burning',
            rarity = 'common'
        },
        {
            toolName = 'Land Cucumber',
            description = 'On defeating a character, attacking enemies take damage equal to damage they dealt',
            flavorText = 'Like a cornered mouse',
            rarity = 'common'
        },
        {
            toolName = 'Display Loaf',
            description = 'Attacks with a base power under 5 deal extra damage',
            flavorText = 'The crumb structure reveals the fine attention paid to the details in the baking process',
            rarity = 'common'
        },
        {
            toolName = 'Bread Board',
            description = 'Paralysis has no effect on speed',
            flavorText = 'Why was this here?',
            rarity = 'common'
        },
        {
            toolName = 'LOVE',
            description = 'Gain an additional small amount of gold at the end of each battle for each surviving team member',
            flavorText = 'We take care of our own here',
            rarity = 'common'
        },
        {
            toolName = 'Blindfold of the Unburdened',
            description = 'Characters without equipment or accessories have higher crit chance and speed',
            flavorText = 'See without eyes',
            rarity = 'common'
        },
        {
            toolName = 'Pita',
            description = 'A random team member starts each battle with burn',
            flavorText = 'Take the evil you know over the evils you don\'t',
            rarity = 'common'
        },
    },

    uncommon = {
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'uncommon'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'uncommon'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'uncommon'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'uncommon'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'uncommon'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'uncommon'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'uncommon'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'uncommon'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'uncommon'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'uncommon'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'uncommon'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'uncommon'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'uncommon'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'uncommon'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'uncommon'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'uncommon'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'uncommon'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'uncommon'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'uncommon'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'uncommon'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'uncommon'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'uncommon'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'uncommon'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'uncommon'
        },
    },

    rare = {
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'rare'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'rare'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'rare'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'rare'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'rare'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'rare'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'rare'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'rare'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'rare'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'rare'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'rare'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'rare'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'rare'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'rare'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'rare'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'rare'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'rare'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'rare'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'rare'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'rare'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'rare'
        },
    },

    event = {
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'event'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'event'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'event'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'event'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'event'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'event'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'event'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'event'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'event'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'event'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'event'
        },

    },
    shop = {
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'shop'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'shop'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'shop'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'shop'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'shop'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'shop'
        },
        {
            toolName = '',
            description = '',
            flavorText = '',
            rarity = 'shop'
        },
    }
}

function GetToolPool()
    return toolPool
end;
