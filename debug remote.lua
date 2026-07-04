-- SIMPLE DEBUG SCRIPT - CATCH TRACKER
-- Run this and then try to catch the football

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer

print("🔍 CATCH DEBUG STARTED")
print("========================================")

------------------------------------------------
-- 1. TRACK ALL FOOTBALLS
------------------------------------------------
local trackedFootballs = {}

local function trackFootball(ball)
    if trackedFootballs[ball] then return end
    trackedFootballs[ball] = true
    
    print("⚽ Tracking:", ball:GetFullName())
    
    -- Track parent changes (this shows when caught)
    ball:GetPropertyChangedSignal("Parent"):Connect(function()
        print("🔄 FOOTBALL PARENT CHANGED!")
        print("   New Parent:", ball.Parent)
        if ball.Parent and ball.Parent:IsA("Model") then
            local player = Players:GetPlayerFromCharacter(ball.Parent)
            if player then
                print("   🎯 CAUGHT BY:", player.Name)
            end
        end
    end)
    
    -- Track position (shows movement)
    ball:GetPropertyChangedSignal("Position"):Connect(function()
        -- Only log if moved significantly
    end)
    
    -- Check for TouchTransmitter events
    for _, child in pairs(ball:GetChildren()) do
        if child:IsA("TouchTransmitter") then
            print("   📡 TouchTransmitter found on:", ball.Name)
            
            -- Try to hook the Touched event if possible
            -- TouchTransmitter doesn't have a standard Touched event directly
        end
    end
end

-- Find all existing footballs
for _, obj in pairs(Workspace:GetDescendants()) do
    if obj.Name:lower():match("football") and obj:IsA("BasePart") then
        trackFootball(obj)
    end
end

-- Track new footballs
Workspace.DescendantAdded:Connect(function(obj)
    if obj.Name:lower():match("football") and obj:IsA("BasePart") then
        trackFootball(obj)
    end
end)

------------------------------------------------
-- 2. HOOK ALL REMOTE EVENTS
------------------------------------------------
local remoteHooks = {}

local function hookRemoteEvent(remote, path)
    if remoteHooks[remote] then return end
    remoteHooks[remote] = true
    
    local original = remote.FireServer
    remote.FireServer = function(self, ...)
        local args = {...}
        print("📡 REMOTE FIRED:", path or self:GetFullName())
        print("   Args:", args)
        return original(self, unpack(args))
    end
end

-- Hook all remotes
for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") then
        hookRemoteEvent(obj, obj:GetFullName())
    end
end

for _, obj in pairs(Workspace:GetDescendants()) do
    if obj:IsA("RemoteEvent") then
        hookRemoteEvent(obj, obj:GetFullName())
    end
end

print("📡 Remote hooks installed")

------------------------------------------------
-- 3. MONITOR PLAYER TOUCH
------------------------------------------------
local character = plr.Character
if character then
    local parts = {
        character:FindFirstChild("CatchL"),
        character:FindFirstChild("CatchR"),
        character:FindFirstChild("LeftHand"),
        character:FindFirstChild("RightHand"),
        character:FindFirstChild("Left Arm"),
        character:FindFirstChild("Right Arm")
    }
    
    for _, part in pairs(parts) do
        if part and part:IsA("BasePart") then
            part.Touched:Connect(function(hit)
                if hit and hit.Name:lower():match("football") then
                    print("🖐️ PLAYER TOUCHED FOOTBALL!")
                    print("   Part:", part.Name)
                    print("   Hit:", hit.Name)
                    print("   Hit Parent:", hit.Parent)
                    print("   Position:", hit.Position)
                end
            end)
        end
    end
end

------------------------------------------------
-- 4. TRY TO CATCH (MANUAL)
------------------------------------------------
print("\n⌨️ COMMANDS:")
print("   /catch - Try to catch")
print("   /touch - Simulate touch")
print("   /find - Find footballs")

plr.Chatted:Connect(function(msg)
    if msg == "/catch" then
        print("🎯 Attempting catch...")
        
        -- Find a football
        local ball = nil
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:lower():match("football") and obj:IsA("BasePart") then
                ball = obj
                break
            end
        end
        
        if not ball then
            print("   ❌ No football found")
            return
        end
        
        print("   ⚽ Found:", ball:GetFullName())
        
        -- Try method 1: RemoteEvent on ball
        local remote = ball:FindFirstChild("RemoteEvent")
        if remote and remote:IsA("RemoteEvent") then
            print("   📡 Firing RemoteEvent...")
            remote:FireServer("PlayerActions", "Catch")
        end
        
        -- Try method 2: CharacterSoundEvent
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local cs = remotes:FindFirstChild("CharacterSoundEvent")
            if cs and cs:IsA("RemoteEvent") then
                print("   📡 Firing CharacterSoundEvent...")
                cs:FireServer("PlayerActions", "Catch")
            end
        end
        
        -- Try method 3: FireTouchInterest
        local char = plr.Character
        if char then
            local catchL = char:FindFirstChild("CatchL")
            if catchL then
                print("   🔥 Firing FireTouchInterest...")
                firetouchinterest(catchL, ball, 0)
                task.wait(0.05)
                firetouchinterest(catchL, ball, 1)
            end
        end
    end
    
    if msg == "/touch" then
        local ball = nil
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:lower():match("football") and obj:IsA("BasePart") then
                ball = obj
                break
            end
        end
        
        if ball and plr.Character then
            local catchL = plr.Character:FindFirstChild("CatchL")
            if catchL then
                print("👆 Simulating touch...")
                firetouchinterest(catchL, ball, 0)
                task.wait(0.05)
                firetouchinterest(catchL, ball, 1)
            end
        end
    end
    
    if msg == "/find" then
        print("🔍 Finding footballs...")
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:lower():match("football") and obj:IsA("BasePart") then
                print("   ✅ Found:", obj:GetFullName())
                print("      Parent:", obj.Parent)
                print("      Position:", obj.Position)
            end
        end
    end
end)

print("\n✅ Debug ready!")
print("Try catching the football normally and watch the output.")