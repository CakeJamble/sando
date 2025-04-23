# 🥪 SANDO! 
Save the bakery! Recruit team members and level-up in this active turn-based combat RPG as you run the gauntlet of enemies and bosses!

## 🔗 Quick Links (For Potential Employers & Collaborators)
- [Design Document - Email for Permission to View](https://docs.google.com/document/d/1nEuiEjtqEy8lEPdqv0Vll76njOY-9loD1x_p4BfTgoM/edit?usp=sharing)
- [Itch.io Store Page - Currently under development, access with 'MadeWithLOVE'](https://cakejamble.itch.io/sando)
- [See my design process on Figma](https://www.figma.com/files/team/1365416823601159568/project/246899128/Sando-?fuid=1365416821386778796)
- [Progress Tracking on Trello](https://trello.com/b/HwgkOIyj/sando)

## ✅ Repository Structure
The source code for the game can be found in its entirety in `src`. Use your preferred build method to launch in LOVE.

### 🎨 `asset` 
Contains sprite sheets and documentation.

### `🖥️ class` 
Contains the source code for OOP classes. Uses `hump.class` to support its implementations. See `src.class.README.md` for more detailed class breakdowns.

### 🎮 `gamestates` 
Contains the source code for the different gamestates in the game. Uses `hump.gamestates` to support its implementations. View progress on Trello for more updates.

- `Bakery`: An interactive codex-like environment to see your achievements and track your progress in the game.
- `Character Select`: Accessible when beginning a new game. Allows you to select your starting member(s)
- `Combat`: Main driver for the core game loop.
- `Main Menu`: Hosts the landing page for the game.
- `Pause`: Accessible during the Combat gamestate. Contains settings, and the team's vital stats.
- `Reward`: Pushed onto the gamestates stack when you win a fight to distribute rewards and level-ups.

### 📖 `libs` 
Contains the libraries used for the game's implementation. Expect many more libraries and credits to come as development gains momentum!
- [hump](https://hump.readthedocs.io/en/latest/)

### 🛠️ `util` 
Contains helper functions and globals for the game.

## 🗺️ Roadmap 

### 🧪 Features 
- [ ] Roguelike loop
- [ ] Active Turn-Based Combat System with Quick-Time-Events, inspired by Mario RPG series (SNES, N64, GBA, GC, Switch)
- [ ] Unlockable Characters
- [ ] Events
- [ ] Shops for progression during runs & metaprogression over a save file
- [ ] Input-Assist Mode
- [ ] More more more but I will have to trickle that out after some testable alpha is done.

### 📈 Marketing 
TBD

### 📢 Publication 
Targeting a release window for a Vertical Slice Demo of the game's core roguelike loop in Q3/Q4 2025.

## 📫 Inquiries
Direct all inquiries regarding to the development of this product to the email of the sole author of Sando: [CakeJamble](mailto:cakejamblegames@gmail.com)
