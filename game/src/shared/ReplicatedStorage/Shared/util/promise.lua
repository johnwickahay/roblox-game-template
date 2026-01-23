--!strict
--[[
	promise.lua - Minimal Promise Implementation

	A lightweight Promise implementation for async operations.
	For production games, consider using evaera/promise from Wally instead.

	Usage:
		local Promise = require(path.to.promise)

		local myPromise = Promise.new(function(resolve, reject)
			task.delay(1, function()
				resolve("Done!")
			end)
		end)

		myPromise:andThen(function(value)
			print(value) -- "Done!"
		end):catch(function(err)
			warn("Error:", err)
		end)
]]

export type PromiseStatus = "Pending" | "Resolved" | "Rejected"

export type Promise<T> = {
	andThen: (self: Promise<T>, onResolve: (T) -> (), onReject: ((any) -> ())?) -> Promise<T>,
	catch: (self: Promise<T>, onReject: (any) -> ()) -> Promise<T>,
	finally: (self: Promise<T>, callback: () -> ()) -> Promise<T>,
	getStatus: (self: Promise<T>) -> PromiseStatus,
	await: (self: Promise<T>) -> (boolean, T | any),
}

type PromiseInternal<T> = {
	_status: PromiseStatus,
	_value: T?,
	_error: any?,
	_thenCallbacks: { (T) -> () },
	_catchCallbacks: { (any) -> () },
	_finallyCallbacks: { () -> () },
}

local Promise = {}
Promise.__index = Promise

--[[
	Creates a new Promise.

	@param executor Function receiving (resolve, reject) functions
	@return A new Promise object
]]
function Promise.new<T>(executor: (resolve: (T) -> (), reject: (any) -> ()) -> ()): Promise<T>
	local self: PromiseInternal<T> = {
		_status = "Pending",
		_value = nil,
		_error = nil,
		_thenCallbacks = {},
		_catchCallbacks = {},
		_finallyCallbacks = {},
	}

	setmetatable(self, Promise)

	local function resolve(value: T)
		if self._status ~= "Pending" then
			return
		end

		self._status = "Resolved"
		self._value = value

		for _, callback in ipairs(self._thenCallbacks) do
			task.spawn(callback, value)
		end

		for _, callback in ipairs(self._finallyCallbacks) do
			task.spawn(callback)
		end
	end

	local function reject(err: any)
		if self._status ~= "Pending" then
			return
		end

		self._status = "Rejected"
		self._error = err

		for _, callback in ipairs(self._catchCallbacks) do
			task.spawn(callback, err)
		end

		for _, callback in ipairs(self._finallyCallbacks) do
			task.spawn(callback)
		end
	end

	task.spawn(function()
		local success, err = pcall(executor, resolve, reject)
		if not success then
			reject(err)
		end
	end)

	return self :: any
end

--[[
	Creates an immediately resolved Promise.

	@param value The value to resolve with
	@return A resolved Promise
]]
function Promise.resolve<T>(value: T): Promise<T>
	return Promise.new(function(resolve)
		resolve(value)
	end)
end

--[[
	Creates an immediately rejected Promise.

	@param err The error to reject with
	@return A rejected Promise
]]
function Promise.reject<T>(err: any): Promise<T>
	return Promise.new(function(_, reject)
		reject(err)
	end)
end

--[[
	Chains a callback to be called when the Promise resolves.

	@param onResolve Callback for resolution
	@param onReject Optional callback for rejection
	@return Self for chaining
]]
function Promise:andThen<T>(onResolve: (T) -> (), onReject: ((any) -> ())?): Promise<T>
	if self._status == "Resolved" then
		task.spawn(onResolve, self._value :: T)
	elseif self._status == "Rejected" then
		if onReject then
			task.spawn(onReject, self._error)
		end
	else
		table.insert(self._thenCallbacks, onResolve)
		if onReject then
			table.insert(self._catchCallbacks, onReject)
		end
	end

	return self :: any
end

--[[
	Chains a callback to be called when the Promise rejects.

	@param onReject Callback for rejection
	@return Self for chaining
]]
function Promise:catch<T>(onReject: (any) -> ()): Promise<T>
	if self._status == "Rejected" then
		task.spawn(onReject, self._error)
	elseif self._status == "Pending" then
		table.insert(self._catchCallbacks, onReject)
	end

	return self :: any
end

--[[
	Chains a callback to be called when the Promise settles (resolves or rejects).

	@param callback Callback to run on settlement
	@return Self for chaining
]]
function Promise:finally<T>(callback: () -> ()): Promise<T>
	if self._status ~= "Pending" then
		task.spawn(callback)
	else
		table.insert(self._finallyCallbacks, callback)
	end

	return self :: any
end

--[[
	Gets the current status of the Promise.

	@return "Pending", "Resolved", or "Rejected"
]]
function Promise:getStatus(): PromiseStatus
	return self._status
end

--[[
	Yields until the Promise settles, then returns the result.

	@return success: boolean, result: value or error
]]
function Promise:await<T>(): (boolean, T | any)
	while self._status == "Pending" do
		task.wait()
	end

	if self._status == "Resolved" then
		return true, self._value :: T
	else
		return false, self._error
	end
end

return Promise
