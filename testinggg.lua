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
    FarmDelay = 1.5,
    AutoGrindNormal = false,
    AutoGrindBoss = false,
    AutoGrindBoth = false,
    AutoTargetNPCs = true,
}

-- State
local farmRunning = false
local farmLoop = nil

-- ============ HELPER FUNCTIONS ============

-- Function to find hidden instances
function getNil(name, class)
    for _, v in pairs(getnilinstances()) do
        if v.ClassName == class and v.Name == name then
            return v
        end
    end
    return nil
end

-- ============ NORMAL MISSION FUNCTIONS ============

-- Get all normal mission NPCs from missiongivers
local function getNormalMissions()
    local missions = {}
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
    
    return missions
end

-- Accept normal mission
local function acceptNormalMission(mission)
    if not mission or not mission.Object then return false end
    
    local talkEvent = mission.Object:FindFirstChild("CLIENTTALK")
    if not talkEvent then return false end
    
    local args = {
        [1] = "accept"
    }
    
    pcall(function()
        talkEvent:FireServer(unpack(args))
        print("✅ Accepted normal mission:", mission.Name)
        return true
    end)
    
    return false
end

-- Target NPC for normal mission
local function targetNPCMission(npcName)
    local targetHRP = nil
    
    -- Try to find NPC in workspace.npc
    local npcFolder = Workspace:FindFirstChild("npc")
    if npcFolder then
        local npc = npcFolder:FindFirstChild(npcName)
        if npc and npc:FindFirstChild("HumanoidRootPart") then
            targetHRP = npc.HumanoidRootPart
        end
    end
    
    -- If not found, try getNil (hidden instances)
    if not targetHRP then
        local hiddenNPC = getNil(npcName, "Model")
        if hiddenNPC and hiddenNPC:FindFirstChild("HumanoidRootPart") then
            targetHRP = hiddenNPC.HumanoidRootPart
        end
    end
    
    if not targetHRP then
        print("❌ Could not find NPC:", npcName)
        return false
    end
    
    local args = {
        [1] = "target",
        [2] = targetHRP
    }
    
    pcall(function()
        LocalPlayer.startevent:FireServer(unpack(args))
        print("✅ Targeted NPC:", npcName)
        return true
    end)
    
    return false
end

-- ============ BOSS MISSION FUNCTIONS ============

-- Get all boss missions
local function getBossMissions()
    local missions = {}
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

-- Accept boss mission
local function acceptBossMission(mission)
    if not mission or not mission.Object then return false end
    
    local talkEvent = mission.Object:FindFirstChild("CLIENTTALK")
    if not talkEvent then return false end
    
    local args = {
        [1] = "accept"
    }
    
    pcall(function()
        talkEvent:FireServer(unpack(args))
        print("✅ Accepted boss mission:", mission.Name)
        return true
    end)
    
    return false
end

-- Target NPC for boss mission
local function targetBossNPC(npcName)
    local targetHRP = nil
    
    -- Try to find NPC in workspace.npc
    local npcFolder = Workspace:FindFirstChild("npc")
    if npcFolder then
        local npc = npcFolder:FindFirstChild(npcName)
        if npc and npc:FindFirstChild("HumanoidRootPart") then
            targetHRP = npc.HumanoidRootPart
        end
    end
    
    -- If not found, try getNil (hidden instances)
    if not targetHRP then
        local hiddenNPC = getNil(npcName, "Model")
        if hiddenNPC and hiddenNPC:FindFirstChild("HumanoidRootPart") then
            targetHRP = hiddenNPC.HumanoidRootPart
        end
    end
    
    if not targetHRP then
        print("❌ Could not find NPC:", npcName)
        return false
    end
    
    local args = {
        [1] = "target",
        [2] = targetHRP
    }
    
    pcall(function()
        LocalPlayer.startevent:FireServer(unpack(args))
        print("✅ Targeted NPC:", npcName)
        return true
    end)
    
    return false
end

-- Check mission list
local function checkMissions()
    pcall(function()
        local compSystem = Workspace:FindFirstChild("newcompsystem")
        if compSystem then
            local getlist = compSystem:FindFirstChild("getlist")
            if getlist then
                local result = getlist:InvokeServer()
                print("📋 Current missions:", result)
                return result
            end
        end
    end)
    return nil
end

-- ============ GRIND FUNCTIONS ============

-- Grind Normal Missions
local function grindNormal()
    print("📋 Grinding normal missions...")
    local missions = getNormalMissions()
    if #missions > 0 then
        for _, mission in ipairs(missions) do
            acceptNormalMission(mission)
            task.wait(0.5)
            
            if CONFIG.AutoTargetNPCs then
                local npcName = mission.Name
                targetNPCMission(npcName)
                task.wait(0.3)
                
                -- Also try with "npc" prefix
                if not Workspace:FindFirstChild("npc"):FindFirstChild(npcName) then
                    targetNPCMission("npc" .. npcName)
                    task.wait(0.3)
                end
            end
            
            task.wait(CONFIG.FarmDelay)
        end
    else
        print("ℹ️ No normal missions available")
    end
end

-- Grind Boss Missions
local function grindBoss()
    print("👑 Grinding boss missions...")
    local missions = getBossMissions()
    if #missions > 0 then
        for _, mission in ipairs(missions) do
            acceptBossMission(mission)
            task.wait(0.5)
            
            if CONFIG.AutoTargetNPCs then
                -- Boss missions use specific NPCs
                local bossNPCs = {
                    ["Bankai Akuma"] = "npc4",
                    ["Dio Senko"] = "npc6",
                }
                
                local npcName = bossNPCs[mission.Name]
                if npcName then
                    targetBossNPC(npcName)
                    task.wait(0.3)
                else
                    -- Try to find matching NPC
                    local npcFolder = Workspace:FindFirstChild("npc")
                    if npcFolder then
                        for _, npc in ipairs(npcFolder:GetChildren()) do
                            if npc.Name:lower():match(mission.Name:lower():sub(1, 3)) then
                                targetBossNPC(npc.Name)
                                break
                            end
                        end
                    end
                end
            end
            
            task.wait(CONFIG.FarmDelay)
        end
    else
        print("ℹ️ No boss missions available")
    end
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
        
        -- Check which modes are enabled and run them
        if CONFIG.AutoGrindNormal then
            grindNormal()
        end
        
        if CONFIG.AutoGrindBoss then
            grindBoss()
        end
        
        if CONFIG.AutoGrindBoth then
            grindNormal()
            task.wait(CONFIG.FarmDelay)
            grindBoss()
        end
        
        -- Check mission list
        checkMissions()
        
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

-- Specific Grind Mode Checkboxes
autofarmss:CreateCheckbox("📋 Auto Grind Normal", function(state)
    CONFIG.AutoGrindNormal = state
    if state then
        CONFIG.AutoGrindBoss = false
        CONFIG.AutoGrindBoth = false
    end
end)

autofarmss:CreateCheckbox("👑 Auto Grind Boss", function(state)
    CONFIG.AutoGrindBoss = state
    if state then
        CONFIG.AutoGrindNormal = false
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

autofarmss:CreateCheckbox("🎯 Auto Target NPCs", function(state)
    CONFIG.AutoTargetNPCs = state
end):SetValue(true)

autofarmss:CreateSlider("Farm Delay (seconds)", 5, 0.5, function(value)
    CONFIG.FarmDelay = value
end):SetValue(1.5)

-- Manual Controls
autofarmss:CreateButton("📋 Grind Normal Now", function()
    grindNormal()
end)

autofarmss:CreateButton("👑 Grind Boss Now", function()
    grindBoss()
end)

autofarmss:CreateButton("⭐ Grind Both Now", function()
    grindNormal()
    task.wait(CONFIG.FarmDelay)
    grindBoss()
end)

-- Scan Buttons
autofarmss:CreateButton("🔍 Scan Normal Missions", function()
    local missions = getNormalMissions()
    print("📋 Found", #missions, "normal missions")
    for _, mission in ipairs(missions) do
        print("   -", mission.Name)
    end
end)

autofarmss:CreateButton("🔍 Scan Boss Missions", function()
    local missions = getBossMissions()
    print("📋 Found", #missions, "boss missions")
    for _, mission in ipairs(missions) do
        print("   -", mission.Name)
    end
end)

autofarmss:CreateButton("📋 Check Mission List", function()
    checkMissions()
end)

-- Main Tab
main:CreateButton("📋 Grind Normal", function()
    grindNormal()
end)

main:CreateButton("👑 Grind Boss", function()
    grindBoss()
end)

main:CreateButton("⭐ Grind Both", function()
    grindNormal()
    task.wait(CONFIG.FarmDelay)
    grindBoss()
end)

main:CreateButton("🔍 Scan Everything", function()
    local normalMissions = getNormalMissions()
    print("📋 Normal Missions:", #normalMissions)
    for _, mission in ipairs(normalMissions) do
        print("   -", mission.Name)
    end
    
    local bossMissions = getBossMissions()
    print("👑 Boss Missions:", #bossMissions)
    for _, mission in ipairs(bossMissions) do
        print("   -", mission.Name)
    end
    
    checkMissions()
end)

main:CreateButton("📋 Check Mission List", function()
    checkMissions()
end)

print("✅ Shindo Life Auto Farm loaded!")
print("")
print("🔧 GRIND MODES:")
print("   - 📋 Normal: Grinds normal missions only")
print("   - 👑 Boss: Grinds boss missions only")
print("   - ⭐ Both: Grinds both normal and boss missions")
print("")
print("📌 Select ONE grind mode, then toggle Auto-Farm!")
