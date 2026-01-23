# Architecture Guide

## Core Principles

### 1. Client-Server Boundary

Roblox uses a client-server model. **Never trust the client.**

```
┌─────────────────┐          ┌─────────────────┐
│     CLIENT      │          │     SERVER      │
│                 │          │                 │
│  UI Display     │◄────────►│  Game Logic     │
│  Input Handling │ RemoteEvents │  Data Storage │
│  Visual Effects │          │  Validation     │
│                 │          │                 │
└─────────────────┘          └─────────────────┘
        │                            │
        └──────────┬─────────────────┘
                   │
           ┌───────▼───────┐
           │    SHARED     │
           │               │
           │  Types        │
           │  Constants    │
           │  Utilities    │
           │  Config       │
           └───────────────┘
```

### 2. Directory Structure

```
game/src/
├── client/                    # CLIENT ONLY
│   ├── StarterPlayerScripts/  # Runs when player joins
│   │   └── main.client.lua    # Client entry point
│   └── StarterGui/            # UI scripts
│       └── ui.client.lua      # UI creation/management
│
├── server/                    # SERVER ONLY
│   └── ServerScriptService/
│       ├── main.server.lua    # Server entry point
│       └── services/          # Server services
│           └── ping_service.lua
│
└── shared/                    # BOTH CLIENT AND SERVER
    └── ReplicatedStorage/
        └── Shared/
            ├── config.lua     # Game configuration
            ├── types.lua      # Type definitions
            ├── remotes.lua    # Remote event management
            └── util/
                ├── signal.lua
                └── promise.lua
```

### 3. What Goes Where?

| Code Type | Location | Why |
|-----------|----------|-----|
| UI rendering | `client/` | Only client sees UI |
| Input handling | `client/` | Only client has input |
| Visual effects | `client/` | Performance, client-side prediction |
| Game logic | `server/` | Authority, anti-cheat |
| Data persistence | `server/` | Security, DataStore access |
| Validation | `server/` | Never trust client |
| Type definitions | `shared/` | Both need same types |
| Constants | `shared/` | Consistency |
| Pure utilities | `shared/` | Code reuse |

## Remote Events

### Pattern: Request-Response

```lua
-- CLIENT: Send request
remotes.Ping:FireServer(timestamp)

-- SERVER: Handle and respond
remotes.Ping.OnServerEvent:Connect(function(player, timestamp)
    -- Validate, process, then respond
    remotes.Ping:FireClient(player, response)
end)

-- CLIENT: Handle response
remotes.Ping.OnClientEvent:Connect(function(response)
    -- Update UI with response
end)
```

### Security Rules

1. **Validate all input** - Check types, ranges, permissions
2. **Rate limit** - Prevent spam (see `ping_service.lua`)
3. **Authorize actions** - Can this player do this action?
4. **Sanitize data** - Never trust client-provided strings

```lua
-- BAD: Trusting client data
remotes.GiveCoins.OnServerEvent:Connect(function(player, amount)
    playerData[player].coins += amount  -- EXPLOITABLE!
end)

-- GOOD: Server authoritative
remotes.ClaimReward.OnServerEvent:Connect(function(player, rewardId)
    if canClaimReward(player, rewardId) then
        local reward = REWARDS[rewardId]
        playerData[player].coins += reward.coins  -- Server decides amount
    end
end)
```

## Service Pattern

Services encapsulate related server functionality:

```lua
-- services/example_service.lua
--!strict

local ExampleService = {}

-- Private state
local playerStates: { [Player]: State } = {}

-- Private functions
local function validateAction(player, action)
    -- ...
end

-- Public API
function ExampleService.init(remotes)
    -- Set up event listeners
    -- Initialize state
end

function ExampleService.doSomething(player, ...)
    -- Public method for other services to call
end

return ExampleService
```

### Service Initialization

```lua
-- main.server.lua
local Services = ServerScriptService:WaitForChild("services")

-- Initialize in dependency order
local PlayerService = require(Services.player_service)
local RewardService = require(Services.reward_service)
local TaskService = require(Services.task_service)

PlayerService.init(remotes)
RewardService.init(remotes, PlayerService)  -- Depends on PlayerService
TaskService.init(remotes, PlayerService, RewardService)
```

## Type Safety

All modules use `--!strict` mode. Define types explicitly:

```lua
--!strict

export type PlayerState = {
    coins: number,
    level: number,
    inventory: { [string]: number },
}

local function processPlayer(player: Player, state: PlayerState): boolean
    -- Type-checked implementation
    return true
end
```

### Benefits

1. **Catch errors early** - Before runtime
2. **Better autocomplete** - IDE knows types
3. **Self-documenting** - Types explain intent
4. **Refactoring safety** - Type errors reveal issues

## State Management

### Server State

```lua
-- Server owns authoritative state
local playerData: { [Player]: PlayerData } = {}

-- Clean up on leave
Players.PlayerRemoving:Connect(function(player)
    savePlayerData(player, playerData[player])
    playerData[player] = nil
end)
```

### Client State

```lua
-- Client caches server state for UI
local cachedPlayerData: PlayerData? = nil

-- Update from server
remotes.PlayerDataUpdated.OnClientEvent:Connect(function(data)
    cachedPlayerData = data
    updateUI(data)
end)
```

### Synchronization Pattern

```
Server                          Client
   │                               │
   │  Initial data on join         │
   ├──────────────────────────────►│
   │                               │
   │  Player action request        │
   │◄──────────────────────────────┤
   │                               │
   │  Validate & process           │
   │                               │
   │  Updated data                 │
   ├──────────────────────────────►│
   │                               │
```

## Error Handling

### Server

```lua
local success, err = pcall(function()
    -- Risky operation
end)

if not success then
    warn("[ServiceName] Error:", err)
    -- Log to analytics
    -- Graceful degradation
end
```

### Client

```lua
-- Defensive UI updates
local function updateUI(data)
    if not data then
        showErrorState()
        return
    end
    -- Normal update
end
```

## Performance Considerations

1. **Minimize RemoteEvent traffic** - Batch updates when possible
2. **Use client-side prediction** - Show immediate feedback, reconcile with server
3. **Lazy load modules** - Only require when needed
4. **Clean up connections** - Disconnect events when no longer needed

```lua
-- Connection cleanup pattern
local connections = {}

function Module.init()
    table.insert(connections, event:Connect(handler))
end

function Module.destroy()
    for _, conn in ipairs(connections) do
        conn:Disconnect()
    end
    table.clear(connections)
end
```
