local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Constants for highlighting and tracers
local highlightColor = Color3.fromRGB(255, 0, 0)  -- Red color
local lineColor = Color3.fromRGB(255, 0, 0)  -- Red color for the lines
local lineThickness = 0  -- Line thickness

-- Fly constants
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local flying = false
local flySpeed = 200
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

-- Tables to hold the highlight and line objects for each player
local lines = {}

-- Function to create or reapply a Highlight instance on a character
local function applyHighlightToCharacter(character)
    local existingHighlight = character:FindFirstChildOfClass("Highlight")
    if existingHighlight then
        existingHighlight:Destroy()
    end
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerHighlight"
    highlight.Adornee = character
    highlight.FillColor = highlightColor
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = highlightColor
    highlight.Parent = character
end

-- Function to create a line from the local player to a target player
local function createLineToPlayer(player)
    local line = Drawing.new("Line")
    line.Color = lineColor
    line.Thickness = lineThickness
    line.Transparency = 1
    line.Visible = true
    return line
end

-- Function to update the line to the player
local function updateLineToPlayer(line, targetPlayer)
    local camera = workspace.CurrentCamera
    if targetPlayer.Character and player.Character then
        local targetHead = targetPlayer.Character:FindFirstChild("Head")
        local localRootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if targetHead and localRootPart then
            local targetPosition = camera:WorldToViewportPoint(targetHead.Position)
            local localPosition = camera:WorldToViewportPoint(localRootPart.Position)
            line.From = Vector2.new(localPosition.X, localPosition.Y)
            line.To = Vector2.new(targetPosition.X, targetPosition.Y)
            line.Visible = true
        else
            line.Visible = false
        end
    else
        line.Visible = false
    end
end

-- Function to handle when a player's character is added
local function onCharacterAdded(player, character)
    character:WaitForChild("HumanoidRootPart", 5)
    applyHighlightToCharacter(character)
end

-- Process existing players (except local player)
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        if player.Character then
            applyHighlightToCharacter(player.Character)
        end
        player.CharacterAdded:Connect(function(character)
            onCharacterAdded(player, character)
        end)
        lines[player] = createLineToPlayer(player)
    end
end

-- Listen for new players joining
Players.PlayerAdded:Connect(function(player)
    if player ~= Players.LocalPlayer then
        player.CharacterAdded:Connect(function(character)
            onCharacterAdded(player, character)
        end)
        lines[player] = createLineToPlayer(player)
    end
end)

-- Continuously check and update highlights and lines every frame
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character then
            if not player.Character:FindFirstChildOfClass("Highlight") then
                applyHighlightToCharacter(player.Character)
            end
            if lines[player] then
                updateLineToPlayer(lines[player], player)
            end
        end
    end

    -- Update flying mechanics if flying
    if flying then
        local cam = workspace.CurrentCamera
        local moveVector = Vector3.new(0, 0, 0)
        if keysPressed.W then moveVector = moveVector + cam.CFrame.LookVector end
        if keysPressed.S then moveVector = moveVector - cam.CFrame.LookVector end
        if keysPressed.A then moveVector = moveVector - cam.CFrame.RightVector end
        if keysPressed.D then moveVector = moveVector + cam.CFrame.RightVector end
        if keysPressed.Space then moveVector = moveVector + Vector3.new(0, 1, 0) end
        if keysPressed.LeftControl then moveVector = moveVector - Vector3.new(0, 1, 0) end

        if moveVector.Magnitude > 0 then
            moveVector = moveVector.Unit * flySpeed
        end

        bodyVelocity.Velocity = moveVector
        bodyGyro.CFrame = cam.CFrame
    end
end)

-- Start flying function
local function startFlying()
    if flying then return end
    flying = true

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Parent = hrp
    bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Parent = hrp
    bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bodyGyro.CFrame = hrp.CFrame

    updateConnection = RunService.RenderStepped:Connect(function(delta)
        if not flying then return end
        local moveVector = Vector3.new(0, 0, 0)
        local cam = workspace.CurrentCamera
        if keysPressed.W then moveVector = moveVector + cam.CFrame.LookVector end
        if keysPressed.S then moveVector = moveVector - cam.CFrame.LookVector end
        if keysPressed.A then moveVector = moveVector - cam.CFrame.RightVector end
        if keysPressed.D then moveVector = moveVector + cam.CFrame.RightVector end
        if keysPressed.Space then moveVector = moveVector + Vector3.new(0, 1, 0) end
        if keysPressed.LeftControl then moveVector = moveVector - Vector3.new(0, 1, 0) end
        if moveVector.Magnitude > 0 then
            moveVector = moveVector.Unit * flySpeed
        end
        bodyVelocity.Velocity = moveVector
        bodyGyro.CFrame = cam.CFrame
    end)
end

-- Stop flying function
local function stopFlying()
    if not flying then return end
    flying = false
    if updateConnection then
        updateConnection:Disconnect()
        updateConnection = nil
    end
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
end

-- Toggle flying with F key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.F then
        if not flying then
            startFlying()
        else
            stopFlying()
        end
    end

    if input.KeyCode == Enum.KeyCode.W then keysPressed.W = true end
    if input.KeyCode == Enum.KeyCode.A then keysPressed.A = true end
    if input.KeyCode == Enum.KeyCode.S then keysPressed.S = true end
    if input.KeyCode == Enum.KeyCode.D then keysPressed.D = true end
    if input.KeyCode == Enum.KeyCode.Space then keysPressed.Space = true end
    if input.KeyCode == Enum.KeyCode.LeftControl then keysPressed.LeftControl = true end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.W then keysPressed.W = false end
    if input.KeyCode == Enum.KeyCode.A then keysPressed.A = false end
    if input.KeyCode == Enum.KeyCode.S then keysPressed.S = false end
    if input.KeyCode == Enum.KeyCode.D then keysPressed.D = false end
    if input.KeyCode == Enum.KeyCode.Space then keysPressed.Space = false end
    if input.KeyCode == Enum.KeyCode.LeftControl then keysPressed.LeftControl = false end
end)

-- Optional: Ensure that if the character respawns, flying stops and resets
player.CharacterAdded:Connect(function(newChar)
    stopFlying()
    character = newChar
    hrp = character:WaitForChild("HumanoidRootPart")
end)

print("Combined Player Highlight, Tracer, and Fly Script Loaded and Running.")