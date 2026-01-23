--!strict
--[[
	ui.client.lua - UI System

	Creates and manages the game's user interface.
	Uses a module pattern for clean separation of concerns.

	This is a LocalScript that creates UI elements programmatically.
	For complex UIs, consider using Roact or Fusion instead.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "LocalPlayer not available")

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Prevent duplicate initialization
if PlayerGui:FindFirstChild("GameUI") then
	return require(PlayerGui:FindFirstChild("GameUI") :: any)
end

-- UI Constants
local COLORS = {
	background = Color3.fromRGB(30, 30, 40),
	backgroundHover = Color3.fromRGB(40, 40, 55),
	primary = Color3.fromRGB(66, 135, 245),
	primaryHover = Color3.fromRGB(86, 155, 255),
	text = Color3.fromRGB(255, 255, 255),
	textMuted = Color3.fromRGB(180, 180, 190),
}

local UI = {}

-- Store references to UI elements
local elements: {
	screenGui: ScreenGui?,
	titleLabel: TextLabel?,
	pingButton: TextButton?,
	statusLabel: TextLabel?,
} = {}

-- Callbacks
local pingClickedCallbacks: { () -> () } = {}

-- Create the main ScreenGui
local function createScreenGui(): ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GameUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = false
	return screenGui
end

-- Create a styled frame
local function createMainFrame(parent: GuiObject): Frame
	local frame = Instance.new("Frame")
	frame.Name = "MainFrame"
	frame.Size = UDim2.new(0, 280, 0, 160)
	frame.Position = UDim2.new(0, 20, 0, 20)
	frame.BackgroundColor3 = COLORS.background
	frame.BorderSizePixel = 0
	frame.Parent = parent

	-- Rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	-- Padding
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 16)
	padding.PaddingBottom = UDim.new(0, 16)
	padding.PaddingLeft = UDim.new(0, 16)
	padding.PaddingRight = UDim.new(0, 16)
	padding.Parent = frame

	-- Layout
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 12)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = frame

	return frame
end

-- Create title label
local function createTitleLabel(parent: GuiObject): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = "TitleLabel"
	label.Size = UDim2.new(1, 0, 0, 24)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 18
	label.TextColor3 = COLORS.text
	label.Text = "Roblox Game Template"
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.LayoutOrder = 1
	label.Parent = parent
	return label
end

-- Create ping button
local function createPingButton(parent: GuiObject): TextButton
	local button = Instance.new("TextButton")
	button.Name = "PingButton"
	button.Size = UDim2.new(1, 0, 0, 40)
	button.BackgroundColor3 = COLORS.primary
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.TextSize = 16
	button.TextColor3 = COLORS.text
	button.Text = "Ping Server"
	button.LayoutOrder = 2
	button.AutoButtonColor = false
	button.Parent = parent

	-- Rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	-- Hover effects
	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	button.MouseEnter:Connect(function()
		TweenService:Create(button, tweenInfo, { BackgroundColor3 = COLORS.primaryHover }):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, tweenInfo, { BackgroundColor3 = COLORS.primary }):Play()
	end)

	-- Click handler
	button.MouseButton1Click:Connect(function()
		for _, callback in ipairs(pingClickedCallbacks) do
			task.spawn(callback)
		end
	end)

	return button
end

-- Create status label
local function createStatusLabel(parent: GuiObject): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = "StatusLabel"
	label.Size = UDim2.new(1, 0, 0, 36)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextColor3 = COLORS.textMuted
	label.Text = "Click the button to ping the server"
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextWrapped = true
	label.LayoutOrder = 3
	label.Parent = parent
	return label
end

-- Initialize UI
local function initialize()
	local screenGui = createScreenGui()
	local mainFrame = createMainFrame(screenGui)

	elements.screenGui = screenGui
	elements.titleLabel = createTitleLabel(mainFrame)
	elements.pingButton = createPingButton(mainFrame)
	elements.statusLabel = createStatusLabel(mainFrame)

	screenGui.Parent = PlayerGui
end

--[[
	Sets the status text displayed in the UI.

	@param text The status message to display
]]
function UI.setStatus(text: string)
	if elements.statusLabel then
		elements.statusLabel.Text = text
	end
end

--[[
	Registers a callback to be called when the ping button is clicked.

	@param callback Function to call on click
]]
function UI.onPingClicked(callback: () -> ())
	table.insert(pingClickedCallbacks, callback)
end

--[[
	Gets the ScreenGui instance.

	@return The ScreenGui or nil if not initialized
]]
function UI.getScreenGui(): ScreenGui?
	return elements.screenGui
end

-- Initialize on load
initialize()

return UI
