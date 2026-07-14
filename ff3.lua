local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/iiivyne/cl56295913a02/refs/heads/main/simplistic_lib.lua"))()
local int = lib:CreateInterface("⚡ Auto Rush + Player", "client:" .. math.random(), "https://discord.gg/ZNTHTWx7KE", "bottom left", "royal")
local player_p = int:CreateTab("player", "player script", "info")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local plr = Players.LocalPlayer

-- Toggles
local autoRush = false
local speedEnabled = false
local speedValue = 1
local movementLoop = nil
local jumpoweron = false
local jumpboost = 65
local nojpcooldownon = false
local njcconnections = {}

-- AUTO RUSH VARIABLES
local FOLLOW_DISTANCE = 1.5
local rushActive = false
local lastTarget = nil
local lastTargetPos = nil
local lostTargetTime = 0
local FOLLOW_DELAY = 2

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

print("✅ Cleaned script loaded!")
print("")
print("🏃 AUTO RUSH QB:")
print("   - 🔥 Follows until TOUCHING distance (1.5 studs)")
print("   - ⏱️ 2 second extra chase delay")
print("   - 🎯 Automatically tracks football holder")
print("")
print("🚀 PLAYER FEATURES:")
print("   - CFrame Speed (no lag movement)")
print("   - Jump Power (boosted jumps)")
print("   - No Jump Cooldown (spam jumps)")
