---@meta

---@class Team
---@field members Entity[]
---@field bench table
---@field membersIndex integer
Team = {}

---@param entities Entity[]
function Team:init(entities) end

---@param entity Entity
function Team:addMember(entity) end

---@param entities Entity[]
function Team:removeMembers(entities) end

-- Constructs the bench in the Active/Bench battle format
function Team:initBench() end

---@param index integer
function Team:moveToBench(index) end

-- Swaps out an Active member with a Bench member
---@param activeIndex integer Index of active member going to the bench
---@param benchIndex integer Index of bench member entering combat
function Team:swap(activeIndex, benchIndex) end

---@return Entity[]
function Team:getLivingMembers() end

---@return boolean
function Team:isWipedOut() end

function Team:printMembers() end

---@param dt number
function Team:update(dt) end

function Team:draw() end