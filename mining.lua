--run this one 
upd = "https://raw.githubusercontent.com/iiivyne/mylib/refs/heads/main/lib.lua"
local lib = loadstring(game:HttpGet(upd))()
local int = lib:CreateInterface("mining sim","script undergoing development","https://discord.gg/ZNTHTWx7KE","bottom right","default")

local main = int:CreateTab("main", "main","op")
local plr = int:CreateTab("player","modify your localplayer","player")
local srv = int:CreateTab("server", "server hop to other games","npc")
local misc = int:CreateTab("misc","miscellaneous","misc")
local Players = game:GetService("Players")

--
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")


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


--// =========================
--// MAIN & VISUAL TABS
--// =========================

--// SERVICES (SINGLE SOURCE)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Remote = game.ReplicatedStorage.Network:InvokeServer()

--// GAME REFERENCES
local Blocks = workspace:WaitForChild("Blocks")
local CoinsAmount = LocalPlayer.leaderstats.Coins
local Rebirths = LocalPlayer.leaderstats.Rebirths
local InventoryAmount = LocalPlayer.PlayerGui.ScreenGui.StatsFrame2.Inventory.Amount

--// CONFIG
local SELL_TRESHOLD = nil

--// TOGGLES
local Toggles = {
	AutoMine = false,
	FastMine = false,
	AutoSell = false,
	AutoBackpack = false,
	AutoTools = false,
	AutoRebirth = false
}

--// HELPERS
local function GetCoinsAmount()
	return tonumber(CoinsAmount.Value:gsub(",", "")) or 0
end

local function GetInventoryAmount()
	local clean = InventoryAmount.Text:gsub("%s+", ""):gsub(",", "")
	local split = clean:split("/")
	return tonumber(split[1]) or 0, tonumber(split[2]) or 0
end

--// =========================
--// AUTO MINE
--// =========================
local function StartAutoMine()
	task.spawn(function()
		while Toggles.AutoMine do
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")

			if hrp then
				local region = Region3.new(
					hrp.Position - Vector3.new(10,10,10),
					hrp.Position + Vector3.new(10,10,10)
				)

				for _, part in pairs(workspace:FindPartsInRegion3WithWhiteList(region,{Blocks},100)) do
					if part:IsA("BasePart") then
						Remote:FireServer("MineBlock", {{part.Parent}})
						task.wait()
					end
				end
			end
			task.wait()
		end
	end)
end

--// =========================
--// FAST MINE
--// =========================
local function ApplyFastMine(block)
	local stats = block:FindFirstChild("Stats")
	local mult = stats and stats:FindFirstChild("Multiplier")
	if not mult then return end

	if not stats:FindFirstChild("ActualMultiplier") then
		local clone = mult:Clone()
		clone.Name = "ActualMultiplier"
		clone.Parent = stats
	end

	mult.Value = -1337
end

local function EnableFastMine()
	for _, block in pairs(Blocks:GetChildren()) do
		ApplyFastMine(block)
	end
end

local function DisableFastMine()
	for _, block in pairs(Blocks:GetChildren()) do
		local stats = block:FindFirstChild("Stats")
		local mult = stats and stats:FindFirstChild("Multiplier")
		local original = stats and stats:FindFirstChild("ActualMultiplier")
		if mult and original then
			mult.Value = original.Value
		end
	end
end

Blocks.ChildAdded:Connect(function(block)
	if Toggles.FastMine then
		ApplyFastMine(block)
	end
end)

--// =========================
--// AUTO REBIRTH / BUY
--// =========================
-- Debounce for rebirth and purchases
local rebirthDebounce = false
local buyDebounce = false

-- Connect to coins changing safely
CoinsAmount.Changed:Connect(function(newValue)
    -- Auto Rebirth
    if Toggles.AutoRebirth and not rebirthDebounce then
        local cost = 1_000_000 * Rebirths.Value
        if cost > 0 and newValue >= cost then
            rebirthDebounce = true
            Remote:FireServer("Rebirth", {{}})
            task.delay(2, function() rebirthDebounce = false end)
        end
    end

    -- Auto Buy Backpacks / Tools
    if (Toggles.AutoBackpack or Toggles.AutoTools) and not buyDebounce then
        buyDebounce = true
        task.spawn(function()
            if Toggles.AutoBackpack then
                for i = 3, 50 do
                    Remote:FireServer("BuyItem", {{"Backpack", i}})
                    task.wait(0.1)
                end
            end
            if Toggles.AutoTools then
                for i = 1, 50 do
                    Remote:FireServer("BuyItem", {{"Tools", i}})
                    task.wait(0.1)
                end
            end
            buyDebounce = false
        end)
    end
end)



--// =========================
--// AUTO SELL
--// =========================
InventoryAmount.Changed:Connect(function()
   if Change == "Text" then
			if Toggles["AutoSell"] then
				local Amount, MaxAmount, AmountComma, MaxAmountComma2 = GetInventoryAmount()
				if SELL_TRESHOLD ~= nil then
					MaxAmount = SELL_TRESHOLD
				end
				if Amount >= MaxAmount then
					local Character = LocalPlayer.Character
					if Character then
						local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
						if HumanoidRootPart then
							local SavedLocation = HumanoidRootPart.CFrame
							local SavedText = InventoryAmount.Text
							while InventoryAmount.Text == SavedText do
								HumanoidRootPart.CFrame = CFrame.new(-116, 13, 38)
								Remote:FireServer("SellItems",{{               }})
								wait()
						 	end
							HumanoidRootPart.Anchored = true
							while HumanoidRootPart.CFrame ~= SavedLocation do
								HumanoidRootPart.CFrame = SavedLocation
							wait()
							end
							HumanoidRootPart.Anchored = false
						end
					end
				end
			end
		end
end)

--// =========================
--// MAIN TAB UI
--// =========================

-- Create checkboxes that only update Toggles

main:CreateButton("Sell", function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local savedPos = hrp.CFrame -- Save current position
    hrp.Anchored = true        -- Anchor to prevent falling

    -- Teleport to sell circle
    hrp.CFrame = CFrame.new(-118, 14, 44) 
    task.wait(0.5) -- Wait a moment for server to detect

    -- Fire the sell remote
    Remote:FireServer("SellItems", {{}})
    task.wait(0.5) -- Wait a bit for the server to process

    -- Return to original position
    hrp.CFrame = savedPos
    hrp.Anchored = false
end)


main:CreateCheckbox("Auto Mine", function(v)
    Toggles.AutoMine = v
    print("AutoMine:", v)
    if v then StartAutoMine() end
end)

main:CreateCheckbox("Fast Mine", function(v)
    Toggles.FastMine = v
    print("FastMine:", v)
    if v then EnableFastMine() else DisableFastMine() end
end)

main:CreateCheckbox("Auto Sell", function(v)
    Toggles.AutoSell = v
    print("AutoSell:", v)
end)

main:CreateCheckbox("Auto Buy Backpacks", function(v)
    Toggles.AutoBackpack = v
    print("AutoBackpack:", v)
end)

main:CreateCheckbox("Auto Buy Tools", function(v)
    Toggles.AutoTools = v
    print("AutoTools:", v)
end)

main:CreateCheckbox("Auto Rebirth", function(v)
    Toggles.AutoRebirth = v
    print("AutoRebirth:", v)
end)

--

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local PlaceId = 1417427737 -- your game place id

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
        if s.playing < 8 then
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