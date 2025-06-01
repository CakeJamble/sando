# TODO

Copy/Paste the list under the most recent for next time under a heading for the date you are working on and make it a checkbox.

## 06/01/2025

### TODO
- [x] Selecting a basic attack emits a signal to move the character to the correct place
- [x] Character enters offense state once they arrive at destination
- [x] Character animation begins in offense state
- [x] Turn order and transitions behave as expected, based on speed values
- [x] Refactor hierarchy so that the TurnManager class updates targets and options for the active entity, instead of each character checking if it's their turn every time the signal is emitted
- [ ] QTE Input Validation

### Reflection
HUGE DAY. I am so happy that I got the turn system working! Next time, I want to begin implementing the attacks so that HP is properly updated. And if I have time, I want to implement death and destruction of dead entities, so that we can begin progressing towards a win-state for the combat scene :). This is so exciting!

## For next time

Make some progress on the combat loop being implemented

## 5/31/2025

### TODO

- [x] Refactor combat signals for turn change to set targets for combat participants
- [x] Fix bug that doesn't properly set the current target
- [x] Restructure combat signals so that all entities get the position of targets

Cleanup the following files by getting rid of unused or deprecated variables.

- [x] `combat.lua`
- [x] `team.lua`
- [x] `character_team.lua`
- [x] `enemy_team.lua`
- [x] `entity.lua`
- [x] `character.lua`
- [x] `enemy.lua`
- [x] `action_ui.lua`

### Reflection

Did well today reading through the observer pattern implementation that is used in the combat scene. In the future, I'd like to clean things up a bit more so that I'm not looking for variables that no longer exist, or leaving variables around that never get accessed. A linter might help me catch those, and make it easier in the future to clean up house. Overall, I'm pleased with today's progress, since I've been so busy with school stuff. Lua is great for picking back up after stepping away for a while.