local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Configuration: Only spy on these specific names
local TARGET_NAMES = {
    ["RemoteEvent"] = true,
    ["SpoofEvent"] = true
}

-- Get the metatable for the game to hook __namecall
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall

-- Make the metatable writable so we can hook it
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    -- Check if the method is FireServer (sending data) and the object is a RemoteEvent
    if method == "FireServer" and self:IsA("RemoteEvent") then
        if TARGET_NAMES[self.Name] then
            -- FORMAT THE OUTPUT
            print(`\n[SPY] Detected: {self:GetFullName()}`)
            print(`[SPY] Method: {method}`)
            print(`[SPY] Argument Count: {#args}`)
            
            for i, v in ipairs(args) do
                local valueType = typeof(v)
                local valueStr = tostring(v)
                
                -- Handle Instances specifically to show their path
                if valueType == "Instance" then
                    valueStr = `Instance: {v:GetFullName()}`
                elseif valueType == "Vector3" then
                    valueStr = `Vector3: ({math.floor(v.X)}, {math.floor(v.Y)}, {math.floor(v.Z)})`
                elseif valueType == "CFrame" then
                    valueStr = `CFrame: ({math.floor(v.X)}, {math.floor(v.Y)}, {math.floor(v.Z)})`
                end
                
                print(`[SPY] Arg {i} [{valueType}]: {valueStr}`)
            end
            print("-------------------------")
            
            -- Optional: Copy to clipboard automatically
            -- setclipboard(`game:GetService("ReplicatedStorage"):FindFirstChild("{self.Name}"):FireServer(...)`)
        end
    end
    
    -- Call the original function so the game still works
    return oldNamecall(self, ...)
end)

print("[Spy] Active. Listening for 'RemoteEvent' and 'SpoofEvent'...")
print("[Spy] Perform an action in-game (catch, move, buy) to see arguments.")   