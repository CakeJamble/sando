# TODO

Copy/Paste the list under the most recent for next time under a heading for the date you are working on and make it a checkbox.

## 06/16/2025

Haven't been updating the TODO because I've been refactoring UI and a lot of small tasks pop up as I do other fixes. Good progress all around though learning about UI libraries and grid systems. This TODO will just be a wrapup of some stuff I've changed the last week.

### TODO

- [x] UI Widget Library Implemented (LUIS)
- [x] Fix Screen Size Changes
- [x] Main Menu UI Buttons
- [x] Main Menu Layout
- [x] Character Select UI Buttons
- [x] Character Select Flow Container
- [ ] UI Components
	1. Combat Vitals Container
	2. Avatar
	3. HP Display
	4. FP Display
	5. BP Display
	6. Money Display
	7. EXP Display
- [ ] Add instructions to skills for QTEs

### Reflection

There's some good stuff here, but the UI is still really sloppy. I want to get it working as a base prototype with the functionality, then I can polish it up.

## 06/08/2025

### TODO

- [x] Familiarize with Inventory class
- [ ] Implement simple Inventory functionality
- [ ] Familiarize with different items (Gear, Consumables, Tools, etc)
- [ ] Design basic display of items in inventory (text only ok for implementation)

### Reflection

More groundwork needs to be done in consideration of UI/UX Design. Need to implement some UI stuff using the LUIS library next to see how much easier a layout manager is going to make the dev process of menus. As such, we can move these TODOs to the backlog since this is an exciting new area to learn.

## 06/07/2025

### TODO

- [x] Refactor signal registries so that Entity base class calls when relevant
- [x] Move responsibility of relevant signals to be controlled by Turn Manager
- [x] Document changes so the responsibility of functions is clear
- [x] QTE Input Validation
	- [x] Implement basic functionality to validate input for QTE
	- [x] Tune timing to line up with animation for Marco's basic attack
	- [x] Add visual indicator for success (print statement ok for now)
	- [x] Add sound to play on success (anything is fine)
- [x] Figure out camera with signals -> zoom in, follow, zoom out

### Reflection

First two TODO items were way easier than I thought. Having the turn manager... manage turns... was a great idea for removing complexity from the Entity classes. QTE Input validation and camera were a little confusing but not too bad!

## 06/06/2025

### TODO

- [x] Implement attacking functionality -> calc damage and update health
- [ ] Figure out camera with signals -> zoom in, follow, zoom out

### Reflection

Good job getting an actual turn based combat system functioning in the combat scene. Next step is to refactor so that signals are emitted by entities rather than just characters so that both teams can properly deconstruct members on death. Once that is ready, start digging into a prototype for the QTE input validation. Then move on to pushing a rewards scene at the end of combat.

## 06/01/2025

### TODO

- [x] Selecting a basic attack emits a signal to move the character to the correct place
- [x] Character enters offense state once they arrive at destination
- [x] Character animation begins in offense state
- [x] Turn order and transitions behave as expected, based on speed values
- [x] Refactor hierarchy so that the TurnManager class updates targets and options for the active entity, instead of each character checking if it's their turn every time the signal is emitted
- [x] Sort turn order each turn to account for stat changes
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