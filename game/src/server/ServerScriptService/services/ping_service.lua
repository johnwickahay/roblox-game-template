--!strict
--[[
	ping_service.lua - Example Server Service

	Demonstrates a basic server service pattern:
	- Listens to remote events
	- Processes player requests
	- Implements rate limiting
	- Returns typed responses

	Use this as a template for your own services.
]]

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Types = require(Shared:WaitForChild("Types"))
local Config = require(Shared:WaitForChild("Config"))

-- Type imports
type PingResponse = Types.PingResponse
type Remotes = {
	Ping: RemoteEvent,
}

local PingService = {}

-- Rate limiting: track last ping time per player
local lastPingTime: { [Player]: number } = {}
local COOLDOWN_SECONDS = 0.5 -- Minimum time between pings

-- Clean up when player leaves
local function onPlayerRemoving(player: Player)
	lastPingTime[player] = nil
end

-- Handle ping request from client
local function onPingReceived(player: Player, clientTimestamp: number?)
	-- Rate limiting check
	local now = os.clock()
	local lastTime = lastPingTime[player]

	if lastTime and (now - lastTime) < COOLDOWN_SECONDS then
		if Config.debug then
			print(`[PingService] Rate limited: {player.Name}`)
		end
		return -- Silently ignore rate-limited requests
	end

	lastPingTime[player] = now

	-- Build response
	local response: PingResponse = {
		timestamp = clientTimestamp or 0,
		message = `Pong! Hello, {player.Name}!`,
		serverTime = workspace:GetServerTimeNow(),
	}

	if Config.debug then
		print(`[PingService] Ping from {player.Name}, responding...`)
	end

	return response
end

--[[
	Initializes the PingService.

	@param remotes The remotes table from Remotes.ensure()
]]
function PingService.init(remotes: Remotes)
	-- Connect to remote event
	remotes.Ping.OnServerEvent:Connect(function(player: Player, clientTimestamp: number?)
		local response = onPingReceived(player, clientTimestamp)
		if response then
			remotes.Ping:FireClient(player, response)
		end
	end)

	-- Clean up on player leave
	Players.PlayerRemoving:Connect(onPlayerRemoving)

	if Config.debug then
		print("[PingService] Initialized with cooldown:", COOLDOWN_SECONDS, "seconds")
	end
end

return PingService
