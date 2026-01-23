--!strict
--[[
	config.lua - Game Configuration

	Central configuration for game settings. Modify these values
	to customize your game's behavior.
]]

export type Config = {
	gameName: string,
	version: string,
	buildDate: string,
	debug: boolean,
	features: {
		[string]: boolean,
	},
}

local Config: Config = {
	-- Game identity
	gameName = "Roblox Game Template",
	version = "0.1.0",
	buildDate = "2025-01-22",

	-- Debug mode: enables verbose logging and dev tools
	debug = true,

	-- Feature flags: toggle features without code changes
	features = {
		pingSystem = true,
		-- Add your feature flags here:
		-- analytics = false,
		-- matchmaking = false,
	},
}

return Config
