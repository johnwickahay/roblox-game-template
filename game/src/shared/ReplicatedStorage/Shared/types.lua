--!strict
--[[
	types.lua - Type Definitions and Constants

	Centralized type definitions and constants used across
	client and server code.
]]

local Types = {}

-- Remote event names (use these constants instead of strings)
Types.Remotes = {
	Ping = "Ping",
	-- Add more remote names here:
	-- PlayerData = "PlayerData",
	-- GameState = "GameState",
}

-- Game states
export type GameState = "Loading" | "Lobby" | "Playing" | "Ended"

Types.GameState = {
	Loading = "Loading" :: GameState,
	Lobby = "Lobby" :: GameState,
	Playing = "Playing" :: GameState,
	Ended = "Ended" :: GameState,
}

-- Player data structure (example)
export type PlayerData = {
	coins: number,
	level: number,
	joinDate: number,
}

Types.DefaultPlayerData: PlayerData = {
	coins = 0,
	level = 1,
	joinDate = 0,
}

-- Ping response structure
export type PingResponse = {
	timestamp: number,
	message: string,
	serverTime: number,
}

return Types
