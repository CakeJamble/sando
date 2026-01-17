---@meta

---@class Ring
---@field options {mode: string, x: integer, y: integer, r: number}
---@field flipDuration number
---@field shear {kx: number, ky: number, scale: number, angle: number}
---@field offset {x: integer, y: integer}
---@field peakHeight integer
---@field numSlices integer
---@field sliceLenRange {min: integer, max: integer}
---@field slices table[]
---@field line {angle: number, duration: number, length: number, isActive: boolean}
---@field revolutionTween table
---@field showSlices boolean
---@field gotNoInput boolean
---@field flipTween table
---@field revActive boolean
Ring = {}

---@param options {mode: string, x: integer, y: integer, r: number}
---@param flipDuration number
---@param slicesData {numSlices: integer, sliceLenRange: {min: integer, max: integer}}
---@param qteDuration number
function Ring:init(options, flipDuration, slicesData, qteDuration) end

--[[Flips the Ring into the air, shearing it to achieve the flipping affect.
After defining the tweens using shearing and positions, it returns the tween.]]
---@return table
function Ring:flipRing() end

--[[Defines the slices that represent the hot spots of the Ring,
which correlates to a good input when the line overlaps.
Functionality for cold spots is planned but not ready yet.]]
---@return table[]
function Ring:buildSlices() end

--[[Creates an arc that runs along the a portion of the circumference of the Ring.
This is called when building a slice.]]
---@param radius number
---@param angleStart number
---@param angleEnd number
function Ring.buildArc(radius, angleStart, angleEnd) end

--[[Creates an arc that runs along the a portion of the circumference of the Ring.
This is called when building a slice where you also want to define the number
of segments used to build the arc.]]
---@param radius number
---@param angleStart number
---@param angleEnd number
---@param numSegments integer
function Ring.buildArc(radius, angleStart, angleEnd, numSegments) end

-- Begins the sequence of flipping the Ring, and setting the line to move
function Ring:startRevolution() end

-- Called when Player inputs to check if the line lies within the current slice
function Ring:isInHitBox() end

-- Checks the angle of the line in the slice
function Ring.angleInSlice(angle, start, stop) end

function Ring:draw() end