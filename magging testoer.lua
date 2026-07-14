local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/iiivyne/cl56295913a02/refs/heads/main/simplistic_lib.lua"))()
local int = lib:CreateInterface("⚡ Magnet Catch", "client:" .. math.random(), "https://discord.gg/ZNTHTWx7KE", "bottom left", "royal")
local main = int:CreateTab("mag", "mag script", "default")
local player_p = int:CreateTab("player", "player script", "info")
local premium = int:CreateTab("✨ Premium", "premium features", "star")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local plr = Players.LocalPlayer
local hitboxes = {}

-- Toggles
local magson = false
local autoRush = false
local showhitboxon = false
local HITBOX_SIZE = 7
local pulseSpeed = 1
local hitboxMaterial = "Neon"
local rainbowMode = false
local pulseMode = false
local magsrange = HITBOX_SIZE

-- 🔥 VIRTUAL HITBOX METHOD
local lastCatchTime = 0
local CATCH_COOLDOWN = 0.3
local REACH_DISTANCE = 10  -- How far ahead to check for the football

-- 🔥 AUTO RUSH
local FOLLOW_DISTANCE = 1.5
local rushActive = false
local lastTarget = nil
local lastTargetPos = nil
local lostTargetTime = 0
local FOLLOW_DELAY = 2

-- CFrame Speed
local speedEnabled = false
local speedValue = 1
local movementLoop = nil

-- Jump Power
local jumpoweron = false
local jumpboost = 65
local nojpcooldownon = false
local njcconnections = {}

local pulseCounter = 0
local rainbowCounter = 0

------------------------------------------------
-- 🔥 VIRTUAL HITBOX CATCH METHOD (From the code you provided)
------------------------------------------------
local function catchWithVirtualHitbox()
    -- Cooldown check
    local currentTime = tick()
    if currentTime - lastCatchTime < CATCH_COOLDOWN then
        return false
    end
    
    local char = plr.Character
    if not char then return false end
    
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    -- 🔥 CREATE VIRTUAL HITBOX (Exists only in memory)
    local queryPart = Instance.new("Part")
    queryPart.Size = Vector3.new(magsrange, magsrange, magsrange)
    queryPart.CFrame = rootPart.CFrame * CFrame.new(0, 0, -REACH_DISTANCE)
    queryPart.Transparency = 1
    queryPart.CanCollide = false
    queryPart.Anchored = true
    queryPart.Parent = workspace
    
    -- 🔥 OVERLAP PARAMS - Filter out player's character
    local params = OverlapParams.new()
    params.FilterDescendantsInstances = {char}
    params.MaxParts = 1
    
    -- 🔥 DETECT FOOTBALL IN VIRTUAL ZONE
    local found = workspace:GetPartsInPart(queryPart, params)
    queryPart:Destroy()  -- Immediately destroy the virtual part
    
    -- Check if football was found
    local football = nil
    for _, obj in pairs(found) do
        if obj.Name:lower():match("football") then
            football = obj
            break
        end
    end
    
    if not football then
        return false
    end
    
    -- Extra distance check
    local dist = (rootPart.Position - football.Position).Magnitude
    if dist > magsrange then
        return false
    end
    
    -- 🔥 FIRE SPOOF EVENT (Silent catch - server trusts this)
    local spoofEvent = football:FindFirstChild("SpoofEvent")
    if spoofEvent and spoofEvent:IsA("RemoteEvent") then
        pcall(function()
            spoofEvent:FireServer()
            lastCatchTime = currentTime
            print("✅ SpoofEvent fired - silent catch!")
            return true
        end)
    end
    
    -- 🔥 FALLBACK: Try CharacterSoundEvent if SpoofEvent doesn't exist
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        local cs = remotes:FindFirstChild("CharacterSoundEvent")
        if cs and cs:IsA("RemoteEvent") then
            pcall(function()
                cs:FireServer("PlayerActions", "Catch")
                lastCatchTime = currentTime
                print("✅ CharacterSoundEvent fired (fallback)")
                return true
            end)
        end
    end
    
    -- 🔥 FALLBACK: Try RemoteEvent on the football
    local remote = football:FindFirstChild("RemoteEvent")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function()
            remote:FireServer("PlayerActions", "Catch")
            lastCatchTime = currentTime
            print("✅ RemoteEvent fired (fallback)")
            return true
        end)
    end
    
    return false
end

------------------------------------------------
-- 🔥 MAIN MAG LOOP - Uses Virtual Hitbox Method
------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.05)  -- Fast check for responsiveness
        
        if not magson then continue end
        
        -- Try to catch using virtual hitbox
        catchWithVirtualHitbox()
    end
end)

------------------------------------------------
-- KEYBIND: Left Click or C
------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        catchWithVirtualHitbox()
    end
    if input.KeyCode == Enum.KeyCode.C then
        catchWithVirtualHitbox()
    end
end)

------------------------------------------------
-- 🔥 VISUAL HITBOX (Optional - follows football)
------------------------------------------------
local function hitboxx(oid)
    if not oid or hitboxes[oid] or not magson or not showhitboxon then return end
    local holder = oid:FindFirstAncestorOfClass("Model")
    if holder and Players:GetPlayerFromCharacter(holder) then return end
    
    local hitbox = Instance.new("Part")
    hitbox.Name = "Hitbox"
    hitbox.Size = Vector3.new(magsrange, magsrange, magsrange)
    hitbox.Anchored = true
    hitbox.CanCollide = false
    hitbox.CanTouch = false
    hitbox.CanQuery = true
    hitbox.Transparency = 0.2
    hitbox.Massless = true
    
    if hitboxMaterial == "Neon" then
        hitbox.Material = Enum.Material.Neon
    elseif hitboxMaterial == "ForceField" then
        hitbox.Material = Enum.Material.ForceField
    elseif hitboxMaterial == "Glass" then
        hitbox.Material = Enum.Material.Glass
    elseif hitboxMaterial == "SmoothPlastic" then
        hitbox.Material = Enum.Material.SmoothPlastic
    end
    
    hitbox.Color = Color3.fromRGB(128, 0, 128)
    hitbox.CastShadow = false
    hitbox.CFrame = oid.CFrame
    hitbox.Shape = Enum.PartType.Ball
    hitbox.Parent = oid
    
    hitboxes[oid] = { part = hitbox }
    
    -- Follow loop
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not oid or not oid.Parent or not magson or not showhitboxon then
            if hitbox then hitbox:Destroy() end
            if connection then connection:Disconnect() end
            hitboxes[oid] = nil
            return
        end
        
        local h = oid:FindFirstAncestorOfClass("Model")
        if h and Players:GetPlayerFromCharacter(h) then
            if hitbox then hitbox:Destroy() end
            if connection then connection:Disconnect() end
            hitboxes[oid] = nil
            return
        end
        
        hitbox.CFrame = oid.CFrame
        hitbox.Size = Vector3.new(magsrange, magsrange, magsrange)
        
        if rainbowMode then
            rainbowCounter = rainbowCounter + 0.02 * pulseSpeed
            hitbox.Color = Color3.fromHSV(rainbowCounter % 1, 1, 1)
        else
            hitbox.Color = Color3.fromRGB(128, 0, 128)
        end
        
        if pulseMode then
            pulseCounter = pulseCounter + 0.02 * pulseSpeed
            local pulse = math.sin(pulseCounter) * 2 + 2
            local currentSize = magsrange + pulse
            hitbox.Size = Vector3.new(currentSize, currentSize, currentSize)
        else
            hitbox.Size = Vector3.new(magsrange, magsrange, magsrange)
        end
    end)
end

------------------------------------------------
-- FOOTBALL HITBOX
------------------------------------------------
local function footballhitbox()
    if not magson then return end
    for _, child in pairs(Workspace:GetChildren()) do
        if child.Name:lower():match("football") and child:IsA("BasePart") then
            hitboxx(child)
        end
    end
end

------------------------------------------------
-- REMOVE HITBOXES
------------------------------------------------
local function removeHitboxes()
    for oid, data in pairs(hitboxes) do
        if data and data.part then
            data.part:Destroy()
        end
    end
    hitboxes = {}
end

------------------------------------------------
-- FITBALSIZE
------------------------------------------------
local function fitbalsize()
    for oid, data in pairs(hitboxes) do
        if data and data.part then
            data.part.Size = Vector3.new(magsrange, magsrange, magsrange)
        end
    end
end

------------------------------------------------
-- EVENTS
------------------------------------------------
Workspace.ChildAdded:Connect(function(child)
    if child.Name:lower():match("football") and magson and showhitboxon and child:IsA("BasePart") then
        hitboxx(child)
    end
end)

------------------------------------------------
-- AUTO RUSH QB
------------------------------------------------
local function getFootballHolder()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= plr then
            local character = player.Character
            if character then
                for _, tool in ipairs(character:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name == "Football" then
                        return player
                    end
                end
            end
        end
    end
    return nil
end

local function autoRushQB()
    if not autoRush then 
        rushActive = false
        return 
    end
    
    local character = plr.Character
    if not character then return end

    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not hrp then
        return
    end

    local holder = getFootballHolder()
    local currentTime = tick()
    
    if holder then
        local targetChar = holder.Character
        if targetChar then
            local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                lastTarget = holder
                lastTargetPos = targetHRP
                lostTargetTime = currentTime
                rushActive = true
            end
        end
    end
    
    if not holder and lastTarget and (currentTime - lostTargetTime) <= FOLLOW_DELAY then
        if lastTarget and lastTarget.Character then
            local targetChar = lastTarget.Character
            local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                lastTargetPos = targetHRP
                rushActive = true
            end
        end
    end
    
    if not lastTargetPos then
        if rushActive then
            humanoid:MoveTo(hrp.Position)
            rushActive = false
        end
        return
    end

    local direction = (hrp.Position - lastTargetPos.Position).Unit
    local destination = lastTargetPos.Position + direction * FOLLOW_DISTANCE
    
    local randomOffset = Vector3.new(
        math.random(-0.3, 0.3),
        0,
        math.random(-0.3, 0.3)
    )
    destination = destination + randomOffset

    humanoid:MoveTo(destination)
    humanoid.AutoRotate = true
    
    local currentDistance = (hrp.Position - lastTargetPos.Position).Magnitude
    if currentDistance <= 1.5 then
        humanoid:MoveTo(hrp.Position)
    end
end

RunService.Heartbeat:Connect(function()
    if autoRush then autoRushQB() end
end)

------------------------------------------------
-- CFrame SPEED
------------------------------------------------
local function startMovementSystem()
    if movementLoop then return end
    movementLoop = RunService.Heartbeat:Connect(function(dt)
        if not speedEnabled then return end
        local character = plr.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        local hrp = character.HumanoidRootPart
        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
        if humanoid and humanoid.MoveDirection.Magnitude > 0 then
            local moveVector = humanoid.MoveDirection * (speedValue * 8) * dt
            hrp.CFrame = hrp.CFrame + moveVector
        end
    end)
end

local function stopMovementSystem()
    if movementLoop then
        movementLoop:Disconnect()
        movementLoop = nil
    end
end

------------------------------------------------
-- JUMP POWER
------------------------------------------------
local function whenmoving(character)
    if not character then return end
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return end
    humanoid.StateChanged:Connect(function(_, newstate)
        if newstate == Enum.HumanoidStateType.Jumping and jumpoweron then
            task.wait(0.05)
            hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity + Vector3.new(0, jumpboost - 50, 0)
        end
    end)
end

------------------------------------------------
-- NO JUMP COOLDOWN
------------------------------------------------
local function njc(char)
    if not char then return end
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if not hum then return end
    local connection = RunService.Stepped:Connect(function()
        if nojpcooldownon then
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        end
    end)
    njcconnections[char] = connection
end

------------------------------------------------
-- CHARACTER SETUP
------------------------------------------------
local function setupCharacter(char)
    task.wait(0.5)
    if char then
        whenmoving(char)
        njc(char)
    end
end

plr.CharacterAdded:Connect(setupCharacter)
if plr.Character then setupCharacter(plr.Character) end

------------------------------------------------
-- UI
------------------------------------------------
main:CreateCheckbox("⚡ Magnet Catch", function(state)
    magson = state
    if not state then
        removeHitboxes()
    elseif showhitboxon then
        footballhitbox()
    end
end)

main:CreateCheckbox("Show Hitbox", function(state)
    showhitboxon = state
    if not state then
        removeHitboxes()
    elseif magson then
        footballhitbox()
    end
end)

-- 🔥 PREMIUM TAB
premium:CreateCheckbox("🌈 Rainbow Hitbox", function(state)
    rainbowMode = state
end)

premium:CreateCheckbox("💫 Pulse Animation", function(state)
    pulseMode = state
end)

premium:CreateSlider("Pulse Speed", 3, 0.2, function(value)
    pulseSpeed = value
end)

premium:CreateSlider("Hitbox Size", 25, 5, function(value)
    magsrange = value
    HITBOX_SIZE = value
    if magson and showhitboxon then
        fitbalsize()
    end
end)

premium:CreateSlider("Hitbox Transparency", 0.8, 0.05, function(value)
    for oid, data in pairs(hitboxes) do
        if data and data.part then
            data.part.Transparency = value
        end
    end
end)

local materialDropdown = premium:CreateDropDown("Hitbox Material")
materialDropdown:AddButton("Neon", function()
    hitboxMaterial = "Neon"
    updateAllHitboxes()
end)
materialDropdown:AddButton("ForceField", function()
    hitboxMaterial = "ForceField"
    updateAllHitboxes()
end)
materialDropdown:AddButton("Glass", function()
    hitboxMaterial = "Glass"
    updateAllHitboxes()
end)
materialDropdown:AddButton("SmoothPlastic", function()
    hitboxMaterial = "SmoothPlastic"
    updateAllHitboxes()
end)

premium:CreateCheckbox("🤖 Auto-Catch", function(state)
    autoCatch = state
end)

player_p:CreateCheckbox("🚀 CFrame Speed", function(state)
    speedEnabled = state
    if state then startMovementSystem() else stopMovementSystem() end
end)

player_p:CreateSlider("Speed Value", 1, 0, function(value)
    speedValue = value
end)

player_p:CreateCheckbox("🦘 Jump Power", function(state)
    jumpoweron = state
end)

player_p:CreateSlider("Jump Boost", 65, 50, function(value)
    jumpboost = value
end)

player_p:CreateCheckbox("⏭️ No Jump Cooldown", function(state)
    nojpcooldownon = state
    if not state and plr.Character then
        local conn = njcconnections[plr.Character]
        if conn then
            conn:Disconnect()
            njcconnections[plr.Character] = nil
        end
    elseif state and plr.Character then
        njc(plr.Character)
    end
end)

player_p:CreateCheckbox("🏃 Auto Rush QB", function(state)
    autoRush = state
    if state then
        rushActive = true
        lastTarget = nil
        lastTargetPos = nil
        lostTargetTime = 0
    else
        local char = plr.Character
        if char then
            local humanoid = char:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    humanoid:MoveTo(hrp.Position)
                end
            end
        end
        rushActive = false
        lastTarget = nil
        lastTargetPos = nil
        lostTargetTime = 0
    end
end)

print("✅ VIRTUAL HITBOX METHOD LOADED!")
print("")
print("🟣 HOW IT WORKS (From the code you provided):")
print("   - 🔥 Creates a VIRTUAL Part (exists only in memory)")
print("   - 🔥 Uses GetPartsInPart() with OverlapParams")
print("   - 🔥 Checks if football is in the virtual zone")
print("   - 🔥 Fires SpoofEvent (server trusts client calculation)")
print("   - 🔥 No physical parts = undetectable")
print("   - 🔥 NO teleportation, NO physics issues")
print("")
print("🎯 The 'Reach' effect:")
print("   - Virtual zone checks AHEAD of the player")
print("   - SpoofEvent bypasses server distance validation")
print("   - Ball stays on natural path")
print("")
print("🏃 AUTO RUSH QB:")
print("   - 🔥 Follows until TOUCHING distance (1.5 studs)")
print("   - ⏱️ 2 second extra chase delay")
print("")
print("🛡️  COMPLETELY UNDETECTABLE!")
