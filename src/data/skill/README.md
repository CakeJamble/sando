# Skill Data

## Brief

Contains JSON files that are used to initialize skills. The data in each of these files in read in `util.skill_loader`, which gets returned to the calling function as a lua table after appending the corresponding logic for the skill contained in `skills.logic.<skill name>.lua`. Skills are then bundled together with Character data according to the character's skill pool.

## File Contents

All Skills should have the following attributes.

1. `name`: `string`
2. `damage`: `number`
3. `targetType`: `string` - `characters`, `enemies`, or `any`
3. `isSingleTarget`: `bool` - True if this skill targets a single entity, false otherwise
3. `effects`: `array[string]` - List of effect(s) that can occur
4. `chance`: `number` - Probability of the effect occurring. `chance` should be between 0 and 1. If it is not defined, it defaults to 0.
5. `spritePath`: `string`
6. `soundPath`: `string`
7. `duration`: `number` - Number of seconds for skill to conclude
8. `stagingTime`: `number` - Number of seconds for the entity to move from their current position to the position where they will begin using their skill.
9. `beginTweenType`: `string` - The easing type for the tween used to get the entity from their current position to the position where they will start using their skill. See [flux:ease(type)](https://github.com/rxi/flux/blob/master/README.md#easetype) for the different types of tweens. The tween type defaults to `quadout`.
10. `returnTweenType`: `string` - The easing type for the tween used to get the entity from their current position to the position where they began using the skill. Tween types are the same as `beginTweenType`.
11. `isDodgeable`: `bool`
12. `hasProjectile`: `bool`
