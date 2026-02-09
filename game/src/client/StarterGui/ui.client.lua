--!strict
--[[
	ui.client.lua - UI System

	Creates and manages the Starburst Clicker user interface.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Types = require(Shared:WaitForChild("Types"))

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "LocalPlayer not available")

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("GameUI") then
	return require(PlayerGui:FindFirstChild("GameUI") :: any)
end

local COLORS = {
	background = Color3.fromRGB(30, 30, 40),
	backgroundHover = Color3.fromRGB(40, 40, 55),
	primary = Color3.fromRGB(66, 135, 245),
	primaryHover = Color3.fromRGB(86, 155, 255),
	accent = Color3.fromRGB(255, 195, 64),
	accentHover = Color3.fromRGB(255, 210, 95),
	text = Color3.fromRGB(255, 255, 255),
	textMuted = Color3.fromRGB(180, 180, 190),
}

local UI = {}

local elements: {
	screenGui: ScreenGui?,
	titleLabel: TextLabel?,
	scoreLabel: TextLabel?,
	timerLabel: TextLabel?,
	startButton: TextButton?,
	collectButton: TextButton?,
	statusLabel: TextLabel?,
} = {}

local startClickedCallbacks: { () -> () } = {}
local collectClickedCallbacks: { () -> () } = {}

local function createScreenGui(): ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GameUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = false
	return screenGui
end

local function createMainFrame(parent: GuiObject): Frame
	local frame = Instance.new("Frame")
	frame.Name = "MainFrame"
	frame.Size = UDim2.new(0, 320, 0, 220)
	frame.Position = UDim2.new(0, 20, 0, 20)
	frame.BackgroundColor3 = COLORS.background
	frame.BorderSizePixel = 0
	frame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 16)
	padding.PaddingBottom = UDim.new(0, 16)
	padding.PaddingLeft = UDim.new(0, 16)
	padding.PaddingRight = UDim.new(0, 16)
	padding.Parent = frame

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 10)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = frame

	return frame
end

local function createTitleLabel(parent: GuiObject): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = "TitleLabel"
	label.Size = UDim2.new(1, 0, 0, 24)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 18
	label.TextColor3 = COLORS.text
	label.Text = "Starburst Clicker"
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.LayoutOrder = 1
	label.Parent = parent
	return label
end

local function createStatLabel(parent: GuiObject, name: string, text: string, order: number): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = UDim2.new(1, 0, 0, 20)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 14
	label.TextColor3 = COLORS.textMuted
	label.Text = text
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.LayoutOrder = order
	label.Parent = parent
	return label
end

local function createStartButton(parent: GuiObject): TextButton
	local button = Instance.new("TextButton")
	button.Name = "StartButton"
	button.Size = UDim2.new(1, 0, 0, 36)
	button.BackgroundColor3 = COLORS.primary
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.TextSize = 16
	button.TextColor3 = COLORS.text
	button.Text = "Start Round"
	button.LayoutOrder = 4
	button.AutoButtonColor = false
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	button.MouseEnter:Connect(function()
		TweenService:Create(button, tweenInfo, { BackgroundColor3 = COLORS.primaryHover }):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, tweenInfo, { BackgroundColor3 = COLORS.primary }):Play()
	end)

	button.MouseButton1Click:Connect(function()
		for _, callback in ipairs(startClickedCallbacks) do
			task.spawn(callback)
		end
	end)

	return button
end

local function createCollectButton(parent: GuiObject): TextButton
	local button = Instance.new("TextButton")
	button.Name = "CollectButton"
	button.Size = UDim2.new(1, 0, 0, 44)
	button.BackgroundColor3 = COLORS.accent
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.TextSize = 18
	button.TextColor3 = COLORS.background
	button.Text = "Collect Star"
	button.LayoutOrder = 5
	button.AutoButtonColor = false
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = button

	local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	button.MouseEnter:Connect(function()
		TweenService:Create(button, tweenInfo, { BackgroundColor3 = COLORS.accentHover }):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, tweenInfo, { BackgroundColor3 = COLORS.accent }):Play()
	end)

	button.MouseButton1Click:Connect(function()
		for _, callback in ipairs(collectClickedCallbacks) do
			task.spawn(callback)
		end
	end)

	return button
end

local function createStatusLabel(parent: GuiObject): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = "StatusLabel"
	label.Size = UDim2.new(1, 0, 0, 32)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextColor3 = COLORS.textMuted
	label.Text = "Tap Start to begin."
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextWrapped = true
	label.LayoutOrder = 6
	label.Parent = parent
	return label
end

local function initialize()
	local screenGui = createScreenGui()
	local mainFrame = createMainFrame(screenGui)

	elements.screenGui = screenGui
	elements.titleLabel = createTitleLabel(mainFrame)
	elements.scoreLabel = createStatLabel(mainFrame, "ScoreLabel", "Score: 0", 2)
	elements.timerLabel = createStatLabel(mainFrame, "TimerLabel", "Time Left: 0s", 3)
	elements.startButton = createStartButton(mainFrame)
	elements.collectButton = createCollectButton(mainFrame)
	elements.statusLabel = createStatusLabel(mainFrame)

	screenGui.Parent = PlayerGui
end

function UI.setStatus(text: string)
	if elements.statusLabel then
		elements.statusLabel.Text = text
	end
end

function UI.setScore(score: number)
	if elements.scoreLabel then
		elements.scoreLabel.Text = `Score: {score}`
	end
end

function UI.setTimer(timeLeft: number)
	if elements.timerLabel then
		elements.timerLabel.Text = `Time Left: {timeLeft}s`
	end
end

function UI.setState(state: Types.GameState)
	if elements.startButton then
		local isPlaying = state == Types.GameState.Playing
		elements.startButton.Active = not isPlaying
		elements.startButton.AutoButtonColor = not isPlaying
		elements.startButton.TextTransparency = isPlaying and 0.4 or 0
	end

	if elements.collectButton then
		local isPlaying = state == Types.GameState.Playing
		elements.collectButton.Active = isPlaying
		elements.collectButton.AutoButtonColor = isPlaying
		elements.collectButton.TextTransparency = isPlaying and 0 or 0.4
	end
end

function UI.onStartClicked(callback: () -> ())
	table.insert(startClickedCallbacks, callback)
end

function UI.onCollectClicked(callback: () -> ())
	table.insert(collectClickedCallbacks, callback)
end

function UI.getScreenGui(): ScreenGui?
	return elements.screenGui
end

initialize()

return UI
