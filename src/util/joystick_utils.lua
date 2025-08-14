local Vector = require('libs.hump.vector')

local M = {}
M.activeRumbles = {}
M.axisRepeaterStates = {}

function M.getDeadzoneVector(joystick, stick, deadzone)
	deadzone = deadzone or 0.25
	local stick = stick or 'left'

	if not joystick or not joystick:isGamepad() then
		return Vector(0,0)
	end

	local rawV = Vector(
		joystick:getGamepadAxis(stick .. 'x'),
		joystick:getGamepadAxis(stick .. 'y')
	)

	local magnitude = rawV:len()
	if magnitude < deadzone then
		return Vector(0,0)
	end

	local remappedMag = (magnitude - deadzone) / (1 - deadzone)
	return rawV:normalized() * remappedMag
end;

function M.startRumble(joystick, id, strength, duration)
	if not joystick or not joystick:isGamepad() then return end

	if not M.activeRumbles[joystick] then 
		M.activeRumbles[joystick] = {}
	end

	M.activeRumbles[joystick][id] = {
		strength = strength or 0.75,
		duration = duration or 0.25,
		timer = duration or 0.25
	}
end;

function M.stopRumble(joystick, id)
	if M.activeRumbles[joystick] and M.activeRumbles[joystick][id] then
		M.activeRumbles[joystick][id] = nil
	end
end;

function M.update(dt)
	for joystick, effects in pairs(M.activeRumbles) do
		local maxStrength = 0
		local rumblesToDelete = {}

		for id, rumble in pairs(effects) do
			rumble.timer = rumble.timer - dt
			if rumble.timer <= 0 then
				table.insert(rumblesToDelete, id)
			else
				rumble.strength = math.min(rumble.strength, maxStrength)
			end
		end

		for _,id in ipairs(rumblesToDelete) do
			effects[id] = nil
		end

		if joystick:isConnected() then
			joystick:setVibration(maxStrength, maxStrength)
		else
			M.activeRumbles[joystick] = nil
		end
	end
end;

-- For getting the angle in radians
function M.getAngleVec(vec)
	if vec:len2() == 0 then return nil end -- using squared len
	return math.atan2(vec.y,vec.x)
end;

-- 8-way input, when emulating d-pad input on joystick
function M.get8WayDirection(vec)
	local angle = M.getAngle(vec)
	if not angle then return Vector(0,0) end

	local snappedAngle = math.floor(angle / (math.pi / 4) + 0.5) * (math.pi / 4)

	return Vector(math.cos(snappedAngle), math.sin(snappedAngle))
end;

-- Limits the number of consecutive analog stick inputs recognized
function M.updateAxisRepeater(joystick, dt, config)
    if not joystick or not joystick:isConnected() then return end

    -- init state table
    if not M.axisRepeaterStates[joystick] then
        M.axisRepeaterStates[joystick] = {
            up = { timer = 0, wasDown = false, triggered = false },
            down = { timer = 0, wasDown = false, triggered = false },
            left = { timer = 0, wasDown = false, triggered = false },
            right = { timer = 0, wasDown = false, triggered = false },
        }
    end

    -- Default config
    config = config or {}
    local threshold = config.threshold or 0.5
    local initialDelay = config.initialDelay or 0.4
    local repeatDelay = config.repeatDelay or 0.15

    local state = M.axisRepeaterStates[joystick]
    local stickVec = Vector(joystick:getGamepadAxis('leftx'), joystick:getGamepadAxis('lefty'))

    local directions = {
        up = { isDown = stickVec.y < -threshold, state = state.up },
        down = { isDown = stickVec.y > threshold, state = state.down },
        left = { isDown = stickVec.x < -threshold, state = state.left },
        right = { isDown = stickVec.x > threshold, state = state.right },
    }

    for dir, data in pairs(directions) do
        -- Reset the trigger flag at the start of each frame
        data.state.triggered = false

        if data.isDown then
            if not data.state.wasDown then
                -- 1. JUST PRESSED: Trigger immediately and set the timer for the initial delay.
                data.state.triggered = true
                data.state.timer = initialDelay
            else
                -- 2. STILL HELD: Countdown the timer.
                data.state.timer = data.state.timer - dt
                if data.state.timer <= 0 then
                    -- 3. TIMER EXPIRED: Trigger and reset the timer for the repeat delay.
                    data.state.triggered = true
                    data.state.timer = repeatDelay
                end
            end
        end
        -- Update the 'wasDown' state for the next frame
        data.state.wasDown = data.isDown
    end
end

function M.isAxisRepeaterTriggered(joystick, direction)
    if not M.axisRepeaterStates[joystick] then return false end
    return M.axisRepeaterStates[joystick][direction].triggered
end

return M
