# TODO

Copy/Paste the list under the most recent for next time under a heading for the date you are working on and make it a checkbox.

## [Today's Date]

### TODO

Cleanup the following files by getting rid of unused or deprecated variables.

- [x] `combat.lua`
- [x] `team.lua`
- [x] `character_team.lua`
- [x] `enemy_team.lua`
- [x] `entity.lua`
- [x] `character.lua`
- [x] `enemy.lua`
- [x] `action_ui.lua`

If there's time refactor & update Signal and method calls
- [ ] `movement_state.lua`
- [ ] `offense_state.lua`

### Reflection
(placeholder text)

## For next time

Clean up the following files by getting rid of unused or deprecated variables.

1. `combat.lua`
2. `team.lua`
3. `character_team.lua`
4. `enemy_team.lua`
5. `entity.lua`
6. `character.lua`
7. `enemy.lua`

If there's time, refactor Signals so that `movement_state.lua` & `offense_state.lua` properly put characters where they need to be to initiate an attack.

## 5/31/2025

### TODO

- [x] Refactor combat signals for turn change to set targets for combat participants
- [x] Fix bug that doesn't properly set the current target
- [x] Restructure combat signals so that all entities get the position of targets

### Reflection

Did well today reading through the observer pattern implementation that is used in the combat scene. In the future, I'd like to clean things up a bit more so that I'm not looking for variables that no longer exist, or leaving variables around that never get accessed. A linter might help me catch those, and make it easier in the future to clean up house. Overall, I'm pleased with today's progress, since I've been so busy with school stuff. Lua is great for picking back up after stepping away for a while.