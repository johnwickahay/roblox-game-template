--!strict
--[[
	round_service.lua - Starburst Clicker Game Loop

	Handles round lifecycle, player scoring, and server-authoritative updates.
]]

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Types = require(Shared:WaitForChild("Types"))
local Config = require(Shared:WaitForChild("Config"))

type GameState = Types.GameState
type RoundUpdate = Types.RoundUpdate
type Remotes = {
	StartRound: RemoteEvent,
	CollectStar: RemoteEvent,
	RoundUpdate: RemoteEvent,
}

type PlayerState = {
	state: GameState,
	score: number,
	roundEndTime: number,
	lastClickTime: number,
}

local RoundService = {}

local ROUND_LENGTH = 20
local CLICK_COOLDOWN = 0.05

local playerStates: { [Player]: PlayerState } = {}

local function getState(player: Player): PlayerState
	local existing = playerStates[player]
	if existing then
		return existing
	end

	local state: PlayerState = {
		state = Types.GameState.Idle,
		score = 0,
		roundEndTime = 0,
		lastClickTime = 0,
	}
	playerStates[player] = state
	return state
end

local function sendUpdate(player: Player, remotes: Remotes, message: string)
	local state = getState(player)
	local timeLeft = math.max(0, math.ceil(state.roundEndTime - os.clock()))
	local update: RoundUpdate = {
		state = state.state,
		timeLeft = timeLeft,
		score = state.score,
		message = message,
	}
	remotes.RoundUpdate:FireClient(player, update)
end

local function endRound(player: Player, remotes: Remotes)
	local state = getState(player)
	state.state = Types.GameState.Ended
	sendUpdate(player, remotes, "Round over! Great clicking!")
	state.state = Types.GameState.Idle
	sendUpdate(player, remotes, "Tap Start to play again.")
end

local function runRound(player: Player, remotes: Remotes)
	local state = getState(player)
	while state.state == Types.GameState.Playing do
		local timeLeft = state.roundEndTime - os.clock()
		if timeLeft <= 0 then
			break
		end
		sendUpdate(player, remotes, "Collect as many stars as you can!")
		task.wait(1)
	end

	endRound(player, remotes)
end

local function startRound(player: Player, remotes: Remotes)
	local state = getState(player)
	if state.state == Types.GameState.Playing then
		sendUpdate(player, remotes, "You're already in a round!")
		return
	end

	state.state = Types.GameState.Playing
	state.score = 0
	state.roundEndTime = os.clock() + ROUND_LENGTH
	state.lastClickTime = 0

	sendUpdate(player, remotes, "Round started! Click fast!")
	task.spawn(function()
		runRound(player, remotes)
	end)
end

local function registerClick(player: Player, remotes: Remotes)
	local state = getState(player)
	if state.state ~= Types.GameState.Playing then
		sendUpdate(player, remotes, "Start a round to collect stars.")
		return
	end

	local now = os.clock()
	if now - state.lastClickTime < CLICK_COOLDOWN then
		return
	end

	state.lastClickTime = now
	state.score += 1
	sendUpdate(player, remotes, "Star collected!")
end

local function onPlayerRemoving(player: Player)
	playerStates[player] = nil
end

function RoundService.init(remotes: Remotes)
	remotes.StartRound.OnServerEvent:Connect(function(player: Player)
		startRound(player, remotes)
	end)

	remotes.CollectStar.OnServerEvent:Connect(function(player: Player)
		if Config.features.scoreClicks then
			registerClick(player, remotes)
		end
	end)

	Players.PlayerRemoving:Connect(onPlayerRemoving)

	if Config.debug then
		print(`[RoundService] Ready. Round length: {ROUND_LENGTH}s`)
	end
end

return RoundService
