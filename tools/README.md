# Tools

This directory contains development tools and scripts for the project.

## Installed Tools (via Aftman)

After running `aftman install`, you'll have access to:

### Rojo (v7.4.4)
Syncs your filesystem code with Roblox Studio.

```bash
# Start sync server
rojo serve game/

# Build to .rbxl file
rojo build game/ -o build.rbxl
```

### Selene (v0.27.1)
Lua/Luau linter that catches errors before runtime.

```bash
# Lint all game code
selene game/src/

# Lint specific file
selene game/src/server/ServerScriptService/main.server.lua
```

### StyLua (v0.20.0)
Opinionated Lua/Luau formatter.

```bash
# Check formatting (CI mode)
stylua --check game/src/

# Format all code
stylua game/src/

# Format specific file
stylua game/src/server/ServerScriptService/main.server.lua
```

### Wally (v0.3.2)
Package manager for Roblox.

```bash
# Install dependencies
wally install

# Search for packages
wally search promise
```

## Recommended VS Code Extensions

- **Rojo** - Rojo integration for VS Code
- **Selene** - Selene linting integration
- **StyLua** - Format on save support
- **Luau Language Server** - Type checking and intellisense

## Common Workflows

### Starting Development
```bash
# 1. Install tools
aftman install

# 2. Start Rojo
rojo serve game/

# 3. Open Roblox Studio and connect via Rojo plugin
```

### Before Committing
```bash
# 1. Format code
stylua game/src/

# 2. Lint code
selene game/src/

# 3. Test build
rojo build game/ -o test.rbxl
```

### Adding Dependencies
```bash
# 1. Add to wally.toml
# [dependencies]
# promise = "evaera/promise@4.0.0"

# 2. Install
wally install

# 3. Update Rojo project to include Packages folder
```

## Custom Scripts

Add your custom development scripts here. Examples:

- `build.sh` - Production build script
- `test.sh` - Run test suite
- `deploy.sh` - Deploy to Roblox (if using CI/CD)
