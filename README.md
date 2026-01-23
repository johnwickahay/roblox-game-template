# Roblox Game Template

[![CI](https://github.com/intent-solutions/roblox-game-template/actions/workflows/ci.yml/badge.svg)](https://github.com/intent-solutions/roblox-game-template/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A **production-ready** Roblox game template with professional tooling, type safety, and extensible architecture.

## What Makes This Different

| Feature | Basic Templates | This Template |
|---------|-----------------|---------------|
| Type Safety | None | 100% `--!strict` Luau |
| Tooling | Rojo only | Rojo + Wally + Selene + StyLua + Aftman |
| Testing | None | TestEZ examples |
| CI/CD | None | GitHub Actions (lint, format, build) |
| Documentation | README only | Full architecture + setup + roadmap |
| Examples | Hello world | Working ping system + UI |

## Quick Start

### Prerequisites

1. [Roblox Studio](https://create.roblox.com/)
2. [Rojo Plugin](https://www.roblox.com/library/13916111004/Rojo) for Studio
3. [Aftman](https://github.com/LPGhatguy/aftman) - Roblox toolchain manager

### Setup

```bash
# Clone the template
git clone https://github.com/intent-solutions/roblox-game-template.git my-game
cd my-game

# Install tools
aftman install

# Start Rojo sync server
rojo serve game/
```

### Connect Studio

1. Open Roblox Studio (new Baseplate)
2. Click **Rojo** plugin → **Connect**
3. Press **F5** to play
4. Click "Ping Server" button → see response!

## Project Structure

```
roblox-game-template/
├── .github/workflows/     # CI/CD pipeline
├── docs/                  # Documentation
├── game/
│   ├── default.project.json
│   └── src/
│       ├── client/        # Client scripts
│       ├── server/        # Server scripts
│       └── shared/        # Shared modules
├── tests/                 # TestEZ tests
├── aftman.toml           # Tool versions
├── selene.toml           # Linter config
├── stylua.toml           # Formatter config
└── wally.toml            # Package manager
```

## Documentation

- [Setup Guide](docs/001-setup.md) - Detailed installation steps
- [Architecture](docs/020-architecture.md) - Client/server boundaries explained
- [Game Design](docs/010-game-design.md) - Hub + tasks scaffold
- [Roadmap](docs/030-roadmap.md) - Next 10 features to implement

## Tooling

| Tool | Purpose | Command |
|------|---------|---------|
| **Rojo** | Filesystem ↔ Studio sync | `rojo serve game/` |
| **Selene** | Lua/Luau linter | `selene game/src/` |
| **StyLua** | Code formatter | `stylua game/src/` |
| **Wally** | Package manager | `wally install` |

## Development Workflow

```bash
# Start development
rojo serve game/

# Before committing
stylua game/src/        # Format
selene game/src/        # Lint
rojo build game/ -o test.rbxl  # Verify build
```

## What's Included

### Shared Modules
- **config.lua** - Game configuration with feature flags
- **types.lua** - Type definitions and constants
- **remotes.lua** - Centralized RemoteEvent management
- **signal.lua** - Lightweight event system
- **promise.lua** - Async operation handling

### Server
- **main.server.lua** - Server bootstrap with error handling
- **ping_service.lua** - Example service with rate limiting

### Client
- **main.client.lua** - Client bootstrap
- **ui.client.lua** - Programmatic UI system

## Publishing to Roblox

1. Build the game: `rojo build game/ -o game.rbxl`
2. Open `game.rbxl` in Studio
3. File → Publish to Roblox

Or use Rojo's live sync and publish directly from Studio.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run `stylua` and `selene`
5. Submit a pull request

## License

[MIT](LICENSE) - Use this template for any project, commercial or otherwise.

## Credits

Built by [Intent Solutions](https://github.com/intent-solutions)

---

**Start building your game!** Check the [roadmap](docs/030-roadmap.md) for what to implement next.
