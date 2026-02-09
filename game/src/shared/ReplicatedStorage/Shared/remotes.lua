--!strict
--[[
	remotes.lua - Remote Event Management

	Centralizes RemoteEvent creation and access. Call ensure()
	on the server to create all remotes, then access them via
	the returned table on both client and server.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(script.Parent.Types)

export type Remotes = {
	StartRound: RemoteEvent,
	CollectStar: RemoteEvent,
	RoundUpdate: RemoteEvent,
	-- Add more remote types here
}

local Remotes = {}

-- Remote folder name
local FOLDER_NAME = "Remotes"

-- List of remotes to create
local REMOTE_EVENTS = {
	Types.Remotes.StartRound,
	Types.Remotes.CollectStar,
	Types.Remotes.RoundUpdate,
	-- Add more remote names here
}

--[[
	Ensures all remotes exist. Call this on the server during initialization.
	On the client, remotes are accessed via get().

	@return Remotes table with typed remote references
]]
function Remotes.ensure(): Remotes
	local folder = ReplicatedStorage:FindFirstChild(FOLDER_NAME)

	if not folder then
		folder = Instance.new("Folder")
		folder.Name = FOLDER_NAME
		folder.Parent = ReplicatedStorage
	end

	local remotes: any = {}

	for _, name in ipairs(REMOTE_EVENTS) do
		local remote = folder:FindFirstChild(name)
		if not remote then
			remote = Instance.new("RemoteEvent")
			remote.Name = name
			remote.Parent = folder
		end
		remotes[name] = remote
	end

	return remotes :: Remotes
end

--[[
	Gets remotes from ReplicatedStorage. Use on client after server has
	called ensure(). Waits briefly for the folder to exist.

	@return Remotes table with typed remote references
]]
function Remotes.get(): Remotes
	local folder = ReplicatedStorage:WaitForChild(FOLDER_NAME, 10)
	assert(folder, "Remotes folder not found - server may not be initialized")

	local remotes: any = {}

	for _, name in ipairs(REMOTE_EVENTS) do
		local remote = folder:WaitForChild(name, 5)
		assert(remote, `Remote '{name}' not found`)
		remotes[name] = remote
	end

	return remotes :: Remotes
end

return Remotes
