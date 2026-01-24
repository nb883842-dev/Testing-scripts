-- Minecraft-Style UI System (Mobile Friendly)
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MinecraftUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- State variables
local settingsOpen = false
local textureRemovalActive = false
local backgroundFPSActive = false
local terrainPixelationActive = false
local originalTextures = {}
local renderConnections = {}
local uiVisible = true

-- Blur effect
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = game.Lighting

-- Detect if mobile
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Helper function to create Minecraft-style button with dirt/stone texture
local function createMinecraftButton(name, text, position, size, parent)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Text = text
	button.Font = Enum.Font.GothamBold
	button.TextSize = isMobile and 18 or 22
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.BackgroundColor3 = Color3.fromRGB(130, 130, 130)
	button.BorderSizePixel = 0
	button.Position = position
	button.Size = size
	button.AutoButtonColor = false
	button.Parent = parent
	
	-- Add Minecraft-style beveled border effect
	local topBorder = Instance.new("Frame")
	topBorder.Name = "TopBorder"
	topBorder.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	topBorder.BorderSizePixel = 0
	topBorder.Size = UDim2.new(1, 0, 0, 3)
	topBorder.Position = UDim2.new(0, 0, 0, 0)
	topBorder.ZIndex = button.ZIndex + 1
	topBorder.Parent = button
	
	local leftBorder = Instance.new("Frame")
	leftBorder.Name = "LeftBorder"
	leftBorder.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	leftBorder.BorderSizePixel = 0
	leftBorder.Size = UDim2.new(0, 3, 1, 0)
	leftBorder.Position = UDim2.new(0, 0, 0, 0)
	leftBorder.ZIndex = button.ZIndex + 1
	leftBorder.Parent = button
	
	local bottomBorder = Instance.new("Frame")
	bottomBorder.Name = "BottomBorder"
	bottomBorder.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	bottomBorder.BorderSizePixel = 0
	bottomBorder.Size = UDim2.new(1, 0, 0, 3)
	bottomBorder.Position = UDim2.new(0, 0, 1, -3)
	bottomBorder.ZIndex = button.ZIndex + 1
	bottomBorder.Parent = button
	
	local rightBorder = Instance.new("Frame")
	rightBorder.Name = "RightBorder"
	rightBorder.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	rightBorder.BorderSizePixel = 0
	rightBorder.Size = UDim2.new(0, 3, 1, 0)
	rightBorder.Position = UDim2.new(1, -3, 0, 0)
	rightBorder.ZIndex = button.ZIndex + 1
	rightBorder.Parent = button
	
	-- Add pixelated texture overlay
	local textureGrid = Instance.new("Frame")
	textureGrid.Name = "TextureGrid"
	textureGrid.BackgroundTransparency = 0.85
	textureGrid.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	textureGrid.BorderSizePixel = 0
	textureGrid.Size = UDim2.new(1, 0, 1, 0)
	textureGrid.Parent = button
	
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 8, 0, 8)
	gridLayout.CellPadding = UDim2.new(0, 0, 0, 0)
	gridLayout.Parent = textureGrid
	
	-- Create pixelated pattern
	for i = 1, 100 do
		local pixel = Instance.new("Frame")
		pixel.BackgroundTransparency = math.random(70, 95) / 100
		pixel.BackgroundColor3 = Color3.fromRGB(
			math.random(100, 150),
			math.random(100, 150),
			math.random(100, 150)
		)
		pixel.BorderSizePixel = 0
		pixel.Parent = textureGrid
	end
	
	-- Text stroke for better readability
	local textStroke = Instance.new("UIStroke")
	textStroke.Color = Color3.fromRGB(50, 50, 50)
	textStroke.Thickness = 2
	textStroke.Parent = button
	
	-- Hover/Press effects
	button.MouseButton1Down:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		topBorder.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
		leftBorder.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
		bottomBorder.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
		rightBorder.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	end)
	
	button.MouseButton1Up:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(130, 130, 130)
		topBorder.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
		leftBorder.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
		bottomBorder.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
		rightBorder.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	end)
	
	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(145, 145, 145)
	end)
	
	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(130, 130, 130)
	end)
	
	return button
end

-- Create hamburger menu button (always visible)
local hamburgerButton = Instance.new("ImageButton")
hamburgerButton.Name = "HamburgerButton"
hamburgerButton.Image = "rbxasset://textures/ui/TopBar/inventoryOn.png"
hamburgerButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
hamburgerButton.BorderSizePixel = 0
hamburgerButton.Position = UDim2.new(0, 10, 0, 10)
hamburgerButton.Size = UDim2.new(0, isMobile and 50 or 45, 0, isMobile and 50 or 45)
hamburgerButton.ZIndex = 100
hamburgerButton.Parent = screenGui

local hamburgerCorner = Instance.new("UICorner")
hamburgerCorner.CornerRadius = UDim.new(0, 8)
hamburgerCorner.Parent = hamburgerButton

-- Main menu container (slides in from left)
local mainMenu = Instance.new("Frame")
mainMenu.Name = "MainMenu"
mainMenu.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
mainMenu.BorderSizePixel = 0
mainMenu.Position = UDim2.new(0, -300, 0.5, -200)
mainMenu.Size = UDim2.new(0, isMobile and 280 or 300, 0, isMobile and 350 or 400)
mainMenu.Parent = screenGui

-- Minecraft-style border for menu
local menuBorderTop = Instance.new("Frame")
menuBorderTop.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
menuBorderTop.BorderSizePixel = 0
menuBorderTop.Size = UDim2.new(1, 0, 0, 4)
menuBorderTop.Parent = mainMenu

local menuBorderBottom = Instance.new("Frame")
menuBorderBottom.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
menuBorderBottom.BorderSizePixel = 0
menuBorderBottom.Size = UDim2.new(1, 0, 0, 4)
menuBorderBottom.Position = UDim2.new(0, 0, 1, -4)
menuBorderBottom.Parent = mainMenu

local menuBorderLeft = Instance.new("Frame")
menuBorderLeft.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
menuBorderLeft.BorderSizePixel = 0
menuBorderLeft.Size = UDim2.new(0, 4, 1, 0)
menuBorderLeft.Parent = mainMenu

local menuBorderRight = Instance.new("Frame")
menuBorderRight.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
menuBorderRight.BorderSizePixel = 0
menuBorderRight.Size = UDim2.new(0, 4, 1, 0)
menuBorderRight.Position = UDim2.new(1, -4, 0, 0)
menuBorderRight.Parent = mainMenu

-- Menu title
local menuTitle = Instance.new("TextLabel")
menuTitle.Name = "Title"
menuTitle.Text = "MINECRAFT"
menuTitle.Font = Enum.Font.GothamBold
menuTitle.TextSize = isMobile and 24 or 28
menuTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
menuTitle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
menuTitle.BorderSizePixel = 0
menuTitle.Size = UDim2.new(1, -20, 0, 50)
menuTitle.Position = UDim2.new(0, 10, 0, 10)
menuTitle.Parent = mainMenu

local titleStroke = Instance.new("UIStroke")
titleStroke.Color = Color3.fromRGB(50, 50, 50)
titleStroke.Thickness = 2
titleStroke.Parent = menuTitle

-- Buttons container
local buttonsContainer = Instance.new("Frame")
buttonsContainer.Name = "ButtonsContainer"
buttonsContainer.BackgroundTransparency = 1
buttonsContainer.Position = UDim2.new(0, 10, 0, 70)
buttonsContainer.Size = UDim2.new(1, -20, 1, -80)
buttonsContainer.Parent = mainMenu

-- Settings Button
local settingsButton = createMinecraftButton(
	"SettingsButton",
	"⚙ Settings",
	UDim2.new(0, 0, 0, 10),
	UDim2.new(1, 0, 0, isMobile and 55 or 60),
	buttonsContainer
)

-- Hide UI Button
local hideButton = createMinecraftButton(
	"HideButton",
	"👁 Hide UI",
	UDim2.new(0, 0, 0, isMobile and 75 or 80),
	UDim2.new(1, 0, 0, isMobile and 55 or 60),
	buttonsContainer
)

-- Quit Button
local quitButton = createMinecraftButton(
	"QuitButton",
	"✕ Close Menu",
	UDim2.new(0, 0, 1, isMobile and -65 or -70),
	UDim2.new(1, 0, 0, isMobile and 55 or 60),
	buttonsContainer
)

-- Settings Panel
local settingsPanel = Instance.new("Frame")
settingsPanel.Name = "SettingsPanel"
settingsPanel.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
settingsPanel.BorderSizePixel = 0
settingsPanel.Position = UDim2.new(0.5, isMobile and -160 or -200, 0.5, isMobile and -220 or -250)
settingsPanel.Size = UDim2.new(0, isMobile and 320 or 400, 0, isMobile and 440 or 500)
settingsPanel.Visible = false
settingsPanel.ZIndex = 10
settingsPanel.Parent = screenGui

-- Settings panel borders
local sBorderTop = Instance.new("Frame")
sBorderTop.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
sBorderTop.BorderSizePixel = 0
sBorderTop.Size = UDim2.new(1, 0, 0, 4)
sBorderTop.ZIndex = 10
sBorderTop.Parent = settingsPanel

local sBorderBottom = Instance.new("Frame")
sBorderBottom.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
sBorderBottom.BorderSizePixel = 0
sBorderBottom.Size = UDim2.new(1, 0, 0, 4)
sBorderBottom.Position = UDim2.new(0, 0, 1, -4)
sBorderBottom.ZIndex = 10
sBorderBottom.Parent = settingsPanel

local sBorderLeft = Instance.new("Frame")
sBorderLeft.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
sBorderLeft.BorderSizePixel = 0
sBorderLeft.Size = UDim2.new(0, 4, 1, 0)
sBorderLeft.ZIndex = 10
sBorderLeft.Parent = settingsPanel

local sBorderRight = Instance.new("Frame")
sBorderRight.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
sBorderRight.BorderSizePixel = 0
sBorderRight.Size = UDim2.new(0, 4, 1, 0)
sBorderRight.Position = UDim2.new(1, -4, 0, 0)
sBorderRight.ZIndex = 10
sBorderRight.Parent = settingsPanel

-- Panel title
local panelTitle = Instance.new("TextLabel")
panelTitle.Name = "Title"
panelTitle.Text = "⚙ SETTINGS"
panelTitle.Font = Enum.Font.GothamBold
panelTitle.TextSize = isMobile and 20 or 24
panelTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
panelTitle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
panelTitle.BorderSizePixel = 0
panelTitle.Size = UDim2.new(1, -16, 0, isMobile and 45 or 50)
panelTitle.Position = UDim2.new(0, 8, 0, 8)
panelTitle.ZIndex = 11
panelTitle.Parent = settingsPanel

local pTitleStroke = Instance.new("UIStroke")
pTitleStroke.Color = Color3.fromRGB(50, 50, 50)
pTitleStroke.Thickness = 2
pTitleStroke.Parent = panelTitle

-- Close settings button
local closeSettingsBtn = createMinecraftButton(
	"CloseSettings",
	"✕",
	UDim2.new(1, isMobile and -50 or -55, 0, 8),
	UDim2.new(0, isMobile and 40 or 45, 0, isMobile and 40 or 45),
	settingsPanel
)
closeSettingsBtn.ZIndex = 12
closeSettingsBtn.TextSize = isMobile and 20 or 24

-- Scrolling frame for toggles
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
scrollFrame.BorderSizePixel = 0
scrollFrame.Position = UDim2.new(0, 8, 0, isMobile and 60 or 65)
scrollFrame.Size = UDim2.new(1, -16, 1, isMobile and -68 or -73)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, isMobile and 450 or 500)
scrollFrame.ScrollBarThickness = isMobile and 8 or 10
scrollFrame.ZIndex = 11
scrollFrame.Parent = settingsPanel

-- Tooltip frame
local tooltip = Instance.new("TextLabel")
tooltip.Name = "Tooltip"
tooltip.Text = ""
tooltip.Font = Enum.Font.Gotham
tooltip.TextSize = isMobile and 13 or 15
tooltip.TextColor3 = Color3.fromRGB(255, 255, 255)
tooltip.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
tooltip.BorderSizePixel = 3
tooltip.BorderColor3 = Color3.fromRGB(180, 180, 180)
tooltip.Size = UDim2.new(0, isMobile and 250 or 320, 0, isMobile and 70 or 80)
tooltip.Visible = false
tooltip.TextWrapped = true
tooltip.ZIndex = 50
tooltip.Parent = screenGui

-- Function to create toggle button
local function createToggle(name, displayText, yPosition, description)
	local container = Instance.new("Frame")
	container.Name = name .. "Container"
	container.BackgroundColor3 = Color3.fromRGB(95, 95, 95)
	container.BorderSizePixel = 0
	container.Position = UDim2.new(0, 8, 0, yPosition)
	container.Size = UDim2.new(1, -16, 0, isMobile and 100 or 110)
	container.ZIndex = 11
	container.Parent = scrollFrame
	
	-- Container borders
	local cBorderTop = Instance.new("Frame")
	cBorderTop.BackgroundColor3 = Color3.fromRGB(140, 140, 140)
	cBorderTop.BorderSizePixel = 0
	cBorderTop.Size = UDim2.new(1, 0, 0, 2)
	cBorderTop.ZIndex = 12
	cBorderTop.Parent = container
	
	local cBorderBottom = Instance.new("Frame")
	cBorderBottom.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	cBorderBottom.BorderSizePixel = 0
	cBorderBottom.Size = UDim2.new(1, 0, 0, 2)
	cBorderBottom.Position = UDim2.new(0, 0, 1, -2)
	cBorderBottom.ZIndex = 12
	cBorderBottom.Parent = container
	
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Text = displayText
	label.Font = Enum.Font.GothamBold
	label.TextSize = isMobile and 14 or 16
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -10, 0, 30)
	label.Position = UDim2.new(0, 5, 0, 5)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextWrapped = true
	label.ZIndex = 12
	label.Parent = container
	
	local labelStroke = Instance.new("UIStroke")
	labelStroke.Color = Color3.fromRGB(50, 50, 50)
	labelStroke.Thickness = 1.5
	labelStroke.Parent = label
	
	local toggleBtn = createMinecraftButton(
		name .. "Toggle",
		"OFF",
		UDim2.new(0.5, -50, 1, isMobile and -45 or -50),
		UDim2.new(0, 100, 0, isMobile and 35 or 40),
		container
	)
	toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
	toggleBtn.ZIndex = 12
	toggleBtn.TextSize = isMobile and 16 or 18
	
	-- Adjust borders for OFF state
	for _, child in pairs(toggleBtn:GetChildren()) do
		if child.Name == "TopBorder" or child.Name == "LeftBorder" then
			child.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
		elseif child.Name == "BottomBorder" or child.Name == "RightBorder" then
			child.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
		end
	end
	
	-- Info button
	local infoBtn = Instance.new("TextButton")
	infoBtn.Name = "InfoBtn"
	infoBtn.Text = "?"
	infoBtn.Font = Enum.Font.GothamBold
	infoBtn.TextSize = isMobile and 16 or 18
	infoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	infoBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
	infoBtn.BorderSizePixel = 0
	infoBtn.Size = UDim2.new(0, isMobile and 30 or 35, 0, isMobile and 30 or 35)
	infoBtn.Position = UDim2.new(1, isMobile and -38 or -43, 0, 5)
	infoBtn.ZIndex = 12
	infoBtn.Parent = container
	
	local infoCorner = Instance.new("UICorner")
	infoCorner.CornerRadius = UDim.new(1, 0)
	infoCorner.Parent = infoBtn
	
	-- Tooltip events
	local function showTooltip()
		tooltip.Text = description
		tooltip.Position = UDim2.new(0.5, -tooltip.Size.X.Offset / 2, 0.5, -tooltip.Size.Y.Offset / 2)
		tooltip.Visible = true
	end
	
	local function hideTooltip()
		tooltip.Visible = false
	end
	
	infoBtn.MouseButton1Click:Connect(showTooltip)
	
	if not isMobile then
		infoBtn.MouseEnter:Connect(showTooltip)
		infoBtn.MouseLeave:Connect(hideTooltip)
	end
	
	return toggleBtn, container
end

-- Create toggles
local textureToggle = createToggle(
	"TextureRemoval",
	"Texture Removal",
	10,
	"This toggle activates texture removal to improve performance by removing all textures from objects."
)

local fpsToggle = createToggle(
	"BackgroundFPS",
	"Background FPS Boost",
	isMobile and 120 or 130,
	"This toggle enables background FPS optimization by hiding objects behind other objects to reduce lag."
)

local pixelToggle = createToggle(
	"TerrainPixelation",
	"Distance Quality",
	isMobile and 230 or 250,
	"This toggle reduces quality of distant objects. Closer objects stay high quality, farther objects become lower quality for better FPS."
)

-- Blur toggle function
local function toggleBlur(enabled)
	local targetSize = enabled and 20 or 0
	TweenService:Create(blur, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = targetSize}):Play()
end

-- Hamburger button click (toggle menu)
hamburgerButton.MouseButton1Click:Connect(function()
	local isOpen = mainMenu.Position.X.Offset >= 0
	
	if isOpen then
		TweenService:Create(mainMenu, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Position = UDim2.new(0, -300, 0.5, -200)
		}):Play()
	else
		TweenService:Create(mainMenu, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Position = UDim2.new(0, 10, 0.5, -200)
		}):Play()
	end
end)

-- Settings button click
settingsButton.MouseButton1Click:Connect(function()
	settingsOpen = true
	settingsPanel.Visible = true
	toggleBlur(true)
end)

-- Close settings
closeSettingsBtn.MouseButton1Click:Connect(function()
	settingsOpen = false
	settingsPanel.Visible = false
	toggleBlur(false)
end)

-- Hide UI button
hideButton.MouseButton1Click:Connect(function()
	uiVisible = false
	mainMenu:TweenPosition(UDim2.new(0, -300, 0.5, -200), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
	hamburgerButton.Visible = false
	settingsPanel.Visible = false
	toggleBlur(false)
end)

-- Quit button (just closes menu)
quitButton.MouseButton1Click:Connect(function()
	TweenService:Create(mainMenu, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
		Position = UDim2.new(0, -300, 0.5, -200)
	}):Play()
end)

-- Double-tap screen to show UI again (mobile)
if isMobile then
	local lastTapTime = 0
	
	UserInputService.TouchTap:Connect(function()
		local currentTime = tick()
		if not uiVisible and (currentTime - lastTapTime) < 0.3 then
			uiVisible = true
			hamburgerButton.Visible = true
		end
		lastTapTime = currentTime
	end)
end

-- Keyboard shortcut to show UI (PC: H key)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.H and not uiVisible then
		uiVisible = true
		hamburgerButton.Visible = true
	end
end)

-- TEXTURE REMOVAL SYSTEM
local function toggleTextureRemoval(enabled)
	textureRemovalActive = enabled
	
	if enabled then
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") or obj:IsA("MeshPart") then
				if not originalTextures[obj] then
					originalTextures[obj] = {
						Texture = obj.TextureID or "",
						Material = obj.Material,
						Color = obj.Color
					}
				end
				obj.TextureID = ""
				obj.Material = Enum.Material.SmoothPlastic
			elseif obj:IsA("Decal") or obj:IsA("Texture") then
				if not originalTextures[obj] then
					originalTextures[obj] = {Texture = obj.Texture, Transparency = obj.Transparency}
				end
				obj.Transparency = 1
			end
		end
	else
		for obj, data in pairs(originalTextures) do
			if obj and obj.Parent then
				if obj:IsA("BasePart") or obj:IsA("MeshPart") then
					obj.TextureID = data.Texture
					obj.Material = data.Material
					obj.Color = data.Color
				elseif obj:IsA("Decal") or obj:IsA("Texture") then
					obj.Transparency = data.Transparency
				end
			end
		end
		originalTextures = {}
	end
end

-- BACKGROUND FPS OPTIMIZATION
local function toggleBackgroundFPS(enabled)
	backgroundFPSActive = enabled
	
	if renderConnections.fpsOptimization then
		renderConnections.fpsOptimization:Disconnect()
		renderConnections.fpsOptimization = nil
	end
	
	if enabled then
		local camera = workspace.CurrentCamera
		renderConnections.fpsOptimization = RunService.Heartbeat:Connect(function()
			if not camera then return end
			
			local camPos = camera.CFrame.Position
			local camLook = camera.CFrame.LookVector
			
			for _, obj in pairs(workspace:GetDescendants()) do
				if obj:IsA("BasePart") and obj.Parent and not obj:FindFirstAncestorOfClass("Camera") then
					local objPos = obj.Position
					local direction = (objPos - camPos).Unit
					local dotProduct = direction:Dot(camLook)
					
					local distance = (objPos - camPos).Magnitude
					if dotProduct < -0.1 or distance > 500 then
						obj.LocalTransparencyModifier = 1
					else
						obj.LocalTransparencyModifier = 0
					end
				end
			end
		end)
	else
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") then
				obj.LocalTransparencyModifier = 0
			end
		end
	end
end

-- TERRAIN PIXELATION SYSTEM
local function toggleTerrainPixelation(enabled)
	terrainPixelationActive = enabled
	
	if renderConnections.pixelation then
		renderConnections.pixelation:Disconnect()
		renderConnections.pixelation = nil
	end
	
	if enabled then
		local camera = workspace.CurrentCamera
		local updateInterval = 0
		
		renderConnections.pixelation = RunService.Heartbeat:Connect(function(deltaTime)
			updateInterval = updateInterval + deltaTime
			if updateInterval < 0.1 then return end
			updateInterval = 0
			
			if not camera then return end
			local camPos = camera.CFrame.Position
			
			for _, obj in pairs(workspace:GetDescendants()) do
				if obj:IsA("BasePart") and obj.Parent then
					local distance = (obj.Position - camPos).Magnitude
					
					if distance < 50 then
						obj.CastShadow = true
					elseif distance < 150 then
						if obj.Material ~= Enum.Material.SmoothPlastic then
							obj.Material = Enum.Material.SmoothPlastic
						end
					else
						if obj.Material ~= Enum.Material.SmoothPlastic then
							obj.Material = Enum.Material.SmoothPlastic
						end
						obj.CastShadow = false
					end
				end
			end
		end)
	else
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") then
				obj.CastShadow = true
			end
		end
	end
end

-- Toggle button handlers
textureToggle.MouseButton1Click:Connect(function()
	textureRemovalActive = not textureRemovalActive
	textureToggle.Text = textureRemovalActive and "ON" or "OFF"
	
	if textureRemovalActive then
		textureToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
		for _, child in pairs(textureToggle:GetChildren()) do
			if child.Name == "TopBorder" or child.Name == "LeftBorder" then
				child.BackgroundColor3 = Color3.fromRGB(70, 180, 70)
			elseif child.Name == "BottomBorder" or child.Name == "RightBorder" then
				child.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
			end
		end
	else
		textureToggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
		for _, child in pairs(textureToggle:GetChildren()) do
			if child.Name == "TopBorder" or child.Name == "LeftBorder" then
				child.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
			elseif child.Name == "BottomBorder" or child.Name == "RightBorder" then
				child.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
			end
		end
	end
	
	toggleTextureRemoval(textureRemovalActive)
end)

fpsToggle.MouseButton1Click:Connect(function()
	backgroundFPSActive = not backgroundFPSActive
	fpsToggle.Text = backgroundFPSActive and "ON" or "OFF"
	
	if backgroundFPSActive then
		fpsToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
		for _, child in pairs(fpsToggle:GetChildren()) do
			if child.Name == "TopBorder" or child.Name == "LeftBorder" then
				child.BackgroundColor3 = Color3.fromRGB(70, 180, 70)
			elseif child.Name == "BottomBorder" or child.Name == "RightBorder" then
				child.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
			end
		end
	else
		fpsToggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
		for _, child in pairs(fpsToggle:GetChildren()) do
			if child.Name == "TopBorder" or child.Name == "LeftBorder" then
				child.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
			elseif child.Name == "BottomBorder" or child.Name == "RightBorder" then
				child.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
			end
		end
	end
	
	toggleBackgroundFPS(backgroundFPSActive)
end)

pixelToggle.MouseButton1Click:Connect(function()
	terrainPixelationActive = not terrainPixelationActive
	pixelToggle.Text = terrainPixelationActive and "ON" or "OFF"
	
	if terrainPixelationActive then
		pixelToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
		for _, child in pairs(pixelToggle:GetChildren()) do
			if child.Name == "TopBorder" or child.Name == "LeftBorder" then
				child.BackgroundColor3 = Color3.fromRGB(70, 180, 70)
			elseif child.Name == "BottomBorder" or child.Name == "RightBorder" then
				child.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
			end
		end
	else
		pixelToggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
		for _, child in pairs(pixelToggle:GetChildren()) do
			if child.Name == "TopBorder" or child.Name == "LeftBorder" then
				child.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
			elseif child.Name == "BottomBorder" or child.Name == "RightBorder" then
				child.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
			end
		end
	end
	
	toggleTerrainPixelation(terrainPixelationActive)
end)

-- Close tooltip when clicking outside
screenGui.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if tooltip.Visible then
			tooltip.Visible = false
		end
	end
end)

-- Cleanup on player leaving
Players.PlayerRemoving:Connect(function(leavingPlayer)
	if leavingPlayer == player then
		for _, connection in pairs(renderConnections) do
			if connection then connection:Disconnect() end
		end
	end
end)