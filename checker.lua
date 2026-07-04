-- ======================
-- SERVICES
-- ======================
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlaceId = 606849621 -- your place id

-- ======================
-- TARGET MESSAGES (BRACKET)
-- ======================
local TARGET_MESSAGES = {
    "hacker",
    "report",
    "exploiter"
}

-- ======================
-- GUI SETUP
-- ======================
local gui = Instance.new("ScreenGui")
gui.Name = "ChatWatcherGui"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(0.35, 0.15)
frame.Position = UDim2.fromScale(0.33, 0.4)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local text = Instance.new("TextLabel")
text.Size = UDim2.fromScale(1, 1)
text.BackgroundTransparency = 1
text.TextWrapped = true
text.TextScaled = true
text.Font = Enum.Font.GothamBold
text.TextColor3 = Color3.fromRGB(255, 255, 255)
text.Text = "Waiting until message is said..."
text.Parent = frame

-- ======================
-- MESSAGE CHECK FUNCTION
-- ======================
local function isTargetMessage(msg)
    msg = string.lower(msg)

    for _, target in ipairs(TARGET_MESSAGES) do
        if msg == target then
            return true
        end
    end

    return false
end

-- ======================
-- SERVER FETCH
-- ======================
local function getServers()
    local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"

    local success, result = pcall(function()
        return game:HttpGet(url)
    end)

    if success then
        return HttpService:JSONDecode(result)
    end
end

-- ======================
-- BIG SERVER HOP
-- ======================
local function hopToBigServer()
    local data = getServers()
    if not data then
        text.Text = "Failed to fetch servers."
        return
    end

    local servers = {}
    for _, server in pairs(data.data) do
        if server.playing > 8 then
            table.insert(servers, server.id)
        end
    end

    if #servers > 0 then
        local chosen = servers[math.random(#servers)]
        TeleportService:TeleportToPlaceInstance(PlaceId, chosen, LocalPlayer)
    else
        text.Text = "No big servers found."
    end
end

-- ======================
-- CHAT LISTENER
-- ======================
local function hookPlayer(player)
    player.Chatted:Connect(function(message)
        if isTargetMessage(message) then
            text.Text = "Message detected (" .. message .. ")! Server hopping..."
            task.wait(1)
            hopToBigServer()
        end
    end)
end

-- Existing players
for _, player in ipairs(Players:GetPlayers()) do
    hookPlayer(player)
end

-- New players
Players.PlayerAdded:Connect(hookPlayer)
