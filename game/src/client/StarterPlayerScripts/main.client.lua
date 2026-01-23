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

-- Track pending ping for latency calculation
local pendingPingTimestamp: number? = nil

-- Handle ping response from server
local function onPingResponse(response: Types.PingResponse)
	local roundTripTime = 0

	if pendingPingTimestamp then
		roundTripTime = (os.clock() - pendingPingTimestamp) * 1000 -- Convert to ms
		pendingPingTimestamp = nil
	end

	local statusText = response.message
	if Config.debug then
		statusText = `{response.message} (RTT: {math.floor(roundTripTime)}ms)`
	end

	UI.setStatus(statusText)

	if Config.debug then
		print(`[Client] Ping response: {response.message}`)
		print(`[Client] Round-trip time: {math.floor(roundTripTime)}ms`)
	end
end

-- Send ping to server
local function sendPing()
	pendingPingTimestamp = os.clock()
	UI.setStatus("Pinging server...")
	remotes.Ping:FireServer(pendingPingTimestamp)

	if Config.debug then
		print("[Client] Ping sent to server")
	end
end

-- Connect UI events
UI.onPingClicked(sendPing)

-- Connect to server response
remotes.Ping.OnClientEvent:Connect(onPingResponse)

print("[Client] Initialization complete!")
print("[Client] Click the 'Ping Server' button to test connectivity")
