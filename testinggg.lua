local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/NexityHereLol/robloxluascripts/refs/heads/main/simplistic_lib"))()
local int = lib:CreateInterface("Shindo Life Auto Farm", "script made by lohjc", "https://discord.gg/ZNTHTWx7KE", "bottom left", "royal")

-- Tabs
local autofarmss = int:CreateTab("Auto", "auto farm utilities (OP)", "op")
local main = int:CreateTab("Main", "main functions/script utilities", "default")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local CONFIG = {
    FarmDelay = 1,
    AutoGrindNormal = false,
    AutoGrindBoss = false,
    AutoGrindBoth = false,
}

-- State
local farmRunning = false
local farmLoop = nil

-- ============ NORMAL MISSION FUNCTIONS ============

-- Find all NPCs in the village that give missions
local function findMissionNPCs()
    local npcs = {}
    
    -- Check main mission givers folder
    local missionGivers = Workspace:FindFirstChild("missiongivers")
    if missionGivers then
        for _, child in ipairs(missionGivers:GetChildren()) do
            if child:FindFirstChild("CLIENTTALK") then
                table.insert(npcs, {
                    Name = child.Name,
                    Object = child,
                    Type = "normal"
                })
            end
        end
    end
    
    -- Also check for NPCs with CLIENTTALK in workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("CLIENTTALK") then
            -- Check if it's already in the list
            local exists = false
            for _, npc in ipairs(npcs) do
                if npc.Object == obj then
                    exists = true
                    break
                end
            end
            if not exists then
                table.insert(npcs, {
                    Name = obj.Name,
                    Object = obj,
                    Type = "normal"
                })
            end
        end
    end
    
    return npcs
end

-- Teleport to NPC and start conversation
local function teleportToNPCAndTalk(npc)
    if not npc or not npc.Object then return false end
    
    local character = LocalPlayer.Character
    if not character then return false end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    -- Find the NPC's primary part
    local targetPart = npc.Object:FindFirstChild("HumanoidRootPart") or npc.Object:FindFirstChild("Head")
    if not targetPart then 
        -- Try to find any BasePart
        for _, child in ipairs(npc.Object:GetChildren()) do
            if child:IsA("BasePart") then
                targetPart = child
                break
            end
        end
    end
    
    if not targetPart then
        print("❌ Could not find target part for NPC:", npc.Name)
        return false
    end
    
    -- Teleport to NPC (in front of them)
    local teleportPos = targetPart.Position + Vector3.new(0, 2, 3)
    pcall(function()
        hrp.CFrame = CFrame.new(teleportPos)
        print("✅ Teleported to NPC:", npc.Name)
    end)
    
    -- Wait a moment for teleport to register
    task.wait(0.3)
    
    -- Use CLIENTTALK to engage conversation
    local talkEvent = npc.Object:FindFirstChild("CLIENTTALK")
    if talkEvent then
        pcall(function()
            talkEvent:FireServer("accept")
            print("✅ Started conversation with NPC:", npc.Name)
            return true
        end)
    else
        print("❌ No CLIENTTALK found for NPC:", npc.Name)
        return false
    end
    
    return true
end

-- ============ BOSS MISSION FUNCTIONS ============

-- Find all boss mission scrolls
local function findBossScrolls()
    local scrolls = {}
    
    -- Check boss drop mission folder
    local bossMission = Workspace:FindFirstChild("bossdropmission")
    if bossMission then
        local missionsFolder = bossMission:FindFirstChild("missions")
        if missionsFolder then
            for _, child in ipairs(missionsFolder:GetChildren()) do
                local missionGiver = child:FindFirstChild("missiongiver")
                if missionGiver and missionGiver:FindFirstChild("CLIENTTALK") then
                    table.insert(scrolls, {
                        Name = child.Name,
                        Object = missionGiver,
                        Type = "boss"
                    })
                end
            end
        end
    end
    
    -- Also search for scrolls in workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():match("scroll") then
            local parent = obj.Parent
            if parent and parent.Name:lower():match("boss") then
                -- Check if this scroll has CLIENTTALK somewhere
                local talkEvent = parent:FindFirstChild("CLIENTTALK") or obj:FindFirstChild("CLIENTTALK")
                if talkEvent then
                    table.insert(scrolls, {
                        Name = parent.Name or obj.Name,
                        Object = parent or obj,
                        Type = "boss",
                        Part = obj
                    })
                end
            end
        end
    end
    
    return scrolls
end

-- Teleport to boss scroll and start mission
local function teleportToBossScroll(scroll)
    if not scroll or not scroll.Object then return false end
    
    local character = LocalPlayer.Character
    if not character then return false end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    -- Find the scroll's position
    local targetPart = scroll.Part or scroll.Object:FindFirstChild("HumanoidRootPart") or scroll.Object:FindFirstChild("Head")
    
    if not targetPart then
        -- Try to find any BasePart
        for _, child in ipairs(scroll.Object:GetChildren()) do
            if child:IsA("BasePart") then
                targetPart = child
                break
            end
        end
    end
    
    if not targetPart then
        print("❌ Could not find target part for boss scroll:", scroll.Name)
        return false
    end
    
    -- Teleport to scroll
    local teleportPos = targetPart.Position + Vector3.new(0, 2, 0)
    pcall(function()
        hrp.CFrame = CFrame.new(teleportPos)
        print("✅ Teleported to boss scroll:", scroll.Name)
    end)
    
    -- Wait a moment for teleport to register
    task.wait(0.3)
    
    -- Use CLIENTTALK to start boss mission
    local talkEvent = scroll.Object:FindFirstChild("CLIENTTALK")
    if not talkEvent then
        talkEvent = targetPart:FindFirstChild("CLIENTTALK")
    end
    
    if talkEvent then
        pcall(function()
            talkEvent:FireServer("accept")
            print("✅ Started boss mission:", scroll.Name)
            return true
        end)
    else
        print("❌ No CLIENTTALK found for boss scroll:", scroll.Name)
        return false
    end
    
    return true
end

-- ============ MAIN FARM LOOP ============

local function farmLoopFunction()
    while farmRunning do
        local character = LocalPlayer.Character
        if not character then 
            task.wait(1)
            continue 
        end
        
        print("🔄 Farming cycle...")
        
        -- Handle Normal Missions
        if CONFIG.AutoGrindNormal or CONFIG.AutoGrindBoth then
            print("📋 Looking for normal missions...")
            local npcs = findMissionNPCs()
            if #npcs > 0 then
                for _, npc in ipairs(npcs) do
                    teleportToNPCAndTalk(npc)
                    task.wait(CONFIG.FarmDelay)
                end
            else
                print("ℹ️ No normal mission NPCs found")
            end
        end
        
        -- Handle Boss Missions
        if CONFIG.AutoGrindBoss or CONFIG.AutoGrindBoth then
            print("👑 Looking for boss missions...")
            local scrolls = findBossScrolls()
            if #scrolls > 0 then
                for _, scroll in ipairs(scrolls) do
                    teleportToBossScroll(scroll)
                    task.wait(CONFIG.FarmDelay)
                end
            else
                print("ℹ️ No boss scrolls found")
            end
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
    task.spawn(farmLoopFunction)
end

local function stopFarming()
    if not farmRunning then return end
    farmRunning = false
    print("⏹️ Auto-farm stopped!")
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
    if state and CONFIG.AutoGrindBoth then
        CONFIG.AutoGrindBoth = false
    end
end)

autofarmss:CreateCheckbox("👑 Auto Grind Boss Missions", function(state)
    CONFIG.AutoGrindBoss = state
    if state and CONFIG.AutoGrindNormal then
        CONFIG.AutoGrindNormal = false
    end
    if state and CONFIG.AutoGrindBoth then
        CONFIG.AutoGrindBoth = false
    end
end)

autofarmss:CreateCheckbox("⭐ Auto Grind Both", function(state)
    CONFIG.AutoGrindBoth = state
    if state then
        CONFIG.AutoGrindNormal = false
        CONFIG.AutoGrindBoss = false
    end
end)

autofarmss:CreateSlider("Farm Delay (seconds)", 5, 0.5, function(value)
    CONFIG.FarmDelay = value
end):SetValue(1)

-- Manual Controls
autofarmss:CreateButton("📍 Teleport to Normal NPC", function()
    local npcs = findMissionNPCs()
    if #npcs > 0 then
        teleportToNPCAndTalk(npcs[1])
    else
        print("❌ No normal NPCs found")
    end
end)

autofarmss:CreateButton("📍 Teleport to Boss Scroll", function()
    local scrolls = findBossScrolls()
    if #scrolls > 0 then
        teleportToBossScroll(scrolls[1])
    else
        print("❌ No boss scrolls found")
    end
end)

autofarmss:CreateButton("🔍 Scan for NPCs", function()
    local npcs = findMissionNPCs()
    print("📋 Found", #npcs, "mission NPCs")
    for _, npc in ipairs(npcs) do
        print("   -", npc.Name)
    end
end)

autofarmss:CreateButton("🔍 Scan for Boss Scrolls", function()
    local scrolls = findBossScrolls()
    print("📋 Found", #scrolls, "boss scrolls")
    for _, scroll in ipairs(scrolls) do
        print("   -", scroll.Name)
    end
end)

-- Main Tab
main:CreateButton("📍 Teleport to Normal NPC", function()
    local npcs = findMissionNPCs()
    if #npcs > 0 then
        teleportToNPCAndTalk(npcs[1])
    end
end)

main:CreateButton("📍 Teleport to Boss Scroll", function()
    local scrolls = findBossScrolls()
    if #scrolls > 0 then
        teleportToBossScroll(scrolls[1])
    end
end)

main:CreateButton("🔍 Scan for NPCs", function()
    local npcs = findMissionNPCs()
    print("📋 Found", #npcs, "mission NPCs")
    for _, npc in ipairs(npcs) do
        print("   -", npc.Name)
    end
end)

main:CreateButton("🔍 Scan for Boss Scrolls", function()
    local scrolls = findBossScrolls()
    print("📋 Found", #scrolls, "boss scrolls")
    for _, scroll in ipairs(scrolls) do
        print("   -", scroll.Name)
    end
end)

print("✅ Shindo Life Auto Farm loaded!")
print("")
print("🔧 FEATURES:")
print("   - 📋 Normal Missions: Teleports to NPCs and starts conversation")
print("   - 👑 Boss Missions: Teleports to scrolls and starts mission")
print("   - ⭐ Both Mode: Does both normal and boss missions")
print("   - 🔍 Scan for available NPCs and scrolls")
print("")
print("🚀 Toggle 'Auto-Farm' to start!")
print("📌 Select a grind mode (Normal, Boss, or Both)")
