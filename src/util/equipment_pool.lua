local equipPool = {
    ['common'] = {
        ['equip'] = {
            'Harnet',
            'Swim Brief',
        },
        ['accessory'] = {
            'Peel',
            'Paring Knife',
        }
    },
    ['uncommon'] = {
        ['equip'] = {
            'Painting Smock',
            'Aluminum Apron',
        },
        ['accessory'] = {
            'Large Bandage',
            'Designer Loafers',
            'Name Tag',
        }
    },
    ['rare'] = {
        ['equip'] = {
            'Moldy Apron'
        },
        ['accessory'] = {
            'Soap Bottle',
            'Thick Mitts'
        }
    }

}

function GetEquipmentPool()
    return equipPool
end;