# QTE Data

## Brief

Contains JSON files that are used to initialize QTE objects. The data in each of these files is read in `util.qte_loader.lua`, which gets returned to the calling function as a lua table. The table is used to initialize a class. However, down the road, these class definitions may be replaced with a simpler implementation since the current version of the game doesn't need to perform any operations on QTEs that an OOP approach makes any easier.

## File Contents

All QTEs should have the following attributes. Some QTEs will have more attributes defined. For example, the HoldSBP QTE uses a progress bar to give feedback to the player when they hold down the indicated button, which isn't used by all QTEs.

1. `name`: `string` - Name of the QTE
2. `startupWaitingDuration`: `number` - Time given to the player before the QTE begins, measured in seconds
3. `qteDuration`: `number` - Duration of the QTE's main logic, measured in seconds
4. `feedbackFileNames`: `array[string]` - List of 1 or more file names (excluding the file stem) that contain the UI for different outcomes of performing the QTE (fail, success, etc.)