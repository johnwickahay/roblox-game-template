--!strict
--[[
	example.spec.lua - TestEZ Example Tests

	Demonstrates unit testing patterns for Roblox using TestEZ.

	To run tests:
	1. Install TestEZ via Wally (uncomment in wally.toml)
	2. Run: wally install
	3. Set up a test runner in your game

	TestEZ documentation: https://roblox.github.io/testez/
]]

return function()
	describe("Signal", function()
		local Signal

		beforeAll(function()
			-- In actual tests, you'd require from the Packages folder
			-- For this example, we'll create a mock
			Signal = {
				new = function()
					local connections = {}
					return {
						Connect = function(_, callback)
							table.insert(connections, callback)
							return {
								Disconnect = function()
									local idx = table.find(connections, callback)
									if idx then
										table.remove(connections, idx)
									end
								end,
							}
						end,
						Fire = function(_, ...)
							for _, cb in ipairs(connections) do
								cb(...)
							end
						end,
						Destroy = function()
							table.clear(connections)
						end,
					}
				end,
			}
		end)

		it("should create a new signal", function()
			local signal = Signal.new()
			expect(signal).to.be.ok()
			expect(signal.Connect).to.be.a("function")
			expect(signal.Fire).to.be.a("function")
		end)

		it("should connect and fire callbacks", function()
			local signal = Signal.new()
			local received = nil

			signal:Connect(function(value)
				received = value
			end)

			signal:Fire("test")

			expect(received).to.equal("test")
		end)

		it("should support multiple connections", function()
			local signal = Signal.new()
			local count = 0

			signal:Connect(function()
				count = count + 1
			end)
			signal:Connect(function()
				count = count + 1
			end)

			signal:Fire()

			expect(count).to.equal(2)
		end)

		it("should disconnect properly", function()
			local signal = Signal.new()
			local count = 0

			local connection = signal:Connect(function()
				count = count + 1
			end)

			signal:Fire()
			expect(count).to.equal(1)

			connection:Disconnect()
			signal:Fire()
			expect(count).to.equal(1) -- Should not increment after disconnect
		end)
	end)

	describe("Config", function()
		it("should have required fields", function()
			-- In actual tests, require the real Config module
			local Config = {
				gameName = "Test Game",
				version = "1.0.0",
				debug = true,
				features = {},
			}

			expect(Config.gameName).to.be.a("string")
			expect(Config.version).to.be.a("string")
			expect(Config.debug).to.be.a("boolean")
			expect(Config.features).to.be.a("table")
		end)

		it("should have valid version format", function()
			local Config = {
				version = "1.0.0",
			}

			-- Simple semver check
			local major, minor, patch = Config.version:match("^(%d+)%.(%d+)%.(%d+)$")
			expect(major).to.be.ok()
			expect(minor).to.be.ok()
			expect(patch).to.be.ok()
		end)
	end)

	describe("Types", function()
		it("should export remote names", function()
			local Types = {
				Remotes = {
					Ping = "Ping",
				},
			}

			expect(Types.Remotes).to.be.a("table")
			expect(Types.Remotes.Ping).to.equal("Ping")
		end)

		it("should have default player data", function()
			local Types = {
				DefaultPlayerData = {
					coins = 0,
					level = 1,
					joinDate = 0,
				},
			}

			expect(Types.DefaultPlayerData.coins).to.equal(0)
			expect(Types.DefaultPlayerData.level).to.equal(1)
		end)
	end)
end
