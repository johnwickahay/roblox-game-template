# Game Design Scaffold

## Hub + Tasks Pattern

This template is structured to support a common Roblox game pattern: **Hub World with Task-Based Gameplay**.

### The Pattern

```
┌─────────────────────────────────────────────────────┐
│                     HUB WORLD                       │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐             │
│  │  Shop   │  │ Portals │  │ Social  │             │
│  └─────────┘  └─────────┘  └─────────┘             │
│                    │                                │
│        ┌──────────┼──────────┐                     │
│        ▼          ▼          ▼                     │
│   ┌─────────┐┌─────────┐┌─────────┐               │
│   │ Task 1  ││ Task 2  ││ Task 3  │               │
│   │ (Obby)  ││(Collect)││ (Boss)  │               │
│   └─────────┘└─────────┘└─────────┘               │
│        │          │          │                     │
│        └──────────┼──────────┘                     │
│                   ▼                                │
│            ┌─────────────┐                         │
│            │  Rewards    │                         │
│            │  Currency   │                         │
│            │  Progress   │                         │
│            └─────────────┘                         │
└─────────────────────────────────────────────────────┘
```

### Why This Pattern?

1. **Player Agency** - Players choose what to do
2. **Session Flexibility** - Quick tasks or long sessions
3. **Monetization Ready** - Natural shop integration
4. **Social Features** - Hub enables player interaction
5. **Content Scaling** - Add tasks without restructuring

## Current Template State

The template provides the foundation:

| Component | Status | Location |
|-----------|--------|----------|
| Server Bootstrap | ✅ | `server/ServerScriptService/main.server.lua` |
| Client Bootstrap | ✅ | `client/StarterPlayerScripts/main.client.lua` |
| Remote Events | ✅ | `shared/ReplicatedStorage/Shared/remotes.lua` |
| Configuration | ✅ | `shared/ReplicatedStorage/Shared/config.lua` |
| UI System | ✅ | `client/StarterGui/ui.client.lua` |
| Example Service | ✅ | `server/ServerScriptService/services/ping_service.lua` |

## Building Your Hub

### Step 1: Define Your World

Create your hub in Roblox Studio:
- Design the central area
- Add portal locations (empty parts to mark positions)
- Create shop NPC/kiosk positions
- Design social spaces

### Step 2: Add Portal System

```lua
-- server/ServerScriptService/services/portal_service.lua
local PortalService = {}

local PORTALS = {
    { name = "Obby1", destination = Vector3.new(0, 100, 0) },
    { name = "BossArena", destination = Vector3.new(500, 0, 0) },
}

function PortalService.init(remotes)
    -- Listen for portal touch events
    -- Teleport players to task areas
end

return PortalService
```

### Step 3: Implement Task Manager

```lua
-- server/ServerScriptService/services/task_service.lua
local TaskService = {}

export type Task = {
    id: string,
    name: string,
    type: "obby" | "collect" | "combat",
    rewards: { coins: number, xp: number },
}

function TaskService.startTask(player, taskId)
    -- Track player's active task
    -- Set up task-specific state
end

function TaskService.completeTask(player, taskId)
    -- Validate completion
    -- Award rewards
    -- Return player to hub
end

return TaskService
```

## Suggested Architecture

```
services/
├── player_service.lua      # Player data, join/leave
├── portal_service.lua      # Hub ↔ Task transitions
├── task_service.lua        # Task lifecycle
├── reward_service.lua      # Currency, XP, items
├── shop_service.lua        # Purchases, inventory
└── leaderboard_service.lua # Rankings, achievements
```

## Data Model Suggestion

```lua
export type PlayerData = {
    -- Progress
    coins: number,
    xp: number,
    level: number,

    -- Inventory
    items: { [string]: number },

    -- Tasks
    completedTasks: { [string]: number }, -- taskId -> completionCount
    currentTask: string?, -- nil when in hub

    -- Stats
    totalPlayTime: number,
    joinDate: number,
}
```

## Next Steps

1. Design your hub world in Studio
2. Implement `player_service.lua` for data persistence
3. Create your first task type
4. Add rewards and progression
5. Build the shop UI

See [030-roadmap.md](./030-roadmap.md) for detailed implementation order.
