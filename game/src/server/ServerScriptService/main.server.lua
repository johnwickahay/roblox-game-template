--!strict
--[[
	main.server.lua - Server Bootstrap

	Entry point for all server-side code. Initializes shared modules,
	creates remotes, and starts all services.

	This script runs once when the server starts.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Wait for shared modules to be available
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))

-- Services
local Services = ServerScriptService:WaitForChild("services")
local RoundService = require(Services:WaitForChild("round_service"))

-- Boot banner
print("========================================")
print(`  {Config.gameName}`)
print(`  Version: {Config.version}`)
print(`  Debug: {Config.debug}`)
print("========================================")
print("[Server] Initializing...")

-- Initialize remotes (must be done on server first)
local remotes = Remotes.ensure()
print("[Server] Remotes initialized")

-- Initialize services
local function initializeServices()
	-- Start RoundService
	if Config.features.roundSystem then
		RoundService.init(remotes)
		print("[Server] RoundService started")
	end

	-- Add more service initializations here:
	-- DataService.init(remotes)
	-- MatchmakingService.init(remotes)
end

-- Protected initialization with error handling
local success, err = pcall(initializeServices)

if success then
	print("[Server] All services initialized successfully")
	print("[Server] Ready for players!")
else
	warn("[Server] CRITICAL: Service initialization failed!")
	warn("[Server] Error:", err)
	-- In production, you might want to:
	-- - Send analytics
	-- - Gracefully handle the failure
	-- - Prevent players from joining
end
