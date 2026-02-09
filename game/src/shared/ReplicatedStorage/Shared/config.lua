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
	gameName = "Starburst Clicker",
	version = "1.0.0",
	buildDate = "2025-02-10",

	-- Debug mode: enables verbose logging and dev tools
	debug = true,

	-- Feature flags: toggle features without code changes
	features = {
		roundSystem = true,
		scoreClicks = true,
		-- Add your feature flags here:
		-- analytics = false,
		-- matchmaking = false,
	},
}

return Config
