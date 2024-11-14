### 11/13/24 Reflection
    - who should have an actionUI? The team so that there is only one to manage?
        - Each character so that they can be partitioned easily with their designated actionButton?
        - Or should the offenseState and defenseState of each character get their own ActionUI?

        - Difficult to decide right now because testing takes place with a team of only a single member :(

        - If the team should have an actionUI then we need to split the team into CharacterTeam and EnemyTeam subclasses because the different kinds of teams behave differently

### 11/14/24 Reflection
    - ActionUI:
        - Both the Team Class and the Character class have an ActionUI object
            - First, going to make Team a base class so that EnemyTeam doesn't even have to worry about it
            - Design Choice to make:
                - If the Character Class has an ActionUI object, then we need to manage more ActionUI objects in the combat state.
                - If the Team Class has an ActionUI object, then we need to make sure the correct skills are always displayed, which needs to be updated every time the focused character changes
                - DECISION: Character Class has an ActionUI object, so that it is more customizable later on if I want.
                    - I'm not sure which class is drawing it properly right now... need to check
        - The ActionUI class has a ton of variables that make it less modular than desired for testing and rapid changing
            - Ton of variables, static variables, and variables that depend on other variables (within the class, low cohesion)
            - Action Buttons (Solo, Flour, Duo) should be their own objects that inehrit from a Button base class
            - The ActionUI should be composed of these buttons, so that I can remove a lot of the complex logic, and focus on the functionality.