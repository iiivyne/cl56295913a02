local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/NexityHereLol/robloxluascripts/refs/heads/main/simplistic_lib"))()
local int = lib:CreateInterface("Shindo Life Auto Farm", "script made by lohjc", "https://discord.gg/ZNTHTWx7KE", "bottom left", "royal")

-- Tabs
local autofarmss = int:CreateTab("Auto", "auto farm utilities (OP)", "op")
local main = int:CreateTab("Main", "main functions/script utilities", "default")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

-- Configuration
local CONFIG = {
    FarmDelay = 0.5,
    TeleportDistance = 5,
    AutoGrindNormal = false,
    AutoGrindBoss = false,
    AutoGrindBoth = false,
    AutoClick = true,
    ClickDelay = 0.1,
}

-- State
local farmRunning = false
local farmLoop = nil
local currentTarget = nil
local isAttacking = false

-- Ember Village Scroll Locations (update these based on actual positions)
local SCROLL_LOCATIONS = {
    Normal = {
        -- Add actual scroll positions here
        -- Example: CFrame.new(x, y, z)
    },
    Boss = {
        -- Add actual boss scroll positions here
        -- Example: CFrame.new(x, y, z)
    }
}

-- Find scrolls in workspace
local function findScrolls()
    local scrolls = {
        Normal = {},
        Boss = {}
    }
    
    -- Search for scroll parts in workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():match("scroll") then
            local parent = obj.Parent
            if parent then
                local parentName = parent.Name:lower()
                if parentName:match("boss") or parentName:match("mission") then
                    table.insert(scrolls.Boss, obj)
                else
                    table.insert(scrolls.Normal, obj)
                end
            end
        end
    end
    
    -- Also check for mission givers
    local missionGivers = Workspace:FindFirstChild("missiongivers")
    if missionGivers then
        for _, child in ipairs(missionGivers:GetChildren()) do
            if child:FindFirstChild("CLIENTTALK") then
                table.insert(scrolls.Normal, child)
            end
        end
    end
    
    -- Check boss missions
    local bossMission = Workspace:FindFirstChild("bossdropmission")
    if bossMission then
        local missionsFolder = bossMission:FindFirstChild("missions")
        if missionsFolder then
            for _, child in ipairs(missionsFolder:GetChildren()) do
                local missionGiver = child:FindFirstChild("missiongiver")
                if missionGiver and missionGiver:FindFirstChild("CLIENTTALK") then
                    table.insert(scrolls.Boss, missionGiver)
                end
            end
        end
    end
    
    return scrolls
end

-- Teleport to scroll
local function teleportToScroll(scroll)
    if not scroll then return false end
    
    local character = LocalPlayer.Character
    if not character then return false end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local targetCFrame
    if scroll:IsA("BasePart") then
        targetCFrame = scroll.CFrame
    else
        -- If it's a model, find its primary part
        local primary = scroll:FindFirstChild("HumanoidRootPart") or scroll:FindFirstChild("Head")
        if primary then
            targetCFrame = primary.CFrame
        else
            return false
        end
    end
    
    -- Teleport to scroll
    pcall(function()
        hrp.CFrame = targetCFrame + Vector3.new(0, 2, 0) -- Slightly above
        print("✅ Teleported to scroll")
        return true
    end)
    
    return false
end

-- Interact with scroll (accept mission)
local function interactWithScroll(scroll)
    if not scroll then return false end
    
    -- Try to find CLIENTTALK or click event
    local talkEvent = scroll:FindFirstChild("CLIENTTALK")
    if talkEvent then
        pcall(function()
            talkEvent:FireServer("accept")
            print("✅ Accepted mission from scroll")
            return true
        end)
    end
    
    -- Alternative: Check for click detector
    local clickDetector = scroll:FindFirstChildWhichIsA("ClickDetector")
    if clickDetector then
        pcall(function()
            clickDetector:Click()
            print("✅ Clicked scroll")
            return true
        end)
    end
    
    return false
end

-- Find nearest enemy/mob
local function findNearestEnemy()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local nearest = nil
    local nearestDist = math.huge
    
    -- Search for NPCs/mobs in workspace
    local npcFolder = Workspace:FindFirstChild("npc")
    if npcFolder then
        for _, child in ipairs(npcFolder:GetChildren()) do
            if child:IsA("Model") and child:FindFirstChild("HumanoidRootPart") then
                -- Skip if it's a player
                if not Players:GetPlayerFromCharacter(child) then
                    local targetHrp = child.HumanoidRootPart
                    local distance = (hrp.Position - targetHrp.Position).Magnitude
                    
                    -- Check if alive
                    local humanoid = child:FindFirstChildWhichIsA("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        if distance < nearestDist then
                            nearest = child
                            nearestDist = distance
                        end
                    end
                end
            end
        end
    end
    
    -- Also search in workspace for other enemies
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChildWhichIsA("Humanoid") then
            if not Players:GetPlayerFromCharacter(obj) and not obj.Name:match("scroll") then
                local targetHrp = obj.HumanoidRootPart
                local distance = (hrp.Position - targetHrp.Position).Magnitude
                
                local humanoid = obj:FindFirstChildWhichIsA("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    if distance < nearestDist then
                        nearest = obj
                        nearestDist = distance
                    end
                end
            end
        end
    end
    
    return nearest, nearestDist
end

-- Teleport to enemy and attack
local function teleportToEnemyAndAttack()
    local enemy, distance = findNearestEnemy()
    if not enemy then 
        print("ℹ️ No enemies found")
        return false 
    end
    
    local character = LocalPlayer.Character
    if not character then return false end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local enemyHrp = enemy:FindFirstChild("HumanoidRootPart")
    if not enemyHrp then return false end
    
    -- Teleport to enemy
    pcall(function()
        -- Teleport slightly above and behind enemy
        local teleportPos = enemyHrp.Position + Vector3.new(0, 3, 5)
        hrp.CFrame = CFrame.new(teleportPos)
        print("✅ Teleported to enemy:", enemy.Name)
    end)
    
    -- Attack if enabled
    if CONFIG.AutoClick then
        attackEnemy()
    end
    
    return true
end

-- Attack enemy (simulate M1 clicks)
local function attackEnemy()
    if isAttacking then return end
    isAttacking = true
    
    pcall(function()
        -- Try different attack methods
        local character = LocalPlayer.Character
        if not character then 
            isAttacking = false
            return 
        end
        
        -- Method 1: Simulate mouse click
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                -- Already clicking
            end
        end)
        
        -- Method 2: Try to find attack remote
        local attackRemote = ReplicatedStorage:FindFirstChild("Attack")
        if attackRemote then
            attackRemote:FireServer()
        end
        
        -- Method 3: Simulate key press (M1)
        local VirtualInputManager = game:GetService("VirtualInputManager")
        if VirtualInputManager then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, Enum.UserInputType.MouseButton1, 0)
            task.wait(CONFIG.ClickDelay)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, Enum.UserInputType.MouseButton1, 0)
        end
        
        print("⚔️ Attacked enemy")
    end)
    
    task.wait(CONFIG.ClickDelay)
    isAttacking = false
end

-- Main grind loop
local function grindLoop()
    while farmRunning do
        local character = LocalPlayer.Character
        if not character then 
            task.wait(1)
            continue 
        end
        
        print("🔄 Grinding cycle...")
        
        -- Find scrolls
        local scrolls = findScrolls()
        local scrollToUse = nil
        
        -- Determine which scroll to use based on settings
        if CONFIG.AutoGrindBoth then
            -- Find any available scroll
            if #scrolls.Normal > 0 then
                scrollToUse = scrolls.Normal[1]
            elseif #scrolls.Boss > 0 then
                scrollToUse = scrolls.Boss[1]
            end
        elseif CONFIG.AutoGrindNormal and #scrolls.Normal > 0 then
            scrollToUse = scrolls.Normal[1]
        elseif CONFIG.AutoGrindBoss and #scrolls.Boss > 0 then
            scrollToUse = scrolls.Boss[1]
        end
        
        -- Teleport to scroll and interact
        if scrollToUse then
            print("📋 Found scroll:", scrollToUse.Name)
            teleportToScroll(scrollToUse)
            task.wait(1)
            interactWithScroll(scrollToUse)
            task.wait(1)
        else
            print("ℹ️ No scrolls found")
        end
        
        -- Find and fight enemies
        local enemyFound = teleportToEnemyAndAttack()
        
        if not enemyFound then
            print("⏳ No enemies, waiting...")
        end
        
        print("⏳ Waiting", CONFIG.FarmDelay, "seconds...")
        task.wait(CONFIG.FarmDelay)
    end
end

-- Start/Stop farming
local function startFarming()
    if farmRunning then return end
    farmRunning = true
    print("🚀 Auto-farm started!")
    task.spawn(grindLoop)
end

local function stopFarming()
    if not farmRunning then return end
    farmRunning = false
    isAttacking = false
    print("⏹️ Auto-farm stopped!")
end

-- Find and teleport to scroll
local function findAndTeleportToScroll(type)
    local scrolls = findScrolls()
    local scrollList = type == "boss" and scrolls.Boss or scrolls.Normal
    
    if #scrollList > 0 then
        teleportToScroll(scrollList[1])
        task.wait(0.5)
        interactWithScroll(scrollList[1])
    else
        print("❌ No", type, "scrolls found")
    end
end

-- ============ UI ============

-- Auto Farm Tab
autofarmss:CreateCheckbox("🔁 Auto-Farm", function(state)
    if state then
        startFarming()
    else
        stopFarming()
    end
end)

autofarmss:CreateCheckbox("📋 Auto Grind Normal Missions", function(state)
    CONFIG.AutoGrindNormal = state
    if state and CONFIG.AutoGrindBoss then
        CONFIG.AutoGrindBoss = false
    end
end)

autofarmss:CreateCheckbox("👑 Auto Grind Boss Missions", function(state)
    CONFIG.AutoGrindBoss = state
    if state and CONFIG.AutoGrindNormal then
        CONFIG.AutoGrindNormal = false
    end
end)

autofarmss:CreateCheckbox("⭐ Auto Grind Both", function(state)
    CONFIG.AutoGrindBoth = state
    if state then
        CONFIG.AutoGrindNormal = false
        CONFIG.AutoGrindBoss = false
    end
end)

autofarmss:CreateCheckbox("⚔️ Auto Click/M1", function(state)
    CONFIG.AutoClick = state
end):SetValue(true)

autofarmss:CreateSlider("Farm Delay (seconds)", 5, 0.2, function(value)
    CONFIG.FarmDelay = value
end):SetValue(0.5)

autofarmss:CreateSlider("Click Delay (seconds)", 1, 0.05, function(value)
    CONFIG.ClickDelay = value
end):SetValue(0.1)

-- Manual Controls
autofarmss:CreateButton("📍 Teleport to Normal Scroll", function()
    findAndTeleportToScroll("normal")
end)

autofarmss:CreateButton("📍 Teleport to Boss Scroll", function()
    findAndTeleportToScroll("boss")
end)

autofarmss:CreateButton("🎯 Find & Teleport to Enemy", function()
    teleportToEnemyAndAttack()
end)

-- Main Tab
main:CreateButton("📍 Teleport to Normal Scroll", function()
    findAndTeleportToScroll("normal")
end)

main:CreateButton("📍 Teleport to Boss Scroll", function()
    findAndTeleportToScroll("boss")
end)

main:CreateButton("🎯 Find & Teleport to Enemy", function()
    teleportToEnemyAndAttack()
end)

main:CreateButton("⚔️ Attack Enemy", function()
    attackEnemy()
end)

main:CreateButton("🔍 Scan for Scrolls", function()
    local scrolls = findScrolls()
    print("📋 Found", #scrolls.Normal, "normal scrolls and", #scrolls.Boss, "boss scrolls")
    for _, scroll in ipairs(scrolls.Normal) do
        print("   - Normal:", scroll.Name)
    end
    for _, scroll in ipairs(scrolls.Boss) do
        print("   - Boss:", scroll.Name)
    end
end)

print("✅ Shindo Life Auto Farm loaded!")
print("")
print("🔧 FEATURES:")
print("   - 🔄 Automatic grinding loop")
print("   - 📍 Teleports to mission scrolls")
print("   - 🎯 Teleports to enemies")
print("   - ⚔️ Auto attacks with M1")
print("   - 📋 Normal & Boss mission support")
print("   - ⭐ Both mode (normal + boss)")
print("")
print("🚀 Toggle 'Auto-Farm' to start!")
print("📌 Select a grind mode (Normal, Boss, or Both)")
