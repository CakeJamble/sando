# 🥪 SANDO! 
Save the bakery! Recruit team members and level-up in this active turn-based combat RPG as you run the gauntlet of enemies and bosses!

## ✅ Repository Structure 
The source code for the game can be found in its entirety in `src`.

### 🎨 `asset` 
Contains sprite sheets and documentation.

### `🖥️ class` 
Contains the source code for OOP classes. Uses `hump.class` to support its implementations. See `src.class.README.md` for more detailed class breakdowns.

### 🎮 `gamestates` 
Contains the source code for the different gamestates in the game. Uses `hump.gamestates` to support its implementations.

- `Bakery`: An interactive codex-like environment to see your achievements and track your progress in the game.
- `Character Select`: Accessible when beginning a new game. Allows you to select your starting member(s)
- `Combat`: Main driver for the core game loop.
- `Main Menu`: Hosts the landing page for the game.
- `Pause`: Accessible during the Combat gamestate. Contains settings, and the team's vital stats.
- `Reward`: Pushed onto the gamestates stack when you win a fight to distribute rewards and level-ups.

### 📖 `libs` 
Contains the libraries used for the game's implementation. Currently refactoring, so this README does not include LoveFrames, which is currently in the source code as a relic from an early iteration of Sando's UI.
- [hump](https://hump.readthedocs.io/en/latest/)

### 🛠️ `util` 
Contains helper functions and globals for the game.

## 🗺️ Roadmap 

### 🧪 Features 
- [ ] Roguelike loop
- [ ] Unlockable Characters
- [ ] Events & Shops
- [ ] Bakery
- [ ] Input-Assist Mode
- [ ] More more more but I will have to trickle that out after some testable alpha is done.

### 📈 Marketing 
TBD

### 📢 Publication 
TBD

## 📫 Inquiries
Direct all inquiries to the email of the sole author of Sando: [CakeJamble](mailto:cakejamblegames@gmail.com)