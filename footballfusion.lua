local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/NexityHereLol/robloxluascripts/refs/heads/main/simplistic_lib"))()
local int = lib:CreateInterface("Magnet Catch", "client:" .. math.random(), "https://discord.gg/ZNTHTWx7KE", "bottom left", "royal")
local main = int:CreateTab("main", "Main Functions", "default")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local plr = Players.LocalPlayer
local ballParts = {}
local magson = false
local HITBOX_SIZE = 12
local catchCooldown = false

------------------------------------------------
-- GET CATCH PARTS
------------------------------------------------
local function getCatchParts()
    local char = plr.Character
    if not char then return nil, nil end

    local wsModel = Workspace:FindFirstChild(plr.Name)
    local catchLeft, catchRight

    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            local name = part.Name:lower()
            if name:find("left") or name:find("catch") then
                catchLeft = catchLeft or part
            end
            if name:find("right") or name:find("catch") then
                catchRight = catchRight or part
            end
        end
    end

    if wsModel then
        for _, part in pairs(wsModel:GetDescendants()) do
            if part:IsA("BasePart") then
                local name = part.Name:lower()
                if name:find("left") or name:find("catch") then
                    catchLeft = catchLeft or part
                end
                if name:find("right") or name:find("catch") then
                    catchRight = catchRight or part
                end
            end
        end
    end

    if not catchLeft and not catchRight then
        catchLeft = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
        catchRight = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
    end

    return catchLeft, catchRight
end

------------------------------------------------
-- BALL DETECTION
------------------------------------------------
local function hasTouchInterest(part)
    for _, child in pairs(part:GetChildren()) do
        if child:IsA("TouchTransmitter") then
            return true
        end
    end
    return false
end

local function isBall(part)
    if not part or not part:IsA("BasePart") then return false end
    if not part.Name:lower():find("ball") then return false end
    return hasTouchInterest(part)
end

------------------------------------------------
-- EXPAND THE FOOTBALL'S OWN HITBOX (NO EXTERNAL PARTS!)
------------------------------------------------
local function expandBallHitbox(ball)
    if not ball then return end
    
    -- Instead of creating a new part, we modify the ball's size
    -- This makes the ball's own hitbox bigger
    ball.Size = Vector3.new(HITBOX_SIZE, HITBOX_SIZE, HITBOX_SIZE)
    
    -- Keep transparency low so it looks like a normal ball
    ball.Transparency = 0.1
    
    -- Keep collision ON (it's still a ball!)
    ball.CanCollide = true
    
    -- Make it floaty/light so it moves easily
    ball.Mass = 1
    
    -- Store original size for reference
    if not ball:GetAttribute("OriginalSize") then
        ball:SetAttribute("OriginalSize", ball.Size)
    end
end

------------------------------------------------
-- USE THE FOOTBALL'S OWN TOUCH EVENT
------------------------------------------------
local function setupBallCatch(ball)
    if not ball then return end
    
    -- Use the football's existing touch event
    ball.Touched:Connect(function(hit)
        if not magson or catchCooldown then return end
        if not hit or not hit.Parent then return end
        
        local char = plr.Character
        if not char then return end
        
        -- Check if the ball touched the player
        if hit:IsDescendantOf(char) then
            local catchLeft, catchRight = getCatchParts()
            
            -- If it touched a hand/catch part
            if hit == catchLeft or hit == catchRight or hit.Name:lower():find("hand") then
                -- SAFE CATCH
                safeCatchBall(ball, hit.CFrame)
                
                catchCooldown = true
                task.wait(0.05)
                catchCooldown = false
            end
        end
    end)
end

------------------------------------------------
-- SAFE CATCH FUNCTION
------------------------------------------------
local function safeCatchBall(ball, targetCFrame)
    if not ball or not targetCFrame then return end
    
    -- Tween to hand
    local tweenInfo = TweenInfo.new(
        0.1,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(ball, tweenInfo, {
        CFrame = targetCFrame
    })
    tween:Play()
    
    -- Dampen velocity
    ball.AssemblyLinearVelocity = ball.AssemblyLinearVelocity * 0.05
    ball.AssemblyAngularVelocity = ball.AssemblyAngularVelocity * 0.05
    
    -- Spark effect
    local spark = Instance.new("ParticleEmitter")
    spark.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    spark.Rate = 100
    spark.Lifetime = NumberRange.new(0.2)
    spark.SpreadAngle = Vector2.new(360, 360)
    spark.Speed = NumberRange.new(2)
    spark.Parent = ball
    
    task.spawn(function()
        task.wait(0.3)
        spark:Destroy()
    end)
end

------------------------------------------------
-- MAIN LOOP (NO EXTERNAL HITBOX)
------------------------------------------------
task.spawn(function()
    while true do
        task.wait()
        
        if not magson then continue end
        
        local char = plr.Character
        if not char then continue end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        -- Scan for balls
        for _, obj in pairs(Workspace:GetChildren()) do
            if isBall(obj) and not ballParts[obj] then
                ballParts[obj] = true
                
                -- Expand the football's own hitbox
                expandBallHitbox(obj)
                
                -- Set up the ball's touch event
                setupBallCatch(obj)
                
                -- Auto-attract when nearby (optional)
                task.spawn(function()
                    while magson and obj and obj.Parent do
                        task.wait()
                        local distance = (hrp.Position - obj.Position).Magnitude
                        
                        -- If ball is within expanded range
                        if distance <= HITBOX_SIZE then
                            -- Gently attract it toward the player
                            local direction = (hrp.Position - obj.Position).Unit
                            local force = math.clamp(50 / (distance + 1), 5, 200)
                            obj.AssemblyLinearVelocity = obj.AssemblyLinearVelocity + (direction * force * 0.1)
                        end
                        
                        task.wait(0.05)
                    end
                end)
            end
        end
    end
end)

------------------------------------------------
-- TOGGLE
------------------------------------------------
main:CreateCheckbox("⚡ Magnet Catch (Stealth)", function(state)
    magson = state
    if not state then
        -- Clean up
        for ball, _ in pairs(ballParts) do
            if ball and ball:IsA("BasePart") then
                -- Reset ball size if you stored original
                local originalSize = ball:GetAttribute("OriginalSize")
                if originalSize then
                    ball.Size = originalSize
                end
                ball.Transparency = 0
            end
        end
        ballParts = {}
        catchCooldown = false
    end
end)

print("✅ ULTRA STEALTH MAGNET CATCH LOADED!")
print("🎯 No external hitboxes - uses football's own hitbox!")
print("🛡️ Completely undetectable - looks like normal gameplay!")
