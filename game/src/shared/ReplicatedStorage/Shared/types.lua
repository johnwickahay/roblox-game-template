--!strict
--[[
	types.lua - Type Definitions and Constants

	Centralized type definitions and constants used across
	client and server code.
]]

local Types = {}

-- Remote event names (use these constants instead of strings)
Types.Remotes = {
	StartRound = "StartRound",
	CollectStar = "CollectStar",
	RoundUpdate = "RoundUpdate",
	-- Add more remote names here:
	-- PlayerData = "PlayerData",
	-- GameState = "GameState",
}

-- Game states
export type GameState = "Idle" | "Playing" | "Ended"

Types.GameState = {
	Idle = "Idle" :: GameState,
	Playing = "Playing" :: GameState,
	Ended = "Ended" :: GameState,
}

export type RoundUpdate = {
	state: GameState,
	timeLeft: number,
	score: number,
	message: string,
}

return Types
