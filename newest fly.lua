local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-------------------------------------------------
-- PLAYER REFERENCES
-------------------------------------------------
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-------------------------------------------------
-- FLY CONSTANTS & STATE
-------------------------------------------------
local FAST_FLY_SPEED = 230
local NORMAL_FLY_SPEED = 75

local desiredFlySpeed = FAST_FLY_SPEED
local flySpeed = FAST_FLY_SPEED
local flying = false

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

-------------------------------------------------
-- FLY FUNCTIONS
-------------------------------------------------
local function startFlying()
	if flying then return end
	flying = true
	flySpeed = desiredFlySpeed

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
	bodyVelocity.Velocity = Vector3.zero
	bodyVelocity.Parent = hrp

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
	bodyGyro.CFrame = hrp.CFrame
	bodyGyro.Parent = hrp

	updateConnection = RunService.RenderStepped:Connect(function()
		if not flying then return end

		local cam = workspace.CurrentCamera
		local move = Vector3.zero

		if keysPressed.W then move += cam.CFrame.LookVector end
		if keysPressed.S then move -= cam.CFrame.LookVector end
		if keysPressed.A then move -= cam.CFrame.RightVector end
		if keysPressed.D then move += cam.CFrame.RightVector end
		if keysPressed.Space then move += Vector3.new(0, 1, 0) end
		if keysPressed.LeftControl then move -= Vector3.new(0, 1, 0) end

		if move.Magnitude > 0 then
			move = move.Unit * flySpeed
		end

		bodyVelocity.Velocity = move
		bodyGyro.CFrame = cam.CFrame
	end)
end

local function stopFlying()
	flying = false

	if updateConnection then
		updateConnection:Disconnect()
		updateConnection = nil
	end
	if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
	if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
end

-------------------------------------------------
-- INPUT HANDLING
-------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end

	-- F = toggle fly
	if input.KeyCode == Enum.KeyCode.F then
		if flying then
			stopFlying()
		else
			startFlying()
		end
	end

	-- G = toggle speed (only while flying)
	if input.KeyCode == Enum.KeyCode.G then
		if not flying then return end

		if desiredFlySpeed == FAST_FLY_SPEED then
			desiredFlySpeed = NORMAL_FLY_SPEED
		else
			desiredFlySpeed = FAST_FLY_SPEED
		end

		flySpeed = desiredFlySpeed
	end

	if keysPressed[input.KeyCode.Name] ~= nil then
		keysPressed[input.KeyCode.Name] = true
	end
end)

UserInputService.InputEnded:Connect(function(input, gp)
	if gp then return end
	if keysPressed[input.KeyCode.Name] ~= nil then
		keysPressed[input.KeyCode.Name] = false
	end
end)

-------------------------------------------------
-- RESPAWN / FULL RESET
-------------------------------------------------
player.CharacterAdded:Connect(function(char)
	-- STOP FLYING IMMEDIATELY
	stopFlying()

	-- RESET SPEED STATE
	desiredFlySpeed = FAST_FLY_SPEED
	flySpeed = FAST_FLY_SPEED

	-- RESET INPUTS
	for k in pairs(keysPressed) do
		keysPressed[k] = false
	end

	-- DESTROY LEFTOVER PHYSICS (safety)
	if updateConnection then
		updateConnection:Disconnect()
		updateConnection = nil
	end
	if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
	if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end

	-- REBIND CHARACTER
	character = char
	hrp = char:WaitForChild("HumanoidRootPart")
end)
