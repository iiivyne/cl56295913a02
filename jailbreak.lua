--run this one 
upd = "https://raw.githubusercontent.com/iiivyne/mylib/refs/heads/main/lib.lua"
local lib = loadstring(game:HttpGet(upd))()
local int = lib:CreateInterface("jailbreak","script undergoing development","https://discord.gg/ZNTHTWx7KE","bottom right","default")

local plr = int:CreateTab("player","modify your localplayer","player")
local spawn = int:CreateTab("spawn","spawn mod","info")
local aimmod = int:CreateTab("aim","break the game with specific aimlocks","op")
local srv = int:CreateTab("server", "server hop to other games","npc")
local vis = int:CreateTab("visual","modify your sights","visuals")
local misc = int:CreateTab("misc","miscellaneous","misc")
local Players = game:GetService("Players")

--

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local PlaceId = 606849621 -- your game place id

-- Helper function to get public server list
local function getServers(cursor)
    local url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
    if cursor then
        url = url .. "&cursor=" .. cursor
    end
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        return HttpService:JSONDecode(result)
    else
        warn("Failed to fetch servers")
        return nil
    end
end

-- ======================
-- BIG SERVER BUTTON
-- ======================
srv:CreateButton("serverhop (big)", function()
    local data = getServers()
    if not data then return end

    local servers = {}
    for _, s in pairs(data.data) do
        if s.playing > 8 then
            table.insert(servers, s.id)
        end
    end

    if #servers > 0 then
        local randomServer = servers[math.random(1, #servers)]
        print("Teleporting to big server:", randomServer)
        TeleportService:TeleportToPlaceInstance(PlaceId, randomServer, Players.LocalPlayer)
    else
        print("No big servers found!")
    end
end)

-- ======================
-- SMALL SERVER BUTTON
-- ======================
srv:CreateButton("serverhop (small)", function()
    local data = getServers()
    if not data then return end

    local servers = {}
    for _, s in pairs(data.data) do
        if s.playing < 4 then
            table.insert(servers, s.id)
        end
    end

    if #servers > 0 then
        local randomServer = servers[math.random(1, #servers)]
        print("Teleporting to small server:", randomServer)
        TeleportService:TeleportToPlaceInstance(PlaceId, randomServer, Players.LocalPlayer)
    else
        print("No small servers found!")
    end
end)


--


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
--plr:CreateSlider("jumppower", 65, 50, function(value)
 --   local char = LocalPlayer.Character
 --   if char and char:FindFirstChild("Humanoid") then
  --      char.Humanoid.JumpPower = value
 --   end
--end)

aimmod:CreateCheckbox("hover over CEO", function(enabled)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HumRoot = Character:WaitForChild("HumanoidRootPart")

    local conn
    local speed = 10 -- studs per second, adjust for smoothness

    conn = RunService.RenderStepped:Connect(function(deltaTime)
        if not enabled then
            if conn then
                conn:Disconnect()
            end
            return
        end

        local bossHead = workspace:FindFirstChild("MansionRobbery") 
            and workspace.MansionRobbery:FindFirstChild("ActiveBoss") 
            and workspace.MansionRobbery.ActiveBoss:FindFirstChild("Head")
        
        if bossHead then
            local targetPos = bossHead.Position + Vector3.new(0, 5, 0) -- hover 5 studs above
            -- Smoothly interpolate position
            local newPos = HumRoot.Position:Lerp(targetPos, math.clamp(speed * deltaTime, 0, 1))
            HumRoot.CFrame = CFrame.new(newPos)
        end
    end)
end)

spawn:CreateButton("spawn camaro",function()
	local args = {
    "Chassis",
    "Camaro"
	}
	game:GetService("ReplicatedStorage"):WaitForChild("GarageSpawnVehicle"):FireServer(unpack(args))
end)





aimmod:CreateButton("aimlock (T)", function()

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

plr:CreateCheckbox("walkspeed toggle (100)",function(toggle)
    if toggle == true then 
    _G.HackedWalkSpeed = 100
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

plr:CreateButton("fly ('V' to fly, 'B' to change speeds)", function()
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")

    local fastfly = 20
    local normalfly = 7.5
    local currentFlySpeed = fastfly
    local fast = true

    local FLYING = false
    local CONTROL = {F=0,B=0,L=0,R=0}
    local lCONTROL = {F=0,B=0,L=0,R=0}
    local SPEED = 0

    local flyKeyDown, flyKeyUp
    local BODY_V, BODY_GYRO

    -- Get root safely
    local function getRoot(char)
        return char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart")
    end

    local function cleanup()
        FLYING = false
        if flyKeyDown then flyKeyDown:Disconnect() flyKeyDown = nil end
        if flyKeyUp then flyKeyUp:Disconnect() flyKeyUp = nil end
        if BODY_V then BODY_V:Destroy() BODY_V = nil end
        if BODY_GYRO then BODY_GYRO:Destroy() BODY_GYRO = nil end
        local char = Players.LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.PlatformStand = false end
        end
        pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
    end

    local function startFly()
        local plr = Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")

        -- Prevent multiple fly loops
        if FLYING then return end
        FLYING = true

        local T = getRoot(char)
        CONTROL = {F=0,B=0,L=0,R=0}
        lCONTROL = {F=0,B=0,L=0,R=0}
        SPEED = 0

        -- Create Body objects
        BODY_GYRO = Instance.new("BodyGyro")
        BODY_GYRO.P = 9e4
        BODY_GYRO.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        BODY_GYRO.CFrame = T.CFrame
        BODY_GYRO.Parent = T

        BODY_V = Instance.new("BodyVelocity")
        BODY_V.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        BODY_V.Velocity = Vector3.new(0,0,0)
        BODY_V.Parent = T

        humanoid.PlatformStand = true -- disable normal physics while flying

        -- Input connections
        flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == Enum.KeyCode.W then CONTROL.F = currentFlySpeed
            elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = -currentFlySpeed
            elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = -currentFlySpeed
            elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = currentFlySpeed
            end
        end)

        flyKeyUp = UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 0
            elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = 0
            elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = 0
            elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = 0
            end
        end)

        -- Fly loop
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not FLYING or not T or not T.Parent then
                connection:Disconnect()
                cleanup()
                return
            end

            local camera = workspace.CurrentCamera
            if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 then
                SPEED = currentFlySpeed
            else
                SPEED = 0
            end

            if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 then
                BODY_V.Velocity = ((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) +
                    ((camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, 0, 0).p) - camera.CFrame.p)) * SPEED
                lCONTROL = {F=CONTROL.F, B=CONTROL.B, L=CONTROL.L, R=CONTROL.R}
            elseif SPEED ~= 0 then
                BODY_V.Velocity = ((camera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) +
                    ((camera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R,0,0).p) - camera.CFrame.p)) * SPEED
            else
                BODY_V.Velocity = Vector3.new(0,0,0)
            end

            BODY_GYRO.CFrame = camera.CFrame
        end)
    end

    -- Toggle fly key
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.V then
            if FLYING then
                cleanup()
            else
                startFly()
            end
        elseif input.KeyCode == Enum.KeyCode.B then
            fast = not fast
            currentFlySpeed = fast and fastfly or normalfly
        end
    end)

    -- Cleanup on death / respawn
    Players.LocalPlayer.CharacterAdded:Connect(function()
        cleanup()
    end)
end)


-- WalkSpeed Slider with Persistent Behavior
plr:CreateSlider("walkspeed", 100, 16, function(value)
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

misc:CreateButton("antiafk",function()

    wait(0.5)local ba=Instance.new("ScreenGui")
local ca=Instance.new("TextLabel")local da=Instance.new("Frame")
local _b=Instance.new("TextLabel")local ab=Instance.new("TextLabel")ba.Parent=game.CoreGui
ba.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;ca.Parent=ba;ca.Active=true
ca.BackgroundColor3=Color3.new(0.176471,0.176471,0.176471)ca.Draggable=true
ca.Position=UDim2.new(0.698610067,0,0.098096624,0)ca.Size=UDim2.new(0,370,0,52)
ca.Font=Enum.Font.SourceSansSemibold;ca.Text="anti afk"ca.TextColor3=Color3.new(0,1,1)
ca.TextSize=22;da.Parent=ca
da.BackgroundColor3=Color3.new(0.196078,0.196078,0.196078)da.Position=UDim2.new(0,0,1.0192306,0)
da.Size=UDim2.new(0,370,0,107)_b.Parent=da
_b.BackgroundColor3=Color3.new(0.176471,0.176471,0.176471)_b.Position=UDim2.new(0,0,0.800455689,0)
_b.Size=UDim2.new(0,370,0,21)_b.Font=Enum.Font.Arial;_b.Text="anti afk"
_b.TextColor3=Color3.new(0,1,1)_b.TextSize=20;ab.Parent=da
ab.BackgroundColor3=Color3.new(0.176471,0.176471,0.176471)ab.Position=UDim2.new(0,0,0.158377,0)
ab.Size=UDim2.new(0,370,0,44)ab.Font=Enum.Font.ArialBold;ab.Text="status: active"
ab.TextColor3=Color3.new(0,1,1)ab.TextSize=20;local bb=game:service'VirtualUser'
game:service'Players'.LocalPlayer.Idled:connect(function()
bb:CaptureController()bb:ClickButton2(Vector2.new())
ab.Text="roblox tried to kick you but failed to do so!"wait(2)ab.Text="status : active"end)

end)

-- extra scripts

--aimlock code


local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- SETTINGS
local AIMLOCK_ENABLED = false
local BUTTON_ACTIVE = false
local lockedPart = nil
local TOGGLE_KEY = Enum.KeyCode.H
local FOV = 300

-- NPC FOLDERS
local NPC_FOLDERS = {}

-- REGISTER MANSION GUARDS
local mansion = workspace:WaitForChild("MansionRobbery")
local guardsFolder = mansion:FindFirstChild("GuardsFolder")
if guardsFolder then
    table.insert(NPC_FOLDERS, guardsFolder)
end
mansion.ChildAdded:Connect(function(child)
    if child.Name == "GuardsFolder" then
        table.insert(NPC_FOLDERS, child)
    end
end)

-- DYNAMIC DROP NPC REGISTRATION
local dropRegistered = false
RunService.RenderStepped:Connect(function()
    if not dropRegistered then
        local dropFolder = workspace:FindFirstChild("Drop") and workspace.Drop:FindFirstChild("NPCs")
        if dropFolder then
            table.insert(NPC_FOLDERS, dropFolder)
            dropRegistered = true
        end
    end
end)

-- GET NPC PART
local function getNPCPart(model)
    return model:FindFirstChild("Head")
        or model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("Torso")
end

-- GET NEAREST TARGET (NPCs first, CEO fallback)
local function getNearestTarget()
    local nearestPart = nil
    local shortest = FOV

    -- Check Drop + GuardsFolder
    for _, folder in ipairs(NPC_FOLDERS) do
        for _, npc in ipairs(folder:GetDescendants()) do
            if npc:IsA("Model") then
                local part = getNPCPart(npc)
                if part then
                    local pos, onScreen = Camera:WorldToScreenPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                        if dist < shortest then
                            shortest = dist
                            nearestPart = part
                        end
                    end
                end
            end
        end
    end

    -- Fallback: CEO if no NPCs under cursor
    if not nearestPart then
        local ceo = workspace:FindFirstChild("MansionRobbery")
            and workspace.MansionRobbery:FindFirstChild("ActiveBoss")
            and workspace.MansionRobbery.ActiveBoss:FindFirstChild("Head")
        if ceo then
            nearestPart = ceo
        end
    end

    return nearestPart
end

-- CREATE BUTTON
aimmod:CreateButton("Activate NPC Aimlock", function()
    BUTTON_ACTIVE = not BUTTON_ACTIVE
    AIMLOCK_ENABLED = false
    lockedPart = nil
    print("[Aimlock] Button clicked. Aimlock is now", BUTTON_ACTIVE and "ACTIVE" or "INACTIVE")
end)

-- H KEY TOGGLE
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == TOGGLE_KEY and BUTTON_ACTIVE then
        AIMLOCK_ENABLED = not AIMLOCK_ENABLED
        if AIMLOCK_ENABLED then
            lockedPart = getNearestTarget()
        else
            lockedPart = nil
        end
        print("[Aimlock]", AIMLOCK_ENABLED and "ENABLED (H)" or "DISABLED (H)")
    end
end)

-- AIMLOCK LOOP
RunService.RenderStepped:Connect(function()
    if BUTTON_ACTIVE and AIMLOCK_ENABLED then
        if lockedPart and lockedPart.Parent then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, lockedPart.Position)
        end
    end
end)

-- aimlock code
