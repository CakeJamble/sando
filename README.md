# 🥪 SANDO

Save the bakery! Recruit team members and level-up in this active turn-based combat RPG as you run the gauntlet of enemies and bosses!

## 🔗 Quick Links

Now that Sando is in an intense development period, the game is gettings several updates day-to-day. For this reason, previously available quick links have been removed until Sando lands in a spot where I feel comfortable sharing my progress. If you would like to see my work process, I've begun a Dev Log series on my Wordpress where I try to organize the development process into more digestible chunks of milestones. I'll add back other links later!

- [Dev Logs - CakeJamble Wordpress](https://cakejamble.wordpress.com/)

## ✅ Repository Structure

The source code for the game can be found in its entirety in `src`. Use your preferred build method to launch in LOVE.

### 🎨 `asset`

Animations, SFX, music, backgrounds, and documentation.

### 🖥️ `class`

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

Contains the libraries used for the game's implementation.

- [hump](https://hump.readthedocs.io/en/latest/)
- [flux](https://github.com/rxi/flux)
- [cimgui-love](https://codeberg.org/apicici/cimgui-love)
- [json.lua](https://github.com/rxi/json.lua)
- [shove](https://github.com/Oval-Tutu/shove)

### 🛠️ `util`

Contains helper functions and globals for the game.

## 🗺️ Roadmap

### 🧪 Features

- [ ] Roguelike loop
- [x] Reactive Combat System with Quick-Time-Events, inspired by Mario RPG series (SNES, N64, GBA, GC, Switch)
- [x] Modular Turn Scheduling system, allowing custom swapping between different turn-based battle architectures (Standard, ATB, CTB)
- [ ] Modular Entity engagement system, allowing custom swapping between different combat formats (3v3, Bench-Swap System)
- [x] Data-Oriented Design Architecture enabling designers to write a JSON file & an associated Lua script for a skill/item action, and the game engine will handle the rest
- [ ] Unlockable Characters
- [ ] Events
- [ ] Shops
- [ ] Meta-progression system across runs
- [ ] Input-Assist Mode
- [ ] More more more but I will have to trickle that out after some testable alpha is done.

### 📈 Marketing

TBD - Store pages have been acquired for itch.io & Steam, but will remain unpublished until the demo releases.

### 📢 Publication

Targeting a release window for a Vertical Slice Demo of the game's core roguelike loop in Late 2025.

## 💁 Tools & External Resources

- [HotPartciles](https://github.com/ReFreezed/HotParticles)
- [Magical 8Bit Plug](https://ymck.net/app/magical-8bit-plug-en)
- [Bfxr](https://www.bfxr.net/)
- [Figma](https://www.figma.com/)
- [Sublime Text](https://www.sublimetext.com/)
- [Sublime Merge](https://www.sublimemerge.com/)


## 📫 Inquiries

Direct all inquiries regarding to the development of this product to the email of the sole author of Sando: [CakeJamble](mailto:cakejamblegames@gmail.com)

## ⚠️ Disclaimer

I provide no support for code taken from this repository. Despite the code being publicly available, this is NOT an open-source software. I may respond to emails that ask for support or suggest improvements, but I cannot promise I will respond promptly or consistently at this time. I reserve the right to change the visibility of this repository without any notice or reason.
