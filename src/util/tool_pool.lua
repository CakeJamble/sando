--!: file: tool pool

local toolPool = 
{ 
    -- ['common'] = {
    --     {
    --         toolName = 'Half Muffin',
    --         description = 'On pickup, increase all members\' HP by 8%',
    --         flavorText = 'Microwaved to perfection',
    --         rarity = 'common'
    --     },
    --     {
    --         toolName = 'Strainer',
    --         description = 'On pickup, increase all member\'s defense by 1',
    --         flavorText = 'No clumps',
    --         rarity = 'common'
    --     },
    --     {
    --         toolName = 'Energy Drink',
    --         description = 'On pickup, assigned character has a 50% chance to take their turn first',
    --         flavorText = 'For the baker with nothing left to give',
    --         rarity = 'common',
    --     },
    --     {
    --         toolName = 'Smart Watch',
    --         description = 'PLACEHOLDER',
    --         flavorText = 'Steps add up',
    --         rarity = 'common',
    --     },
    --     {
    --         toolName = 'Boiled Egg',
    --         description = 'On pickup, enchant a move of one character with healing',
    --         flavorText = 'It\'s close to hatching',
    --         rarity = 'common',
    --     },
    --     {
    --         toolName = 'Splatter Guard',
    --         description = 'Further reduces damage blocked by guarding by a small amount',
    --         flavorText = 'For the baker with nothing left to give',
    --         rarity = 'common',
    --     },
    --     {
    --         toolName = 'Water Bottle',
    --         description = 'On pickup, heal all members and status conditions',
    --         flavorText = 'Why is it always empty',
    --         rarity = 'common',
    --     },
    --     {
    --         toolName = 'Piping Bag',
    --         description = 'Flour Attacks cost 1 less Flour Point',
    --         flavorText = 'CUSTARD',
    --         rarity = 'common',
    --     },
    --     {
    --         toolName = 'Banneton',
    --         description = 'Flower attacks cost 1 more FP but are more effective',
    --         flavorText = 'Every boule deserves a viking funeral',
    --         rarity = 'common',
    --     {
    --         toolName = 'Hard Water',
    --         description = 'On level up, roll a bonus stat reward',
    --         flavorText = 'Good ole tap water',
    --         rarity = 'common',
    --     },
    --     {
    --         toolName = 'Ancient Interface',
    --         description = 'Your first attack each battle always gets the QTE bonus',
    --         flavorText = 'There\'s a satisfying clack to the keys',
    --         rarity = 'common',
    --     },
    --     {
    --         toolName = 'Misshapen Beignet',
    --         description = 'Enemies cannot escape',
    --         flavorText = '???', -- revise
    --         rarity = 'common',
    --     },
    --     {
    --         toolName = 'Dirty Dishes',
    --         description = 'Slow enemies at the start of battle',
    --         flavorText = 'The kitchen can\'t move when the sink is full',
    --         rarity = 'common',
    --     },
    --     {
    --         toolName = 'Fake Mustache',
    --         description = 'Basic attacks deal more damage',
    --         flavorText = 'revise',
    --         rarity = 'common',
    --     },
    --     {
    --         toolName = 'Decroded Mitts',
    --         description = 'You cannot be debuffed during your turn',
    --         flavorText = 'Heat has worn away the fingertips',
    --         rarity = 'common',
    --     },
    --     {
    --         toolName = '',
    --         description = 'Slow enemies at the start of battle',
    --         flavorText = 'The kitchen can\'t move when the sink is full',
    --         rarity = 'common',
    --     },
    -- },
    ['uncommon'] = 
    {
        'Phone Charger',
        'Face Roller',
        'Sunscreen',
        'Mini Whiteboard',
        'Coffee Mug',
        'Milk Pitcher',
        'Meat Press',
        'Chef Hands',
        'Mummified Grapes',
        'Soft Water',
        'Coffee Ground Puck',
        'Thermometer',
        'Crushed Can',
        'Pizza Spire',
        'Portafilter',
        'Preserved Pastry',
        'Potted Plant',
        'Desecrated Idol',
        'Shutter Key',
        'Parking Permit',
        'Cat Teaser',
        'Point Card',
        'Folded Filter',
        'Stolen Rug',
        'Fine Sand'
    },
    ['rare'] = 
    {
        'Pastry Brush',
        'Floury Marker',
        'Double Helix',
        'To-Go Bag',
        'Hoiro',
        'Picnic Blanket',
        'Croissant Flakes',
        'Scraper',
        'Meat Grinder',
        'Everything Seasoning',
        'Cooking Doll',
        'Deck of Cards',
        'Loaf Loader',
        'Pot of Ghee',
        'Work Shoes',
        'Canvas Tote',
        'Cold Brew Pitcher',
        'Memory Foam',
        'Whetstone',
        'Sticky Note',
        'Tardy Treat',
        'White Potato'

    },
    ['event'] = 
    {
        'Electric Kettle',
        'Azzi\'s Manuscript',
        'Tassajara Bread Book',
        'Levain of Theseus',
        'Puff\'s Codex',
        'Massage Gun',
        'Shoe Charm',
        'Test Oracle',
        'Lin\'s Insurance',
        'Lin\'s Ledger',
        'Vampire Fangs',
    },
    ['shop'] = 
    {
        'Boxing Wraps',
        'Recipe Book',
        'Baking Soda',
        'Cinnamon Roll Eye',
        'Coffee Tamper',
        'Ambiguous Furniture',
        'Prismatic Triangle',
        'Forgotten Placeholder',
    }
}

function GetToolPool()
    return toolPool
end;
