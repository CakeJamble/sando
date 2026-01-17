# 🥪 SANDO

Save the bakery! Recruit team members and level-up in this active turn-based combat RPG as you run the gauntlet of enemies and bosses!

## 🔗 Quick Links

Now that Sando is in an intense development period, the game is gettings several updates day-to-day. For this reason, previously available quick links have been removed until Sando lands in a spot where I feel comfortable sharing my progress. If you would like to see my work process, I've begun a Dev Log series on my Wordpress where I try to organize the development process into more digestible chunks of milestones. I'll add back other links later!

- [Dev Logs - CakeJamble Wordpress](https://cakejamble.wordpress.com/)

## ✅ Repository Structure

The source code for the game can be found in its entirety in `src`. Use your preferred build method to launch in LOVE. In order to cut down the amount of scrolling done in files, I decided to move a lot of inline documentation to [Definition Files](https://luals.github.io/wiki/definition-files/). If you want to see annotations, be sure to open your workspace from the `sando` directory, and not from the `src` directory. Definition Files are not a part of the actual program, and are only used by Lua Language Server. As such, no Definition Files should ever be `require`d in another file.

### 🎨 `asset`

Animations, SFX, music, backgrounds, etc. If you have a copy of the game, you can extract assets here, but they will not be provided in this repository.

### 🖥️ `class`

Contains the source code for OOP classes. Uses `hump.class` to support its implementations. See `src.class.README.md` for more detailed class breakdowns.

### 🎮 `gamestates`

Contains the source code for the different gamestates in the game. Uses `hump.gamestates` to support its implementations.

- `Bakery`: An interactive codex-like environment to see your achievements and track your progress in the game.
- `Character Select`: Accessible when beginning a new game. Allows you to select your starting member(s)
- `Combat`: Main driver for the core game loop.
- `Main Menu`: Hosts the landing page for the game.
- `Pause`: Accessible during the Combat gamestate. Contains settings, and the team's vital stats.
- `Reward`: Pushed onto the gamestates stack when you win a fight to distribute rewards and level-ups.
- `Overworld`: Contains the Map for traversing between encounters. There are no plans to implement a free-roam exploration component to the game at the time of writing this.
- `Event`: Small minigames and text-based interactions occur between some combat encounters.
- `Shop`: A Yakiimo Truck inspired shop interface for spending resources in exchange for Tools, Accessories, and Equipment for the current run.

### 📖 `libs`

Contains the libraries used for the game's implementation. Not provided in this repo to cut down on GitHub storage of redundant files that exist elsewhere. I plan to write a simple script that will check for these dependencies in the user's workspace and clone the repositories of any missing dependencies, but for now you will need to manually clone them.

- [hump](https://hump.readthedocs.io/en/latest/)
- [flux](https://github.com/rxi/flux)
- [cimgui-love](https://codeberg.org/apicici/cimgui-love)
- [json.lua](https://github.com/rxi/json.lua)
- [shove](https://github.com/Oval-Tutu/shove)

### 💯 `test`

Unit tests with optional arguments when running from the command line. To run all tests then exit, run `love . --test=true` from the project's root directory (`src`). To run specific tests, you can add an argument for each test file or test directory you would like to run. See the examples below.

1. Run all tool related tests: `love . --test=true test/tool`
2. Run a single test file: `love . --test=true test/tool/onpickup_tools.lua`
3. Run an arbitrary collection of tests `love . --test=true test/tool/onpickup_tools.lua test/accessory/onequip_acc.lua <...>`

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
