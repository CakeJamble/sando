# Known Bugs

Check the box if the bug has been fixed.

## Bug Tracker

### 08/07/2025

- [ ] STBScheduler will start Bake's turn, interrupt it with the enemy command, but not disable the action UI
- [ ] If the above bug happens and Bake's turn is resumed, the game crashes when Bake selects a skill
- [x] RingQTE & Variants sometimes make a very large slice with the wrong hitbox data
- [x] RingQTE & Variants softlock when no input is given
- [x] RingQTE & Variants don't reset properly when QTE is failed
- [x] RingQTE & Variants trigger skill every frame when no input is given
- [x] QTEs are not having `reset()` function called
- [ ] When completing the Combo Ring QTE, sometimes both characters' action ui will appear

### 08/06/2025

- [x] Characters are stuck in guard state after initiating a guard
- [ ] Action Button sometimes don't go through ActionUI hierarchy properly to trigger certain buttons' `gamepadpressed` functions.
- [ ] Enemies will target jumping enemies. Should use `oPos` table for character entities because they can be in midair during turn changes. But if they use `oPos`, the action user is calculating the trajectory of collision using the target's sprite width, and not the more accurate hitbox data, which is tuned to how collision should register in game.

### 08/05/2025

- [ ] ActionUI doesn't set targets properly depending on `ifOffensive` variable.