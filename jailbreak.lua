upd = "https://raw.githubusercontent.com/iiivyne/mylib/refs/heads/main/lib.lua"
local lib = loadstring(game:HttpGet(upd))()
local int = lib:CreateInterface("jailbreak","script undergoing development","https://discord.gg/ZNTHTWx7KE","bottom right","default")

local plr = int:CreateTab("player","modify your localplayer","player")
local vis = int:CreateTab("visual","modify your sights","visuals")
local misc = int:CreateTab("misc","miscellaneous","misc")
local Players = game:GetService("Players")

-- stubs
typeof = typeof or type
getgc = getgc or function() return {} end
hookfunction = hookfunction or function() end
debug = debug or { info = function() return "" end }
LPH_NO_VIRTUALIZE = LPH_NO_VIRTUALIZE or function(f) return f end

LPH_NO_VIRTUALIZE(function()
    for _, v in pairs(getgc()) do
        if typeof(v) == "function" then
            local DebugInfo = debug.info(v, "n")

            if DebugInfo:match("CheatCheck") then
                print("Hooked CheatCheck")
                hookfunction(v, function() end)
            end

            if DebugInfo:match("CheatCheck0") then
                print("Hooked CheatCheck0")
                hookfunction(v, function() end)
            end
        end
    end
end)()

print("script finished")

local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")


-- === Main Configurations === 

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- === Player Sliders ===

-- JumpPower Slider
plr:CreateSlider("jumppower", 65, 50, function(value)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = value
    end
end)

plr:CreateButton("aimlock (T)", function()

	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")
	local Camera = workspace.CurrentCamera

	local LocalPlayer = Players.LocalPlayer
	local Mouse = LocalPlayer:GetMouse()

	-- Settings
	local ENABLED = false
	local KEY_TO_TOGGLE = Enum.KeyCode.T -- Changed to E key
	local MAX_DISTANCE = 1000
	local FOV = 300 -- Field of View for target selection
	local lockedPlayer = nil -- Variable to store the locked player

	-- Function to check if a player is on a different team
	local function isPlayerOnDifferentTeam(player)
		return player.Team ~= LocalPlayer.Team
	end

	-- Function to check if a player is visible
	local function isPlayerVisible(player)
		local character = player.Character
		if not character then return false end
		
		local head = character:FindFirstChild("Head")
		if not head then return false end
		
		local ray = Ray.new(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * MAX_DISTANCE)
		local hitPart, hitPosition = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
		
		return hitPart and hitPart:IsDescendantOf(character)
	end

	-- Function to get the nearest player to the crosshair
	local function getNearestPlayerToCrosshair()
		local nearestPlayer = nil
		local shortestDistance = FOV
		
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
				-- Check if player is on different team
				if isPlayerOnDifferentTeam(player) then
					local screenPoint = Camera:WorldToScreenPoint(player.Character.Head.Position)
					local screenDistance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
					
					if screenDistance < shortestDistance then
						shortestDistance = screenDistance
						nearestPlayer = player
					end
				end
			end
		end
		
		return nearestPlayer
	end

	-- Toggle function
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == KEY_TO_TOGGLE then
			ENABLED = not ENABLED
			
			if ENABLED then
				-- Find a target when enabling
				lockedPlayer = getNearestPlayerToCrosshair()
			else
				-- Clear target when disabling
				lockedPlayer = nil
			end
		end
	end)

	-- Main aimlock loop
	RunService.RenderStepped:Connect(function()
		if ENABLED and lockedPlayer then
			-- Check if locked player is still valid
			if lockedPlayer.Character and 
			lockedPlayer.Character:FindFirstChild("Head") and 
			lockedPlayer.Character:FindFirstChild("Humanoid") and 
			lockedPlayer.Character.Humanoid.Health > 0 and
			isPlayerOnDifferentTeam(lockedPlayer) then
				
				-- Instant lock to head (0 smoothness)
				Camera.CFrame = CFrame.new(Camera.CFrame.Position, lockedPlayer.Character.Head.Position)
			else
				-- If target is no longer valid, find a new one
				lockedPlayer = getNearestPlayerToCrosshair()
			end
		end
	end)

	-- Notification
	local function createNotification()
		local screenGui = Instance.new("ScreenGui")
		screenGui.Parent = game.CoreGui
		
		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(0, 200, 0, 50)
		textLabel.Position = UDim2.new(0.5, -100, 0, 30)
		textLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.Text = "Aimlock Loaded\nToggle with E key"
		textLabel.Parent = screenGui
		
		game:GetService("Debris"):AddItem(screenGui, 3)
	end

	createNotification()

	print("Aimlock script loaded. Press E to toggle.")

    -- Notification
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = game.CoreGui

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0, 250, 0, 50)
    textLabel.Position = UDim2.new(0.5, -125, 0, 30)
    textLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Text = "Aimlock Loaded\nToggle with T (nearest to cursor)"
    textLabel.Parent = screenGui

    game:GetService("Debris"):AddItem(screenGui, 3)
    print("Cursor-nearest Aimlock loaded. Press T to toggle.")
end)




plr:CreateButton("fly('V' to fly, 'G' to change speeds)",function()

	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")

	-------------------------------------------------
	-- PLAYER REFERENCES
	-------------------------------------------------
	local player = Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")

	-------------------------------------------------
	-- FLY CONSTANTS & STATE
	-------------------------------------------------
	local FAST_FLY_SPEED = 250
	local NORMAL_FLY_SPEED = 75

	local desiredFlySpeed = FAST_FLY_SPEED
	local flySpeed = FAST_FLY_SPEED
	local flying = false

	local bodyVelocity, bodyGyro
	local updateConnection

	local keysPressed = {
		W = false,
		A = false,
		S = false,
		D = false,
		Space = false,
		LeftControl = false
	}

	-------------------------------------------------
	-- FLY FUNCTIONS
	-------------------------------------------------
	local function startFlying()
		if flying then return end
		flying = true
		flySpeed = desiredFlySpeed

		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
		bodyVelocity.Velocity = Vector3.zero
		bodyVelocity.Parent = hrp

		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
		bodyGyro.CFrame = hrp.CFrame
		bodyGyro.Parent = hrp

		updateConnection = RunService.RenderStepped:Connect(function()
			if not flying then return end

			local cam = workspace.CurrentCamera
			local move = Vector3.zero

			if keysPressed.W then move += cam.CFrame.LookVector end
			if keysPressed.S then move -= cam.CFrame.LookVector end
			if keysPressed.A then move -= cam.CFrame.RightVector end
			if keysPressed.D then move += cam.CFrame.RightVector end
			if keysPressed.Space then move += Vector3.new(0, 1, 0) end
			if keysPressed.LeftControl then move -= Vector3.new(0, 1, 0) end

			if move.Magnitude > 0 then
				move = move.Unit * flySpeed
			end

			bodyVelocity.Velocity = move
			bodyGyro.CFrame = cam.CFrame
		end)
	end

	local function stopFlying()
		flying = false

		if updateConnection then
			updateConnection:Disconnect()
			updateConnection = nil
		end
		if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
		if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
	end

	-------------------------------------------------
	-- INPUT HANDLING
	-------------------------------------------------
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end

		-- F = toggle fly
		if input.KeyCode == Enum.KeyCode.V then
			if flying then
				stopFlying()
			else
				startFlying()
			end
		end

		-- G = toggle speed (only while flying)
		if input.KeyCode == Enum.KeyCode.G then
			if not flying then return end

			if desiredFlySpeed == FAST_FLY_SPEED then
				desiredFlySpeed = NORMAL_FLY_SPEED
			else
				desiredFlySpeed = FAST_FLY_SPEED
			end

			flySpeed = desiredFlySpeed
		end

		if keysPressed[input.KeyCode.Name] ~= nil then
			keysPressed[input.KeyCode.Name] = true
		end
	end)

	UserInputService.InputEnded:Connect(function(input, gp)
		if gp then return end
		if keysPressed[input.KeyCode.Name] ~= nil then
			keysPressed[input.KeyCode.Name] = false
		end
	end)

	-------------------------------------------------
	-- RESPAWN / FULL RESET
	-------------------------------------------------
	player.CharacterAdded:Connect(function(char)
		-- STOP FLYING IMMEDIATELY
		stopFlying()

		-- RESET SPEED STATE
		desiredFlySpeed = FAST_FLY_SPEED
		flySpeed = FAST_FLY_SPEED

		-- RESET INPUTS
		for k in pairs(keysPressed) do
			keysPressed[k] = false
		end

		-- DESTROY LEFTOVER PHYSICS (safety)
		if updateConnection then
			updateConnection:Disconnect()
			updateConnection = nil
		end
		if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
		if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end

		-- REBIND CHARACTER
		character = char
		hrp = char:WaitForChild("HumanoidRootPart")
	end)

end)

-- WalkSpeed Slider with Persistent Behavior
plr:CreateSlider("walkspeed", 35, 16, function(value)
    _G.HackedWalkSpeed = value

    local function applyWalkSpeed(humanoid)
        if humanoid then
            humanoid.WalkSpeed = _G.HackedWalkSpeed
            humanoid.Changed:Connect(function(property)
                if property == "WalkSpeed" and humanoid.WalkSpeed ~= _G.HackedWalkSpeed then
                    humanoid.WalkSpeed = _G.HackedWalkSpeed
                end
            end)
        end
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        applyWalkSpeed(LocalPlayer.Character.Humanoid)
    end

    LocalPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid")
        applyWalkSpeed(char:FindFirstChild("Humanoid"))
    end)
end)

plr:CreateCheckbox("walkspeed toggle (35)",function(toggle)
    if toggle == true then 
    _G.HackedWalkSpeed = 35
        else
    _G.HackedWalkSpeed = 16
    end

    local function applyWalkSpeed(humanoid)
        if humanoid then
            humanoid.WalkSpeed = _G.HackedWalkSpeed
            humanoid.Changed:Connect(function(property)
                if property == "WalkSpeed" and humanoid.WalkSpeed ~= _G.HackedWalkSpeed then
                    humanoid.WalkSpeed = _G.HackedWalkSpeed
                end
            end)
        end
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        applyWalkSpeed(LocalPlayer.Character.Humanoid)
    end

    LocalPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid")
        applyWalkSpeed(char:FindFirstChild("Humanoid"))
    end)
end)

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

--// CONFIG
local espTransparency = 0.4
local teamCheck = true

--// CUSTOM FONT
local customFont = Font.new("rbxassetid://16658246179", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

--// STATE
local BillboardESPs = {}
local ChamsESPs = {}
local ESPConnections = {}

local ESPEnabled = false
local ChamsEnabled = false

--// HELPERS
local function round(num, decimals)
	return tonumber(string.format("%." .. (decimals or 0) .. "f", num))
end

local function getRoot(char)
	return char and char:FindFirstChild("HumanoidRootPart")
end

--// BILLBOARD ESP
local function createBillboardESP(plr)
	if BillboardESPs[plr] or plr == LocalPlayer then return end
	if not plr.Character or not plr.Character:FindFirstChild("Head") then return end

	local gui = Instance.new("BillboardGui")
	gui.Name = "Billboard_ESP"
	gui.Adornee = plr.Character.Head
	gui.Parent = plr.Character.Head
	gui.Size = UDim2.new(0, 100, 0, 40)
	gui.AlwaysOnTop = true
	gui.StudsOffset = Vector3.new(0, 2, 0)

	local label = Instance.new("TextLabel", gui)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.5
	label.TextScaled = true
	label.FontFace = customFont

	local conn
	conn = RunService.RenderStepped:Connect(function()
		if not plr.Character or not plr.Character:FindFirstChild("Humanoid") then
			gui:Destroy()
			if conn then conn:Disconnect() end
			BillboardESPs[plr] = nil
			ESPConnections[plr] = nil
			return
		end

		local hp = math.floor(plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth * 100)
		label.Text = plr.Name .. " | " .. hp .. "%"
	end)

	BillboardESPs[plr] = gui
	ESPConnections[plr] = conn
end

--// CHAMS ESP (BoxHandleAdornment)
local function createChamsESP(plr)
	if ChamsESPs[plr] or plr == LocalPlayer then return end
	if not plr.Character or not getRoot(plr.Character) then return end

	local folder = Instance.new("Folder")
	folder.Name = "Chams_ESP"
	folder.Parent = CoreGui
	ChamsESPs[plr] = folder

	for _, part in pairs(plr.Character:GetChildren()) do
		if part:IsA("BasePart") then
			local box = Instance.new("BoxHandleAdornment")
			box.Name = "Cham_" .. plr.Name
			box.Adornee = part
			box.AlwaysOnTop = true
			box.ZIndex = 10
			box.Size = part.Size
			box.Transparency = espTransparency
			box.Color = BrickColor.new(
				teamCheck and (plr.TeamColor == LocalPlayer.TeamColor and "Bright green" or "Bright red") or tostring(plr.TeamColor)
			)
			box.Parent = folder
		end
	end
end

--// CLEANUP FUNCTIONS
local function cleanupBillboardESP()
	for _, gui in pairs(BillboardESPs) do
		if gui then gui:Destroy() end
	end
	for _, conn in pairs(ESPConnections) do
		if conn then conn:Disconnect() end
	end
	BillboardESPs = {}
	ESPConnections = {}
end

local function cleanupChamsESP()
	for _, folder in pairs(ChamsESPs) do
		if folder then folder:Destroy() end
	end
	ChamsESPs = {}
end

--// INITIALIZATION HANDLER
local function handlePlayerESP(plr)
	if ESPEnabled then createBillboardESP(plr) end
	if ChamsEnabled then createChamsESP(plr) end

	plr.CharacterAdded:Connect(function()
		task.wait(1)
		if ESPEnabled then createBillboardESP(plr) end
		if ChamsEnabled then createChamsESP(plr) end
	end)
end

--// GUI TOGGLES (INTEGRATE INTO YOUR UI)
vis:CreateCheckbox("ESP", function(state)
	ESPEnabled = state
	if not state then
		cleanupBillboardESP()
	else
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				createBillboardESP(plr)
			end
		end
	end
end)

vis:CreateCheckbox("Chams", function(state)
	ChamsEnabled = state
	if not state then
		cleanupChamsESP()
	else
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				createChamsESP(plr)
			end
		end
	end
end)

--// INIT ON CURRENT PLAYERS
for _, plr in pairs(Players:GetPlayers()) do
	if plr ~= LocalPlayer then
		handlePlayerESP(plr)
	end
end

Players.PlayerAdded:Connect(function(plr)
	handlePlayerESP(plr)
end)

--// FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 1
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.ZIndex = 2

local FOVRadius = 100

RunService.RenderStepped:Connect(function()
	if FOVCircle.Visible then
		FOVCircle.Radius = FOVRadius
		FOVCircle.Position = UserInputService:GetMouseLocation()
	end
end)

vis:CreateCheckbox("FOV Circle", function(state)
	FOVCircle.Visible = state
end)

-- extra scripts

misc:CreateButton("infinite yield",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

-- extra scripts