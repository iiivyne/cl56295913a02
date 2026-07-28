local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/NexityHereLol/robloxluascripts/refs/heads/main/simplistic_lib"))()
local int = lib:CreateInterface("Shindo Life Auto Farm", "script made by lohjc", "https://discord.gg/ZNTHTWx7KE", "bottom left", "royal")

-- Tabs
local autofarmss = int:CreateTab("Auto", "auto farm utilities (OP)", "op")
local main = int:CreateTab("Main", "main functions/script utilities", "default")
local charactertp = int:CreateTab("Mob TP", "bring mobs to you", "npc")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local CONFIG = {
    FarmDelay = 2,
    TargetDistance = 50,
    AutoAcceptMissions = true,
    AutoTargetNPCs = true,
}

-- State
local farmRunning = false
local farmLoop = nil

-- Safe getnilinstances function (only works in certain executors)
local function getNilInstancesSafe()
    local success, result = pcall(function()
        return getnilinstances()
    end)
    if success then
        return result or {}
    end
    return {}
end

-- Function to find hidden instances
function getNil(name, class)
    for _, v in pairs(getNilInstancesSafe()) do
        if v.ClassName == class and v.Name == name then
            return v
        end
    end
    return nil
end

-- Get all available missions
local function getAvailableMissions()
    local missions = {}
    
    -- Check main mission givers
    local missionGivers = Workspace:FindFirstChild("missiongivers")
    if missionGivers then
        for _, child in ipairs(missionGivers:GetChildren()) do
            if child:FindFirstChild("CLIENTTALK") then
                table.insert(missions, {
                    Name = child.Name,
                    Object = child,
                })
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
                    table.insert(missions, {
                        Name = child.Name,
                        Object = missionGiver,
                    })
                end
            end
        end
    end
    
    return missions
end

-- Get all targetable NPCs
local function getTargetableNPCs()
    local npcs = {}
    local character = LocalPlayer.Character
    if not character then return npcs end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return npcs end
    
    -- Check workspace NPCs
    local npcFolder = Workspace:FindFirstChild("npc")
    if npcFolder then
        for _, child in ipairs(npcFolder:GetChildren()) do
            if child:IsA("Model") and child:FindFirstChild("HumanoidRootPart") then
                local targetHrp = child.HumanoidRootPart
                local distance = (hrp.Position - targetHrp.Position).Magnitude
                
                if distance <= CONFIG.TargetDistance then
                    table.insert(npcs, {
                        Name = child.Name,
                        HRP = targetHrp,
                        Distance = distance,
                    })
                end
            end
        end
    end
    
    -- Check for hidden NPCs (only if function exists)
    local hiddenInstances = getNilInstancesSafe()
    if hiddenInstances then
        for _, v in pairs(hiddenInstances) do
            if v.ClassName == "Model" and v:FindFirstChild("HumanoidRootPart") then
                local name = v.Name
                if name:match("npc") or name:match("boss") or name:match("target") then
                    local targetHrp = v.HumanoidRootPart
                    local distance = (hrp.Position - targetHrp.Position).Magnitude
                    
                    if distance <= CONFIG.TargetDistance then
                        table.insert(npcs, {
                            Name = name,
                            HRP = targetHrp,
                            Distance = distance,
                            Type = "hidden"
                        })
                    end
                end
            end
        end
    end
    
    -- Sort by distance
    table.sort(npcs, function(a, b) return a.Distance < b.Distance end)
    
    return npcs
end

-- Accept a mission
local function acceptMission(mission)
    if not mission or not mission.Object then return false end
    
    local talkEvent = mission.Object:FindFirstChild("CLIENTTALK")
    if not talkEvent then return false end
    
    local success = pcall(function()
        talkEvent:FireServer("accept")
        print("✅ Accepted mission:", mission.Name)
    end)
    
    return success
end

-- Target an NPC
local function targetNPC(npc)
    if not npc or not npc.HRP then return false end
    
    -- Check if startevent exists
    local startEvent = LocalPlayer:FindFirstChild("startevent")
    if not startEvent then
        print("⚠️ startevent not found, trying alternative...")
        -- Try to find it in ReplicatedStorage
        startEvent = ReplicatedStorage:FindFirstChild("startevent")
        if not startEvent then
            print("❌ startevent not found anywhere!")
            return false
        end
    end
    
    local success = pcall(function()
        local args = {
            [1] = "target",
            [2] = npc.HRP
        }
        startEvent:FireServer(unpack(args))
        print("✅ Targeted NPC:", npc.Name)
    end)
    
    return success
end

-- Check mission list
local function checkMissions()
    pcall(function()
        local compSystem = Workspace:FindFirstChild("newcompsystem")
        if compSystem then
            local getlist = compSystem:FindFirstChild("getlist")
            if getlist then
                local result = getlist:InvokeServer()
                if result then
                    print("📋 Missions:", result)
                end
            end
        end
    end)
end

-- Main farm loop
local function farmLoopFunction()
    while farmRunning do
        local character = LocalPlayer.Character
        if not character then 
            task.wait(1)
            continue 
        end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            task.wait(1)
            continue 
        end
        
        print("🔄 Farming cycle...")
        
        -- 1. Accept missions
        if CONFIG.AutoAcceptMissions then
            local missions = getAvailableMissions()
            if #missions > 0 then
                for _, mission in ipairs(missions) do
                    acceptMission(mission)
                    task.wait(0.3)
                end
            else
                print("ℹ️ No missions available")
            end
        end
        
        -- 2. Check mission list
        checkMissions()
        task.wait(0.3)
        
        -- 3. Target NPCs
        if CONFIG.AutoTargetNPCs then
            local npcs = getTargetableNPCs()
            if #npcs > 0 then
                for _, npc in ipairs(npcs) do
                    targetNPC(npc)
                    task.wait(0.3)
                end
            else
                print("ℹ️ No NPCs in range")
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

-- Bring NPCs to you
local function bringNPCsToYou()
    local character = LocalPlayer.Character
    if not character then 
        print("❌ No character found")
        return 
    end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then 
        print("❌ No HumanoidRootPart found")
        return 
    end
    
    local npcFolder = Workspace:FindFirstChild("npc")
    if not npcFolder then
        print("❌ No NPC folder found")
        return
    end
    
    local count = 0
    for _, child in ipairs(npcFolder:GetChildren()) do
        if child:IsA("Model") and child:FindFirstChild("HumanoidRootPart") then
            local targetHrp = child.HumanoidRootPart
            if targetHrp then
                pcall(function()
                    targetHrp.CFrame = hrp.CFrame + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
                    count = count + 1
                    task.wait(0.1)
                end)
            end
        end
    end
    print("✅ Brought", count, "NPCs to you!")
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

autofarmss:CreateCheckbox("📋 Auto Accept Missions", function(state)
    CONFIG.AutoAcceptMissions = state
end):SetValue(true)

autofarmss:CreateCheckbox("🎯 Auto Target NPCs", function(state)
    CONFIG.AutoTargetNPCs = state
end):SetValue(true)

autofarmss:CreateSlider("Farm Delay (seconds)", 10, 0.5, function(value)
    CONFIG.FarmDelay = value
end):SetValue(2)

autofarmss:CreateSlider("Target Distance", 100, 10, function(value)
    CONFIG.TargetDistance = value
end):SetValue(50)

-- Manual Controls
autofarmss:CreateButton("📋 Accept All Missions", function()
    local missions = getAvailableMissions()
    if #missions > 0 then
        for _, mission in ipairs(missions) do
            acceptMission(mission)
            task.wait(0.3)
        end
    else
        print("ℹ️ No missions found")
    end
end)

autofarmss:CreateButton("🎯 Target Nearest NPC", function()
    local npcs = getTargetableNPCs()
    if #npcs > 0 then
        targetNPC(npcs[1])
    else
        print("ℹ️ No NPCs in range")
    end
end)

autofarmss:CreateButton("📋 Check Missions", function()
    checkMissions()
end)

-- Info Display
autofarmss:CreateLabel("📊 Status: Ready")

-- Mob TP Tab
charactertp:CreateButton("🔄 Bring All NPCs To You", function()
    bringNPCsToYou()
end)

-- Main Tab - Quick Actions
main:CreateButton("📋 Accept All Missions", function()
    local missions = getAvailableMissions()
    if #missions > 0 then
        for _, mission in ipairs(missions) do
            acceptMission(mission)
            task.wait(0.3)
        end
    end
end)

main:CreateButton("🎯 Target All NPCs", function()
    local npcs = getTargetableNPCs()
    if #npcs > 0 then
        for _, npc in ipairs(npcs) do
            targetNPC(npc)
            task.wait(0.3)
        end
    end
end)

main:CreateButton("🔄 Bring All NPCs To You", function()
    bringNPCsToYou()
end)

print("✅ Shindo Life Auto Farm loaded!")
print("")
print("🔧 FEATURES:")
print("   - 🔄 Automatic farming loop")
print("   - 📋 Accepts all available missions")
print("   - 🎯 Targets NPCs in range")
print("   - 🔍 Finds hidden NPCs (if supported)")
print("   - 📊 Distance-based targeting")
print("   - 🔄 Bring NPCs to you")
print("")
print("🚀 Toggle 'Auto-Farm' to start!")
