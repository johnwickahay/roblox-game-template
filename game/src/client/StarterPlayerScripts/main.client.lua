--!strict
--[[
	main.client.lua - Client Bootstrap

	Entry point for all client-side code. Waits for shared modules,
	initializes UI, and connects to server remotes.

	This script runs once when the player's client loads.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Wait for shared modules
local Shared = ReplicatedStorage:WaitForChild("Shared", 30)
assert(Shared, "Failed to load Shared modules - server may not be ready")

local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Types = require(Shared:WaitForChild("Types"))

-- Get player
local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "LocalPlayer not available")

-- Boot banner
print("========================================")
print(`  {Config.gameName} - Client`)
print(`  Player: {LocalPlayer.Name}`)
print(`  Debug: {Config.debug}`)
print("========================================")
print("[Client] Initializing...")

-- Get remotes (created by server)
local remotes = Remotes.get()
print("[Client] Connected to remotes")

-- Wait for UI module
local StarterGui = LocalPlayer:WaitForChild("PlayerGui")
local UI = require(StarterGui:WaitForChild("ui"))

print("[Client] UI module loaded")

local function onRoundUpdate(update: Types.RoundUpdate)
	UI.setStatus(update.message)
	UI.setScore(update.score)
	UI.setTimer(update.timeLeft)
	UI.setState(update.state)

	if Config.debug then
		print(`[Client] Round update: {update.state} | Score: {update.score} | Time: {update.timeLeft}s`)
	end
end

local function requestStart()
	UI.setStatus("Starting round...")
	remotes.StartRound:FireServer()
end

local function collectStar()
	remotes.CollectStar:FireServer()
end

UI.onStartClicked(requestStart)
UI.onCollectClicked(collectStar)

remotes.RoundUpdate.OnClientEvent:Connect(onRoundUpdate)

print("[Client] Initialization complete!")
print("[Client] Tap Start to begin a round.")
