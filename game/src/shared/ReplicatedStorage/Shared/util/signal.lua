--!strict
--[[
	signal.lua - Lightweight Signal Implementation

	A minimal signal/event system for custom events within your game.
	Use this for local communication (not client-server; use RemoteEvents for that).

	Usage:
		local Signal = require(path.to.signal)
		local mySignal = Signal.new()

		local connection = mySignal:Connect(function(value)
			print("Received:", value)
		end)

		mySignal:Fire("Hello!")
		connection:Disconnect()
]]

export type Connection = {
	Disconnect: (self: Connection) -> (),
	Connected: boolean,
}

export type Signal<T...> = {
	Connect: (self: Signal<T...>, callback: (T...) -> ()) -> Connection,
	Once: (self: Signal<T...>, callback: (T...) -> ()) -> Connection,
	Fire: (self: Signal<T...>, T...) -> (),
	Wait: (self: Signal<T...>) -> T...,
	Destroy: (self: Signal<T...>) -> (),
}

type ConnectionInternal = {
	callback: (...any) -> (),
	connected: boolean,
}

type SignalInternal = {
	_connections: { ConnectionInternal },
	_destroyed: boolean,
}

local Signal = {}
Signal.__index = Signal

--[[
	Creates a new Signal instance.

	@return A new Signal object
]]
function Signal.new<T...>(): Signal<T...>
	local self: SignalInternal = {
		_connections = {},
		_destroyed = false,
	}
	return setmetatable(self, Signal) :: any
end

--[[
	Connects a callback to the signal.

	@param callback Function to call when signal fires
	@return Connection object with Disconnect method
]]
function Signal:Connect<T...>(callback: (T...) -> ()): Connection
	assert(not self._destroyed, "Cannot connect to destroyed signal")

	local connection: ConnectionInternal = {
		callback = callback,
		connected = true,
	}

	table.insert(self._connections, connection)

	local connectionHandle: Connection = {
		Connected = true,
		Disconnect = function(conn: Connection)
			if not connection.connected then
				return
			end
			connection.connected = false
			conn.Connected = false

			local index = table.find(self._connections, connection)
			if index then
				table.remove(self._connections, index)
			end
		end,
	}

	return connectionHandle
end

--[[
	Connects a callback that disconnects after first fire.

	@param callback Function to call once
	@return Connection object
]]
function Signal:Once<T...>(callback: (T...) -> ()): Connection
	local connection: Connection
	connection = self:Connect(function(...)
		connection:Disconnect()
		callback(...)
	end)
	return connection
end

--[[
	Fires the signal, calling all connected callbacks.

	@param ... Arguments to pass to callbacks
]]
function Signal:Fire<T...>(...: T...)
	if self._destroyed then
		return
	end

	for _, connection in ipairs(self._connections) do
		if connection.connected then
			task.spawn(connection.callback, ...)
		end
	end
end

--[[
	Yields until the signal fires, then returns the fired values.

	@return The values passed to Fire()
]]
function Signal:Wait<T...>(): T...
	local thread = coroutine.running()

	self:Once(function(...)
		task.spawn(thread, ...)
	end)

	return coroutine.yield()
end

--[[
	Destroys the signal, disconnecting all connections.
]]
function Signal:Destroy()
	self._destroyed = true
	table.clear(self._connections)
end

return Signal
