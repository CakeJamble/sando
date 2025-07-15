# Character Data

## Brief

Contains JSON files that are used to initialize Character objects. The data in each of these files in read in `util.character_loader`, which gets returned to the calling function as a lua table. The table is used to initialize a class.

## File Contents

All characters should have the following attributes. Explanations are omitted for self-explanatory attributes like common stats.

1. `entityName`: `string`: Name of the character
2. `width`: `number` - Width of the sprite png file
3. `height`: `number` - Height of the sprite png file
4. `hbWidth`: `number` - Width of the hitbox
5. `hbHeight`: `number` - Height of the hitbox
6. `hp`: `number`
7. `fp`: `number`
8. `attack`: `number`
9. `defense`: `number`
10. `speed`: `number`
11. `luck`: `number`
12. `skillPool`: `array[string]` - List of 1 or more skills that the Character can learn. Each skill in the array should be written using the file name that the skill's corresponding data and logic are contained in. For example, when listing Basic Attack, the entry in the JSON file should be `"basic_attack"` because the Basic Attack files are named `basic_attack.json` and `basic_attack.lua`.