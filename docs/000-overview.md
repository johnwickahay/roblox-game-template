# Overview

## What This Template Is

A production-ready Roblox game template that goes beyond basic tutorials. Built with professional tooling, type safety, and extensible architecture.

## Philosophy

1. **Type Safety First** - All code uses `--!strict` Luau annotations
2. **Professional Tooling** - Industry-standard tools (Rojo, Selene, StyLua, Wally)
3. **Clear Boundaries** - Strict client/server/shared separation
4. **Working Examples** - Not just scaffolding, but functional demonstrations
5. **Documentation** - Comprehensive guides for setup, architecture, and extending

## What's Included

### Tooling
- **Rojo** - Filesystem-to-Studio sync
- **Selene** - Static analysis and linting
- **StyLua** - Consistent code formatting
- **Wally** - Package management (optional dependencies)
- **Aftman** - Tool version management
- **GitHub Actions** - CI/CD pipeline

### Code Architecture
- Type-safe configuration system
- Centralized remote event management
- Signal implementation for events
- Promise implementation for async
- Example service (PingService) with rate limiting
- Example UI system with programmatic creation

### Documentation
- Step-by-step setup guide
- Architecture explanation
- Game design scaffold
- Development roadmap

## What This Template Is NOT

- **Not a game** - This is a starting point, not a finished product
- **Not a framework** - No heavy abstractions; simple, readable patterns
- **Not opinionated about game genre** - Works for any type of game

## Current State

This template provides a "first playable" experience:

1. Player spawns in the world
2. UI appears with title and ping button
3. Clicking ping sends request to server
4. Server responds with acknowledgment
5. Round-trip time displayed (in debug mode)

This demonstrates the full client-server communication loop with proper error handling and rate limiting.

## Next Steps

See [030-roadmap.md](./030-roadmap.md) for the logical next features to add to your game.
