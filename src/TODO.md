# TODO

Copy/Paste the list under the most recent for next time under a heading for the date you are working on and make it a checkbox.

## 07/24/2025

Feeling a bit tired at the start of the day, so I'm going to rewrite the TODO so that instead of implementing a whole new class, I start out with just a skill, since the main thing I want to make progress towards is the Earthbound style health system. I also need to get on the gamejam game earlier today to catchup to the progress the rest of the team has made.

### TODO

- [x] Fix Flour Skill menu navigation by using directional pad to exit skill select menu
- [x] Fix target setup to allow character to target teammates when appropriate
- [ ] Implement a single test skill that heals a target.
	- [ ] JSON file
	- [ ] Logic file
- [ ] Tween the HP of Characters so that the loss can be interrupted by a heal

## 07/23/2025

Feeling very motivated after doing the counter-attacks. I want to try and implement the Earthbound style tweening of HP, so that you can use an item to heal back up. However, before I can do that, I need some way to heal. Also, I need to consider if that's really a useful system or not. It could be cool if my HP scales higher, but if I keep numbers low, it probably won't be very satisfying. A couple different ways to implement healing, one being a skill that heals, and the other being a consumable item. If I want to make an item usable, then I will need to refactor the ActionUI, which is something that was bound to happen anyways.

### TODO

- [x] Refactor ActionUI class to use tweening instead of manually moving
- [x] Add new ActionUI button for using items
- [x] Add new Action UI button for passing turn
- [x] Implement Back Button that lets a user cancel targeting using the action button
- [ ] Implement a single test item that heals a target.

If I have time after that

- [ ] Tween the HP of Characters so that the loss can be interrupted by a heal

### Reflection

Switching up the way the Action UI works felt like the culmination of a lot of things I've learned. I started by deeply nesting the decision hierarchy, then I tried to decouple it with the observor pattern. Then I was able to further simplify it by simplifying the logic after realizing that the landing positions for each button stay constant at the start of every turn. I'm going to focus on the consumable items interface sometime tomorrow since it's a big task to start so late in the work day. And I still need to help out with the game jam!

## 07/22/2025

Collision on defense. I want to be able to dodge enemy attacks, and land a counterhit if I time it right! I also need to update the excel sheet to match the new names, stats, and descriptions that I changed in the json files!

### TODO

- [x] Refactor entity animation data structure
	- [x] Movement animations are now instantiated together all at once
	- [x] Encapsulate animations characters do during attacks in the Character class (excluding projectiles)
	- [x] Dynamically create attack animations from skill json data
- [x] Implement and debug proper collision when overhead
	- [x] Entity owned tween table
	- [x] Interrupt entity on collision overhead
	- [x] Interrupt character on collision while trying to jump
- [x] Balance timing
- [x] Cleanup discrepancy between hitbox data and visual sprite (hitbox should actually be slightly smaller than sprite dimensions)
- [x] Implement visual indicator on successful dodge
- [x] Implement feedback on failed dodge (console output ok for now)
- [x] Implement feedback on success/fail block (console output ok for now)
- [x] End attack early when countered

### Reflection

The changes to the animations data structure in the entity class is awesome. I think it was something I was stuck on because I wasn't really thinking about how to package it all up without coupling the skill class with the entity class. Now that the skills are just tables that I wrap the logic around, passing the data for animations was simple. The filename of each json file directs the character class to the asset file for the sprite sheet, so the two don't actually need to interact directly, meaning I can make changes to skills without changing the animation loader in the character class. And since all entities can move, flinch, and get knocked out, I can put that in the base class implementation and further extend the implementation in inherited classes (characters can jump and block but not all enemies need those animations).

Overall, a very productive day! I have to cut it short to switch over to the game jam game today.

## 07/21/2025

Art was tough.

### TODO

- [x] Resize Bake
- [x] New Enemy - Dastobunni
- [x] Resize Marco
- [x] Fix Hold SBP QTE reset for new progress bar changes
- [x] Change animations during attack to match move used
- [x] Add logic to to flinch and get ko'd when attacked
- [x] Fix spacing and timing for skill logic
- [x] Apply attack bonus for QTE success
- [x] Separate responsibility of skill ending and turn ending
- [x] Enemy fade out on KO (replace with different effects later)

### Reflection

Good progress today. Changing the artstyle to be smaller was a good step, because I can better visualize what needs to be fixed and when. For the last bit of time I will be working today, and rolling into tomorrow, I want to focus on checking for collision when attacked. Things will get busy after today since I am starting a game jam tonight! But that's okay. I'm looking forward to working with others and learning some new stuff that might come in handy for developing Sando.

## 07/19/2025

This weekend I want to focus on art.

## 07/18/2025

I tend to run out of steam around 3 or so. I think I need to restructure how I tackle tasks so that I can work a bit longer. I would love to figure out joystick input because it seems like everyone gravitates to using that over the d-pad instinctually.

### TODO

- [x] Figure out sizes of sprites. Figure out whether or not to use Push library
- [x] Baton library? Review it and see if it's a good fit for this game
- [x] Review Command Pattern. Is it a good fit for this game?
- [x] Load in new assets for controller UI
- [ ] Collision System 
	- [ ] dodging
	- [ ] guarding
- [ ] Controller Config? -> Eventually want to display buttons based on controller
- [ ] Tap Left QTE implementation
- [ ] Controller layouts.
- [ ] Start looking up how to implement a save/load system.

### Reflection

I forgot about the collision system! I never finished it!!! Back to work. A little overwhelmed by the issue caused by setting the screen resolution the way I did. I should go back and look at Mario & Luigi to get the size of sprites down so that I don't feel this way about refactoring hitbox data.

Holy shiiiit. The exact dimensions of Mario's idle animation in Partners in Time is 23x35!!! That is tiny! His sprite where he sticks both arms out and waves to the gamera is 30x37. I need to get back to work on art. That is crazy. Why the hell were my characters 64x64 when I couldn't even get the right amount of detail on them. 

Baton actually doesn't seem like a great fit here. While I really like the idea of having different controller layouts, it looks like it is intended to be most useful in movement systems. But my game is more focused on menu navigation. I'll come back to this later.

Also, there's so much to think about right now, I really need to narrow the scope of the stuff I'm working on each day. This TODO had a good amount of stuff but it felt so unrelated to each other. I should be focusing on progress of developing mechanics.

The assets I bought recently are a little small. I'm not sure how I'm gonna be able to use them without blowing them up and making them look kind of distorted.

I'm feeling a little bit better about getting back into art now that I saw the sizes of sprites is actually way smaller than I thought. It's going to be really tough, but I am up to the challenge. I can only put it off for so long, after all. So, this weekend, I think that the move will be:

1. Resize sprites
2. Fix positioning for new size sprites in combat
3. Add another animation or two if I'm up to the task for skills
4. Start refactoring tween-based dodging and blocking for the more manageable sprite sizes.

This feels good, because now I have a good direction to go in that doesn't feel like I'm spinning my wheels and causing more work for myself later.

## 07/17/2025

After doing some of the legwork yesterday, I realized that it is probably a good idea to implement a debug menu using imGUI so that I can test things during combat. That will be the first thing I do after finishing moving the rest of the tools to json files. I finished off yesterday with the common tools. I'm switching priorities here because I think I have a great idea for improving replayability in a novel way. The current roadmap of Sando had you traversing through a randomized series of zones, and the zones were different from each other visually and by the types of enemies you face. I think it would be so cool if the zone also applied a mechanical change the way you play. For example, you enter a zone, and the antagonist applies an effect to the zone that makes it so that health ticks down on a tween, similar to Earthbound. And in the next zone, you add another layer to the mechanics, like a turn-based system where in Pokemon where you can swap out who is taking damage.

### TODO

- [x] Finish up moving tool data to json files
- [x] Read over the documentation for imGUI in Love2d
- [x] Implement an extremely simple debug menu that changes the drawHitbox variable in combat between `true` and `false`

### Reflection

Filling out those JSON files makes me so tired... it basically kills my energy to do other stuff afterwards. I had to move around a lot during the day, which isn't a good excuse, but it's important to recognize what sets my off-task so that I can be proactive about setting tasks. I also think I was a little too conservative with setting my TODO items because I was a bit lost once I finished them.

## 07/16/2025

Continuing refactor. Today I think is a good time to start moving the tools and equipment to JSON files.

- [ ] Move tool data to json files
- [ ] Implement QTE for tapping stick left to charge qte (like the Slap attack)


## 07/15/2025

I forgot to update the TODO again for a few days, despite making some major progress. I think that from here on, I really need to focus on keeping my work scoped into the tasks I'm assigning myself, or I could really burn out once I get frustrated.

Some things I've accomplished:

1. Really happy with the Data-Oriented Design overhaul to skills and characters. I'd like to try and do it with QTEs in the future so that this might be easier to open-source with less depenedencies.
2. Implemented Hold Single-Button-Press QTE
3. Fixed up the Hold Single-Button-Press QTE. It was pretty messy at first in the OOP design, but now the logic seems modular and the architecture is easier to follow
4. Implemented the Mult-Button-Press QTE, with the layout of the Naruto Storm game jutsu QTE. The visuals leave a lot to be desired, but the logic is pretty good, and balancing it shouldn't be too bad either.
5. Small QoL updates all over the place. I should have been tracking it better in the todo
6. Projectile class
7. Scone skill that uses the projectile with tweening and collision

### TODO

It might be boring, but there's a decent amount of grunt work to do to get the new architecture rolling.

- [x] Move Character and Enemy stats into JSON files in the `data` directory
	- [x] Characters
	- [x] Enemies
	- [x] Encounter Pools
- [x] Random Single Button Press QTE
- [ ] Move Skill data into JSON files in the `data` directory

I expect the last one to take a while since it's a lot of back and forth, making new files and referencing old ones. 

### Reflection

I'm going to break down the last bullet point since it's actually an epic that requires a lot of changes since every data file for a skill has a corresponding source file that needs to be designed, implemented, tested, and balanced. It will also be more manageable for PRs to actually serve a purpose if I move these one at a time.

## 07/10/2025

Need to deal with the reverberations of switching to collision based combat.

### TODO
- [x] Add jumping
- [x] Add guarding
- [x] Add jumping and guarding cooldowns
- [x] Fix target setup by enemies using `target.oPos` instead of current position(s)
- [x] Add functionality to guard by modifying defense (without defense state)
- [x] Refactor offense for Characters
	- [x] Skills
	- [x] QTE Manager & QTEs
- [x] Cleanup `NextTurn` signal in `TurnManager` class

### Reflection

Made some really good progress. Got some basic collision and got my first QTE implemented in this new system.

## 07/08/2025 & 07/09/2025

Today wasn't as productive because I spent a lot of time reading and thinking about how to integrate collision with tweening. I think I came to a good conclusion so I'm trying not to consider it wasted time. Today's studying will help improve tomorrow's coding.

- I definitely don't need a physics library for collision detection. I think I should implement my own because I only need AABB (Axis-aligned bounding boxes) to check for collision between combat entities.
- `hump.timer` has decent tweening functionality, but I need a little bit more complexity to solve my problems. Mainly, not having chained tweens, on complete, etc., available out of the box with `hump.timer` is going to slow me down when I start adding more skills. I think `flux` might be a better alternative.
- If I implement my own AABB system, tailored specifically to this style of combat, I should be able to get away without gravity and velocity. This would mean that my combat system's flow can be scripted pretty quickly with tweening. I'm eager to see how this goes with `flux`, since it's going to simplify a lot of the manual implementations of movement that I was chaining together initially.

### TODO

- [x] Import `flux` into my dependencies
- [x] Test a simple tween using `flux`
- [x] Review the diagrams from Figma to make sure I know where I need to hotswap the library uses
- [x] Swap out `hump.timer.tween` for `flux`
- [x] Write a barebones collision detection library

### Notes on `flux`

- `flux` is only used for tweening, while `hump.timer` has some other functionality that seems useful. For example, since `flux` only tweens numerical values, I will need to occasionally use Timer to wait for certain things to be true (like initializing the turn manager after the combat setup is done)

### Reflection
Using `flux` was much easier than `hump.timer`. It was a good swap and didn't take longer than an hour to catch up with my progress from earlier this week. 

## 07/07/2025

Need to figure out how to refactor the skills so that I can cleanly add in collision detection to contact moves and projectile moves. Should the skill class be split up into an inheritence hierarchy? Or is it enough to have the skills decoupled from the QTEs? I think I will try to latter option first and evaluate from there on how difficult it will be to scale the development of new scales, since that will be the primary concern, unless I immediately notice performance bottlenecks.

### TODO

- [ ] Refactor skills to use collision detection

## 07/07/2025

### TODO

- [x] Add collision boxes to entities in combat
- [x] Add jumping to characters, moving collision boxes alongside them
- [ ] Collision detection during enemy attacks

### Reflection

This is the beginning of another large refactor. I need to shift the development of the skill system from a basic signal based communication system, similar to Pokemon, towards the intended solution. The reactive turn based combat system will be based on collision detection, since the defense of characters will be closer to the Mario & Luigi series, while the offense system will be closer to the Paper Mario series. I have some basic designs set up to reference, but it seems like this will be a lot more work to develop and test new skills. I will need to reflect further to see if there are any better ways to organize this new system.

## 07/01/2025

Pivoting over to Skill development since that's honestly what is most important in getting this game progressing.

### QTEs

- [x] Design Timed MBP
- [x] Design Rhythym MBP 1
- [x] Design Rhythym MBP 2
- [x] Design Move Stick
- [x] Design Hold SBP
- [x] Design Hold Stick
- [x] Design Random SBP

### Reflection

Not my most productive day. Need to get back into the flow and get the creative ideas flowing. I'm not exactly sure how to do this without the animations being made yet, but I think I can do some simple placeholder art for the Action Command Prompts with the Flour Skills this week. None of these are terribly challenging to implement either, at least, I hope not! Famous last words.
I realized that I was losing steam because I was getting lost trying to think of how all the different QTEs would work, when I haven't even properly visualized them yet.


## 06/30/2025

More steady work on Tools and Inventory

- [x] Basic inventory sturcture with UI display for tools (rectangles and text ok)
- [ ] Adding & Removing Items
- [ ] Tool Asset Development
- [ ] Get and display info about tools

## 06/29/2025

My birthday :)

Mostly small progress made on implementing the functors for each tool in its respective dictionary when proc'd by an event signal in the tool manager class. I expect this to continue for a couple more days, then I will need to move on to the next piece of gear/equipment etc. until the inventory class is ready to be tested. It might be better to build the inventory class first so that individual pieces can be tested as they are developed.

## 06/28/2025

Been steadily working, but still missing the TODO updates. Need to really work on this and make sure I am tracking progress so I don't burn out.

### Progress Made

1. Added UI visual feedback (still image) for landing a successful block or attack for SBP.
2. Basic architecture designed for the different QTE hierarchy
3. Tool Pools are defined as full dictionaries that can be used to instantiate tool objects, rather than just strings.

### Reflection

These were pretty big steps towards making it feel like a real game. There's not that much further that I can go before I run up against the wall of not having enough assets to test new features, so I will eventually need to get my butt back on Aseprite. I think it might also soon be time to decide if I am going to keep this public or not.

### TODO
 
These TODO items are bigger tasks that will need to be split up into actionable items, but they serve as a good starting point to think about for next week.

- [x] Tool Class Implementation
- [ ] Tool Asset Development
- [x] Defense State Dodging or Jumping
- [ ] Projectiles
- [ ] Collision


## 06/18/2025

Missed another TODO update yesterday because I was so knee deep in GUI stuff I lost track of tracking my progress. Some things I realized:

- I don't need a UI Library for everything
- ImGUI is a good idea to implement for balancing and testing combat

### TODO

This TODO will include items I forgot to add from yesterday (06/17/2025)

- [x] Remove unused getters & setters. Focus on using these only when they simplify the interface to accessing data of a class
- [x] Bugfix: Enemies going past characters when it's their turn
- [x] Bugfix: Turn ending early before attack is registered in offense states
- [x] Cleanup: Move responsibility of offense state reset to the offense state
- [x] Refactor: Undo implementation of LUIS ImGUI for now, reverting back to custom rollout for Main Menu, Character Select, and Combat gamestates
- [x] Bugfix: Screen size scaling issues -> just lock it using the push library
- [x] Rudimentary HP display (non-functioning)
- [x] Create rewards gamestate that follows combat
- [x] Refactor: Enemies have rarity distributions for rewards
- [x] Add fetching of rewards (just tools for now) based on new reward distributions of enemies

### Reflection

I feel a lot more focused now that I am not worrying about implementing a mish-mash of different libraries together. This simpler approach will hopefully make it easier for me to focus on the core features. The frontend will inevitably be a mess, but I have some good ideas. Need to start getting back to designing.

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