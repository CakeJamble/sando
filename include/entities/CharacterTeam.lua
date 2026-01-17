---@meta

---@class CharacterTeam: Team
---@field rarityMod number Percentage added to weighted distributions of rarity events
---@field discount number Percentage off for price of items during transactions
---@field koCharacters Character[]
---@field inventory Inventory
---@field usingFirstConsumable boolean
---@field koGetsExp boolean
local CharacterTeam = {}

-- Creates a character team with a new Inventory
---@param characters Character[]
function CharacterTeam:init(characters) end

-- Create a character team with an existing Inventory
---@param characters Character[]
---@param inventory Inventory
---@see Inventory
function CharacterTeam:init(characters, inventory) end

-- Distributes Exp to all Characters that are not KO'd.
---@param amount integer
function CharacterTeam:distributeExperience(amount) end

-- WIP for character select interaction with a tool
---@param opts? table Optional arguments for excluding selection
---@return any
function CharacterTeam:yieldCharacterSelect(opts) end

-- Adds a Character to `self.koCharacters`
---@param koCharacters Character[]
function CharacterTeam:registerKO(koCharacters) end

-- Restores 40% of HP to each Character, rounding up. Also heals KO'd members
function CharacterTeam:rest() end

-- WIP for saving/loading
function CharacterTeam:serialize() end