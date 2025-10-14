# Analytic Events with PostHog

No SDK setup in Lua to use PostHog to receive and analyze in-game events.

## Files

### `analytics_service`

Begins an analytics service that listens for an event, and pushes it to PostHog using functionality defined in `analytics_event.lua`. Uses an `input` & `output` named thread channels.

### `analytics_event`

Creates, sets, and pushes events to PostHog.

#### `pushAnalyticEvent(data: table)`

Makes the event through `makeAnalyticEvent` and sends it through `sendAnalyticEvent`

#### `makeAnalyticEvent(data: table)`

Sets the properties via `setProperties`, initializes the event to be sent, and increments the static variable `eventID`, which is simply a number that identifies a chronological order that events are created in during a session.

#### `setProperties(data: table)`

Sets up the major properties used for PostHog Analytics.

#### `sendAnalyticEvent(event: table)`

Sends a POST request to PostHog using the `https` module (LOVE 12.0+).

### `Events`

Defines the types of events that can be sent.

### `get_player_info`

Gets the unique `sessionID`, hardware information, and OS name.

### `uuidv7`

Creates a unique session ID in the format that is required by PostHog.

### `timestamp`

Creates a timestamp that is used to create the unique `sessionID` in `uuidv7.lua`

## Example

A basic example using the `knife` framework for unit testing.

1. Create a new thread for running analytics alongside the game

```lua
-- main.lua
function love.load()
    local analyticsThread = love.thread.newThread("analytics/analytics_service.lua")
    analyticsThread:start()
end;

-- ...

function love.quit()
  local channel = love.thread.getChannel('analytics_input')
  channel:push({type = "quit"})
end;
```

```lua
local T = require('knife.test')

T('Given a sample player and event description', function (T)
	local player = getPlayerInfo()
	local example = Events.example
	example.playerInfo = player
	input:push(example)

	local result = output:demand()
	T:assert(result.type == "example", "An example event was created")
	T:assert(result.sent, "And it was pushed to PostHog")
end)
```

In PostHog you will see new activity posted with the User's data and the example event in JSON format
```json 
{
	"Choices": ["Item1","Item2","Item3"],
	"Selected": "Item"
}
```

## Disclosures

### Data Collected

PostHog provides a comprehensize suite of data collection tools, and SANDO makes use of a relatively small subset of these features. By using the current version of the software, you agree to the following data being collected (as of 10/14/2025).

1. A unique `sessionID` that is associated with your play-session
2. User-specific information information
	- User-defined Name (`string`)
	- Processor & GPU name (`string`)
	- OS Name (`string`)
3. In-game Events*

* In-game Events are in development, and as such change often.

### Use of Data Collected

Data collected in SANDO is used for the purpose of balancing gameplay.