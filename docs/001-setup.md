# Setup Guide

## Prerequisites

Before you begin, ensure you have:

1. **Roblox Studio** installed
2. **Rojo Plugin** for Studio ([Install from Roblox](https://www.roblox.com/library/13916111004/Rojo))
3. **Aftman** - Roblox toolchain manager

### Installing Aftman

**Windows (PowerShell):**
```powershell
irm https://github.com/LPGhatguy/aftman/releases/latest/download/aftman-windows-x86_64.zip -OutFile aftman.zip
Expand-Archive aftman.zip -DestinationPath aftman
./aftman/aftman self-install
```

**macOS/Linux:**
```bash
curl -L https://github.com/LPGhatguy/aftman/releases/latest/download/aftman-linux-x86_64.zip -o aftman.zip
unzip aftman.zip
./aftman self-install
```

## Quick Start

### 1. Clone the Template

```bash
git clone https://github.com/intent-solutions/roblox-game-template.git my-game
cd my-game
```

### 2. Install Tools

```bash
aftman install
```

This installs:
- Rojo (sync tool)
- Selene (linter)
- StyLua (formatter)
- Wally (package manager)

### 3. Start Rojo Server

```bash
rojo serve game/
```

You should see:
```
Rojo server listening on port 34872
```

### 4. Connect Roblox Studio

1. Open Roblox Studio
2. Create a new Baseplate or open existing place
3. Click the **Rojo** plugin button
4. Click **Connect**

You should see "Connected!" in the Rojo plugin window.

### 5. Play Test

1. Press **F5** or click **Play** in Studio
2. Your character should spawn
3. A UI panel appears in the top-left corner
4. Click **"Ping Server"**
5. You should see a response like: `Pong! Hello, YourName! (RTT: 12ms)`

**Congratulations!** Your development environment is set up.

## Development Workflow

### Making Changes

1. Edit `.lua` files in your code editor (VS Code recommended)
2. Rojo automatically syncs changes to Studio
3. Press **F5** to test

### Before Committing

```bash
# Format code
stylua game/src/

# Lint code
selene game/src/

# Verify build
rojo build game/ -o test.rbxl
```

### Adding Packages (Optional)

1. Edit `wally.toml` to add dependencies
2. Run `wally install`
3. Update `game/default.project.json` to include `Packages/`

## Troubleshooting

### "Rojo plugin not connecting"
- Ensure `rojo serve game/` is running
- Check firewall isn't blocking port 34872
- Try restarting Studio

### "Module not found" errors
- Wait a few seconds for Rojo to sync
- Check the Output window for sync errors
- Verify file paths match Rojo project structure

### "Selene/StyLua not found"
- Run `aftman install` again
- Ensure `~/.aftman/bin` is in your PATH

## Next Steps

- Read [020-architecture.md](./020-architecture.md) to understand the code structure
- Check [030-roadmap.md](./030-roadmap.md) for feature ideas
- Modify `game/src/shared/ReplicatedStorage/Shared/config.lua` to customize your game
