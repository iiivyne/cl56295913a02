
local lib = {}

--setting up the UI LIB

function lib:CreateInterface(name, alignment)

	print('simple lib: lib loaded')
	print('simple lib: loaded tabpages')
	print('simple lib: loaded tabitems')
	print('simple lib: loaded contents')
	print('simple lib: loaded script functionality')
	print('simple lib: loaded script -> ' .. tostring(name))
	print('simple lib: alignment -> ' .. tostring(alignment))
	--print('simple lib: user -> ' .. tostring(game.Players.LocalPlayer))
	print('simple lib: version: 0.0.1')

	-- ScreenGui and topbar
	local client = Instance.new("ScreenGui")
	local topbar = Instance.new("Frame")
	local ui_title = Instance.new("TextLabel")
	local minimize = Instance.new("ImageButton")
	local img_minimize = Instance.new("ImageLabel")
	local holder = Instance.new("Frame")
	local navigation = Instance.new("Frame")

	-- Setup ScreenGui
	--client.Name = "client"
	--client.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	--client.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	--client.IgnoreGuiInset = false
	--client.ResetOnSpawn = false

	--local client = Instance.new("ScreenGui")
	client.Name = "client"
	--client.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	client.ZIndexBehavior = Enum.ZIndexBehavior.Global
	client.IgnoreGuiInset = false
	client.ResetOnSpawn = false
	
	-- Parent to CoreGui
	client.Parent = game:GetService("CoreGui")
	
	-- Setup Topbar
	topbar.Name = "topbar"
	topbar.Parent = client
	topbar.BackgroundColor3 = Color3.new(0.0588235, 0.0588235, 0.0588235)
	topbar.BorderColor3 = Color3.new(0, 0, 0)
	topbar.BorderSizePixel = 0
	topbar.Size = UDim2.new(0, 498, 0, 41)

	holder.Name = "holder"
	holder.Parent = topbar
	holder.AnchorPoint = Vector2.new(0.5, 0)
	holder.BackgroundColor3 = Color3.new(0.0980392, 0.0980392, 0.0980392)
	holder.BorderColor3 = Color3.new(0.0117647, 0.113725, 0.478431)
	holder.BorderSizePixel = 0
	holder.Position = UDim2.new(0.5, 0, 1, 0)  -- positioned at bottom edge of topbar
	holder.Size = UDim2.new(0, 498, 0, 255)

	-- You can change alignment here: "bottom left", "bottom right", "center", "mid left", "mid right" -- example alignment
	local margin = 10

	if alignment == "bottom left" then
		topbar.AnchorPoint = Vector2.new(0, 1)
		topbar.Position = UDim2.new(0, margin, 1, -margin)
	elseif alignment == "bottom right" then
		topbar.AnchorPoint = Vector2.new(1, 1)
		topbar.Position = UDim2.new(1, -margin, 1, -margin)
	elseif alignment == "center" then
		topbar.AnchorPoint = Vector2.new(0.5, 0.5)
		topbar.Position = UDim2.new(0.5, 0, 0.5, 0)
	elseif alignment == "mid left" or alignment == "middle left" then
		topbar.AnchorPoint = Vector2.new(0, 0.5)
		topbar.Position = UDim2.new(0, margin, 0.5, 0)
	elseif alignment == "mid right" or alignment == "middle right" then
		topbar.AnchorPoint = Vector2.new(1, 0.5)
		topbar.Position = UDim2.new(1, -margin, 0.5, 0)
	else
		-- Default fallback (center)
		topbar.AnchorPoint = Vector2.new(0.5, 0.5)
		topbar.Position = UDim2.new(0.5, 0, 0.5, 0)
	end
	
	navigation.Name = "navigation"
	navigation.Parent = holder
	navigation.BackgroundColor3 = Color3.new(0.141176, 0.141176, 0.141176)
	navigation.BackgroundTransparency = 1
	navigation.BorderSizePixel = 0
	navigation.Position = UDim2.new(0.016, 0, 0.032, 0)
	navigation.Size = UDim2.new(0, 133, 0, 240)
	
	ui_title.Name = "ui_title"
	ui_title.Parent = topbar
	ui_title.BackgroundColor3 = Color3.new(1, 1, 1)
	ui_title.BackgroundTransparency = 1
	ui_title.BorderColor3 = Color3.new(0, 0, 0)
	ui_title.BorderSizePixel = 0
	ui_title.Position = UDim2.new(0.0160868615, 0, 0.346637249, 0)
	ui_title.Size = UDim2.new(0, 33, 0, 14)
	ui_title.Font = Enum.Font.GothamBold
	ui_title.Text = name or "interface"
	ui_title.TextColor3 = Color3.new(1, 1, 1)
	ui_title.TextSize = 14
	ui_title.TextXAlignment = Enum.TextXAlignment.Left

	minimize.Name = "minimize"
	minimize.Parent = topbar
	minimize.BackgroundColor3 = Color3.new(1, 1, 1)
	minimize.BackgroundTransparency = 1
	minimize.BorderColor3 = Color3.new(0, 0, 0)
	minimize.BorderSizePixel = 0
	minimize.Position = UDim2.new(0.920712054, 0, 0, 0)
	minimize.Size = UDim2.new(0, 39, 0, 41)

	img_minimize.Name = "img_minimize"
	img_minimize.Parent = minimize
	img_minimize.BackgroundColor3 = Color3.new(1, 1, 1)
	img_minimize.BackgroundTransparency = 1
	img_minimize.BorderColor3 = Color3.new(0, 0, 0)
	img_minimize.BorderSizePixel = 0
	img_minimize.Position = UDim2.new(0.319658339, 0, 0.248707846, 0)
	img_minimize.Size = UDim2.new(0, 17, 0, 19)
	img_minimize.Image = "rbxassetid://99115006296555"

	-- ScreenGui and topbar


	local holderUICorner = Instance.new("UICorner")

	local function createShadow(name)
		local Shadow = Instance.new("ImageLabel")
		Shadow.Name = name
		Shadow.Parent = holder
		Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
		Shadow.BackgroundColor3 = Color3.new(1, 1, 1)
		Shadow.BackgroundTransparency = 1
		Shadow.BorderColor3 = Color3.new(0, 0, 0)
		Shadow.BorderSizePixel = 0
		Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
		Shadow.Size = UDim2.new(1, 50, 1, 50)
		Shadow.ZIndex = -9999
		Shadow.Image = "rbxassetid://186491278"
		Shadow.ImageTransparency = 0.6
		Shadow.ScaleType = Enum.ScaleType.Slice
		Shadow.SliceCenter = Rect.new(48, 48, 48, 48)
		return Shadow
	end

	-- Create the original Shadow
	--createShadow("Shadow")

	--for i = 1,4 do
	--	createShadow("Shadow"..i)
	--end

	
	holderUICorner.Parent = holder
	holderUICorner.CornerRadius = UDim.new(0, 0)
	
	
	--interface hiding
			-- Define off-screen position (left of the viewport)
			local offScreenPosition = UDim2.new(-0.5, 0, 0.5, 0)  -- Move completely off the left side of the screen
			local uis = game:GetService("UserInputService")
			local TweenService = game:GetService("TweenService")
			-- Tween information
			local tweenTime = 0.5  -- Time in seconds for the animation
			local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

			-- Variables to track positions and tween progress
	local originalPosition = topbar.Position
			local lastPosition = originalPosition  -- Start with the initial position
			local tweenInProgress = false  -- Track if a tween is currently playing
			local isVisible = true  -- Initially visible

			-- Create tweens for position transitions
			local moveInTween = TweenService:Create(topbar, tweenInfo, {Position = lastPosition})
		local moveOutTween = TweenService:Create(topbar, tweenInfo, {Position = offScreenPosition})

			-- Function to toggle visibility with position transition
			local function toggleVisibility()
				if tweenInProgress then
					return  -- Exit if a tween is already in progress
				end

				tweenInProgress = true

				if isVisible then
					-- Move out of the screen to the left and save the current position
					lastPosition = topbar.Position
					moveOutTween:Play()
					moveOutTween.Completed:Connect(function()
						topbar.Visible = false
						tweenInProgress = false
					end)
				else
					-- Make visible and move in from the last position
					topbar.Visible = true
					moveInTween = TweenService:Create(topbar, tweenInfo, {Position = lastPosition})
					moveInTween:Play()
					moveInTween.Completed:Connect(function()
						tweenInProgress = false
					end)
				end
				isVisible = not isVisible
			end

			-- Connect input event
			uis.InputBegan:Connect(function(key, chat)
				if key.KeyCode == Enum.KeyCode.RightControl then
					toggleVisibility()
				end
			end)
	--interface hiding
	
	--Holder ends here (pastable)
	
	
	--Navigation starts here

	--DragScript

	local UIS = game:GetService("UserInputService")
	local frame = topbar
	local dragToggle = nil
	local dragSpeed = 0.25 -- the amount of speed you want the drag to be
	local dragStart = nil
	local startPos = nil

	local function updateInput(input)
		local delta = input.Position - dragStart
		local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		game:GetService('TweenService'):Create(frame, TweenInfo.new(dragSpeed), {Position = position}):Play()
	end

	frame.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
			dragToggle = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragToggle = false
				end
			end)
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if dragToggle then
				updateInput(input)
			end
		end
	end)

	--DragScript
	
	minimize.MouseButton1Click:Connect(function()
		print('simple lib: destroyed client')
		wait(0.01)
		client:Destroy()
	end)
	
	minimize.MouseEnter:Connect(function()
		TweenService:Create(img_minimize, TweenInfo.new(0.15), {ImageTransparency = 0.5}):Play()
	end)

	minimize.MouseLeave:Connect(function()
		TweenService:Create(img_minimize, TweenInfo.new(0.15), {ImageTransparency = 0}):Play()
	end)

	
	local TweenService = game:GetService("TweenService")
	local createtab = {}

	local tabButtons = {}
	local tabContents = {}
	local currentTabButton = nil

	local ContentHolder = topbar  -- where the tab pages go

	-- Create the scrolling frame container for tabs (tabholder)
	local tabholder = Instance.new("ScrollingFrame")
	local UIPadding = Instance.new("UIPadding")
	local UIListLayout = Instance.new("UIListLayout")

	tabholder.Name = "tabholder"
	tabholder.Parent = navigation
	tabholder.Active = true
	tabholder.BackgroundColor3 = Color3.new(1, 1, 1)
	tabholder.BackgroundTransparency = 1
	tabholder.BorderColor3 = Color3.new(0, 0, 0)
	tabholder.BorderSizePixel = 0
	tabholder.Size = UDim2.new(0, 132, 0, 238)
	tabholder.ScrollBarThickness = 0

	UIPadding.Parent = tabholder

	UIListLayout.Parent = tabholder
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 6)

	local UIPadding = Instance.new("UIPadding")
	UIPadding.PaddingTop = UDim.new(0, 6)
	UIPadding.PaddingBottom = UDim.new(0, 6)
	UIPadding.PaddingLeft = UDim.new(0, 6)
	UIPadding.PaddingRight = UDim.new(0, 6)
	UIPadding.Parent = tabholder

	-- CreateTab function
	function createtab:CreateTab(tabname, isDefault)
		local tabButton = Instance.new("ImageButton")
		tabButton.Name = tabname
		tabButton.Size = UDim2.new(0, 133, 0, 38)
		tabButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		tabButton.BackgroundTransparency = 1
		tabButton.AutoButtonColor = false
		tabButton.Parent = tabholder
		tabButton:SetAttribute("PageName", tabname)

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 0)
		corner.Parent = tabButton

		local visi_bar = Instance.new("Frame")
		visi_bar.Name = "visi_bar"
		visi_bar.Size = UDim2.new(0, 6, 0, 26)
		visi_bar.Position = UDim2.new(0.058, 0, 0.158, 0)
		visi_bar.BackgroundColor3 = Color3.new(1, 1, 1)
		visi_bar.BackgroundTransparency = 1
		visi_bar.BorderSizePixel = 0
		visi_bar.Parent = tabButton
		Instance.new("UICorner", visi_bar).CornerRadius = UDim.new(0, 2)

		local label = Instance.new("TextLabel")
		label.Name = "tab_label"
		label.Size = UDim2.new(0, 63, 0, 12)
		label.Position = UDim2.new(0.162, 0, 0.336, 0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(136, 136, 136)
		label.Text = tabname
		label.Font = Enum.Font.GothamBold
		label.TextSize = 14
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = tabButton

		local shadow = Instance.new("ImageLabel")
		shadow.Name = "Shadow"
		shadow.AnchorPoint = Vector2.new(0.5, 0.5)
		shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
		shadow.Size = UDim2.new(0.624, 50, 1, 50)
		shadow.BackgroundTransparency = 1
		shadow.ImageTransparency = 1
		shadow.Image = "rbxassetid://186491278"
		shadow.ScaleType = Enum.ScaleType.Slice
		shadow.SliceCenter = Rect.new(48, 48, 48, 48)
		shadow.ZIndex = -9999
		shadow.Parent = tabButton

		tabButton.MouseEnter:Connect(function()
			if currentTabButton ~= tabButton then
				TweenService:Create(label, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
				TweenService:Create(visi_bar, TweenInfo.new(0.15), {BackgroundTransparency = 0.25}):Play()
			end
		end)

		tabButton.MouseLeave:Connect(function()
			if currentTabButton ~= tabButton then
				TweenService:Create(label, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(136, 136, 136)}):Play()
				TweenService:Create(visi_bar, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
			end
		end)

		local tabPage = Instance.new("ScrollingFrame")
		tabPage.Name = "tabpage"
		tabPage.Parent = holder
		tabPage.Active = true
		tabPage.BackgroundColor3 = Color3.new(1, 1, 1)
		tabPage.BackgroundTransparency = 1
		tabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
		tabPage.BorderColor3 = Color3.new(0, 0, 0)
		tabPage.BorderSizePixel = 0
		tabPage.Position = UDim2.new(0.332665384, 0, 0.0320093483, 0)
		tabPage.Size = UDim2.new(0, 327, 0, 240)
		tabPage.BottomImage = ""
		tabPage.Visible = false
		tabPage.ScrollBarThickness = 5
		tabPage.TopImage = ""

		local tabtitleframe = Instance.new("Frame")
		tabtitleframe.Name = "tabtitleframe"
		tabtitleframe.Size = UDim2.new(0, 314, 0, 37)
		tabtitleframe.BackgroundTransparency = 1
		tabtitleframe.BorderSizePixel = 0
		tabtitleframe.Parent = tabPage

		local tabpagetitle = Instance.new("TextLabel")
		tabpagetitle.Name = "tabpagetitle"
		tabpagetitle.Position = UDim2.new(0.028, 0, 0.32, 0)
		tabpagetitle.Size = UDim2.new(0, 31, 0, 14)
		tabpagetitle.BackgroundTransparency = 1
		tabpagetitle.Text = tabname
		tabpagetitle.Font = Enum.Font.GothamBold
		tabpagetitle.TextColor3 = Color3.new(1, 1, 1)
		tabpagetitle.TextSize = 14
		tabpagetitle.TextXAlignment = Enum.TextXAlignment.Left
		tabpagetitle.Parent = tabtitleframe

		local UIListLayoutPage = Instance.new("UIListLayout")
		UIListLayoutPage.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayoutPage.Padding = UDim.new(0, 7)
		UIListLayoutPage.Parent = tabPage

		local function updateScrollbar()
			local contentHeight = UIListLayoutPage.AbsoluteContentSize.Y
			local frameHeight = tabPage.AbsoluteSize.Y

			if contentHeight > frameHeight then
				tabPage.ScrollBarImageTransparency = 0
				tabPage.ScrollBarThickness = 5
			else
				tabPage.ScrollBarImageTransparency = 1
				tabPage.ScrollBarThickness = 0
				tabPage.CanvasPosition = Vector2.new(0, 0)
			end
		end

		UIListLayoutPage:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScrollbar)
		tabPage:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateScrollbar)
		updateScrollbar()

		tabContents[tabname] = tabPage
		tabButtons[tabname] = tabButton

		local function selectTab()
			if currentTabButton == tabButton then return end

			if currentTabButton then
				local oldPage = tabContents[currentTabButton:GetAttribute("PageName")]
				if oldPage then oldPage.Visible = false end

				TweenService:Create(currentTabButton, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()

				local oldLabel = currentTabButton:FindFirstChild("tab_label")
				local oldBar = currentTabButton:FindFirstChild("visi_bar")
				local oldShadow = currentTabButton:FindFirstChild("Shadow")

				if oldLabel then
					TweenService:Create(oldLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(136, 136, 136)}):Play()
				end
				if oldBar then
					TweenService:Create(oldBar, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
				end
				if oldShadow then
					--TweenService:Create(oldShadow, TweenInfo.new(0.25), {ImageTransparency = 1}):Play()
				end
			end

			TweenService:Create(tabButton, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
			TweenService:Create(label, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			TweenService:Create(visi_bar, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
			--TweenService:Create(shadow, TweenInfo.new(0.25), {ImageTransparency = 0.6}):Play()

			tabPage.Visible = true
			currentTabButton = tabButton
		end

		tabButton.MouseButton1Click:Connect(selectTab)

		if isDefault then
			selectTab()
		end

		-- Element container
		local innertab = {}
		innertab._tabPage = tabPage

		function innertab:CreateSlider(slidertitle, maxValue, minValue, callback)
			local slider = Instance.new("Frame")
			local slidernametitle = Instance.new("TextLabel")
			local sliderframe = Instance.new("Frame")
			local actualslider = Instance.new("Frame")
			local slidervalue = Instance.new("TextLabel")

			slider.Name = "slider"
			slider.Parent = tabPage
			slider.BackgroundColor3 = Color3.new(0.0588235, 0.0588235, 0.0588235)
			slider.BorderColor3 = Color3.new(0, 0, 0)
			slider.BorderSizePixel = 0
			slider.Position = UDim2.new(0, 0, 0.529166639, 0)
			slider.Size = UDim2.new(0, 314, 0, 55)

			slidernametitle.Name = "slidernametitle"
			slidernametitle.Parent = slider
			slidernametitle.BackgroundColor3 = Color3.new(1, 1, 1)
			slidernametitle.BackgroundTransparency = 1
			slidernametitle.BorderColor3 = Color3.new(0, 0, 0)
			slidernametitle.BorderSizePixel = 0
			slidernametitle.Position = UDim2.new(0.0280940551, 0, 0.137791857, 0)
			slidernametitle.Size = UDim2.new(0, 31, 0, 14)
			slidernametitle.Font = Enum.Font.GothamBold
			slidernametitle.Text = slidertitle or "slider"
			slidernametitle.TextColor3 = Color3.new(1, 1, 1)
			slidernametitle.TextSize = 14
			slidernametitle.TextXAlignment = Enum.TextXAlignment.Left

			sliderframe.Name = "sliderframe"
			sliderframe.Parent = slider
			sliderframe.BackgroundColor3 = Color3.fromRGB(35,35,35)
			sliderframe.BorderColor3 = Color3.new(0, 0, 0)
			sliderframe.BorderSizePixel = 0
			sliderframe.Position = UDim2.new(0.0573248416, 0, 0.637054443, 0)
			sliderframe.Size = UDim2.new(0, 275, 0, 8)

			actualslider.Name = "actualslider"
			actualslider.Parent = sliderframe
			actualslider.BackgroundColor3 = Color3.new(1, 1, 1)
			actualslider.BorderColor3 = Color3.new(0, 0, 0)
			actualslider.BorderSizePixel = 0
			actualslider.Size = UDim2.new(0, 10, 0, 8)

			slidervalue.Name = "slidervalue"
			slidervalue.Parent = slider
			slidervalue.BackgroundColor3 = Color3.new(1, 1, 1)
			slidervalue.BackgroundTransparency = 1
			slidervalue.BorderColor3 = Color3.new(0, 0, 0)
			slidervalue.BorderSizePixel = 0
			slidervalue.Position = UDim2.new(0.902660608, 0, 0.137791857, 0)
			slidervalue.Size = UDim2.new(0, 22, 0, 14)
			slidervalue.Font = Enum.Font.GothamBold
			slidervalue.Text = "0"
			slidervalue.TextColor3 = Color3.new(1, 1, 1)
			slidervalue.TextSize = 14

			local UIS = game:GetService("UserInputService")
			local dragging = false

			local TweenService = game:GetService("TweenService")

			local function updateSlider(xPos)
				local absPos = sliderframe.AbsolutePosition.X
				local absSize = sliderframe.AbsoluteSize.X
				local relative = math.clamp((xPos - absPos) / absSize, 0, 1)
				local value = math.floor((relative * (maxValue - minValue)) + minValue)

				-- Tween the size instead of setting it directly
				local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				local goal = {Size = UDim2.new(relative, 0, 1, 0)}
				TweenService:Create(actualslider, tweenInfo, goal):Play()

				slidervalue.Text = tostring(value)

				if callback then
					callback(value)
				end
			end

			sliderframe.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					updateSlider(input.Position.X)
				end
			end)

			UIS.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)

			UIS.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					updateSlider(input.Position.X)
				end
			end)

			return self
		end


		function innertab:CreateButton(name, callback)
			local button = Instance.new("ImageButton")
			local UICorner = Instance.new("UICorner")
			local buttonlabelname = Instance.new("TextLabel")
			local click = Instance.new("ImageLabel")

			button.Name = "button"
			button.Parent = tabPage
			button.BackgroundColor3 = Color3.new(0.0588235, 0.0588235, 0.0588235)
			button.BorderColor3 = Color3.new(0, 0, 0)
			button.BorderSizePixel = 0
			button.Position = UDim2.new(0, 0, 0.165354326, 0)
			button.Size = UDim2.new(0, 314, 0, 38)
			button.AutoButtonColor = false

			UICorner.Parent = button
			UICorner.CornerRadius = UDim.new(0, 0)

			buttonlabelname.Name = "buttonlabelname"
			buttonlabelname.Parent = button
			buttonlabelname.BackgroundColor3 = Color3.new(1, 1, 1)
			buttonlabelname.BackgroundTransparency = 1
			buttonlabelname.BorderColor3 = Color3.new(0, 0, 0)
			buttonlabelname.BorderSizePixel = 0
			buttonlabelname.Position = UDim2.new(0.0251041092, 0, 0.371319413, 0)
			buttonlabelname.Size = UDim2.new(0, 63, 0, 9)
			buttonlabelname.Font = Enum.Font.GothamBold
			buttonlabelname.Text = name or "button"
			buttonlabelname.TextColor3 = Color3.new(1, 1, 1)
			buttonlabelname.TextSize = 14
			buttonlabelname.TextXAlignment = Enum.TextXAlignment.Left

			click.Name = "click"
			click.Parent = button
			click.BackgroundColor3 = Color3.new(1, 1, 1)
			click.BackgroundTransparency = 1
			click.BorderColor3 = Color3.new(0, 0, 0)
			click.BorderSizePixel = 0
			click.Position = UDim2.new(0.905844927, 0, 0.239740476, 0)
			click.Size = UDim2.new(0, 22, 0, 21)
			click.Image = "rbxassetid://119676416425308"

			button.MouseButton1Click:Connect(function()
				if callback then
					pcall(callback)
				end
			end)
			
			button.MouseEnter:Connect(function()
				TweenService:Create(button, TweenInfo.new(0.15), {BackgroundTransparency = 0.5}):Play()
			end)

			button.MouseLeave:Connect(function()
				TweenService:Create(button, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
			end)

			return self
		end

		function innertab:CreateDropDown(name)
			local dropdown = Instance.new("Frame")
			dropdown.Name = "dropdown"
			dropdown.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
			dropdown.BorderColor3 = Color3.new(0.0588235, 0.0588235, 0.0588235)
			dropdown.ClipsDescendants = true
			dropdown.Size = UDim2.new(0, 314, 0, 35) -- closed size
			dropdown.BorderSizePixel = 1
			dropdown.BorderMode = Enum.BorderMode.Inset
			dropdown.Position = UDim2.new(0, 0, 0.53, 0)
			dropdown.Parent = tabPage

			local dropdown_title = Instance.new("TextLabel")
			dropdown_title.Name = "dropdown_title"
			dropdown_title.Parent = dropdown
			dropdown_title.BackgroundTransparency = 1
			dropdown_title.Position = UDim2.new(0, 7, 0, 11)
			dropdown_title.Size = UDim2.new(0, 150, 0, 14)
			dropdown_title.Font = Enum.Font.GothamBold
			dropdown_title.Text = name or "Dropdown"
			dropdown_title.TextColor3 = Color3.new(1, 1, 1)
			dropdown_title.TextSize = 14
			dropdown_title.TextXAlignment = Enum.TextXAlignment.Left

			local dropdowntoggler = Instance.new("ImageButton")
			dropdowntoggler.Name = "dropdowntoggler"
			dropdowntoggler.Parent = dropdown
			dropdowntoggler.BackgroundTransparency = 1
			dropdowntoggler.Position = UDim2.new(1, -25, 0, 7)
			dropdowntoggler.Size = UDim2.new(0, 21, 0, 21)
			dropdowntoggler.Image = "rbxassetid://127330890338186"
			dropdowntoggler.AutoButtonColor = false

			local contentholder = Instance.new("ScrollingFrame")
			contentholder.Name = "contentholder"
			contentholder.Parent = dropdown
			contentholder.Active = true
			contentholder.BackgroundTransparency = 1
			contentholder.BorderSizePixel = 0
			contentholder.Position = UDim2.new(0, 10, 0, 37)
			contentholder.Size = UDim2.new(0, 297, 0, 0)  -- start closed (height 0)
			contentholder.BottomImage = ""  
			contentholder.TopImage = ""     
			contentholder.ScrollBarThickness = 7
			contentholder.ScrollBarImageColor3 = Color3.fromRGB(180, 180, 180)
			contentholder.ClipsDescendants = true
			contentholder.ScrollingEnabled = true
			contentholder.AutomaticCanvasSize = Enum.AutomaticSize.Y  -- Auto canvas size based on content

			-- Important: Add a UIListLayout inside the contentholder to layout children vertically and get accurate AbsoluteContentSize
			local UIListLayout = Instance.new("UIListLayout")
			UIListLayout.Parent = contentholder
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout.Padding = UDim.new(0, 2)

			-- Optional: Listen for content size changes to update scrollbar or dropdown size if needed
			UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				-- You can trigger a dropdown size update here if needed
			end)


			local TweenService = game:GetService("TweenService")

			local opened = false
			local baseHeight = 35
			local maxDropdownHeight = 150

			local function tweenRotation(guiObject, targetRotation, duration)
				local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = TweenService:Create(guiObject, tweenInfo, {Rotation = targetRotation})
				tween:Play()
				return tween
			end

			local function updateDropdownSize()
				if opened then
					local contentHeight = UIListLayout.AbsoluteContentSize.Y
					local fudge = 1  -- small tweak to fix off-by-one pixel
					local newHeight = math.min(contentHeight + fudge, maxDropdownHeight)

					local dropdownNewHeight = baseHeight + newHeight

					-- Tween dropdown to new height
					dropdown:TweenSize(UDim2.new(0, 314, 0, dropdownNewHeight + 8), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)

					-- Tween contentholder to slightly smaller height (exact height of content + fudge)
					contentholder:TweenSize(UDim2.new(0, 297, 0, newHeight), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)

					-- CanvasSize must be the actual content height without fudge for scrolling correctness
					contentholder.CanvasSize = UDim2.new(0, 0, 0, contentHeight)

					tweenRotation(dropdowntoggler, -90, 0.3)
				else
					contentholder:TweenSize(UDim2.new(0, 297, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
					dropdown:TweenSize(UDim2.new(0, 314, 0, baseHeight), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
					tweenRotation(dropdowntoggler, 0, 0.3)
				end
			end



			dropdowntoggler.MouseButton1Click:Connect(function()
				opened = not opened
				updateDropdownSize()
			end)

			-- expose method to add buttons
			local dropdownAPI = {}

			function dropdownAPI:AddButton(name, callback)
				local dropdownbtn = Instance.new("ImageButton")
				local UICorner = Instance.new("UICorner")
				local buttonlabelname = Instance.new("TextLabel")
				local click = Instance.new("ImageLabel")

				dropdownbtn.Name = "dropdownbtn"
				dropdownbtn.Parent = contentholder
				dropdownbtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
				dropdownbtn.BorderSizePixel = 0
				dropdownbtn.Size = UDim2.new(0, 285, 0, 26)
				dropdownbtn.AutoButtonColor = false
				dropdownbtn.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
				dropdownbtn.ImageTransparency = 1

				UICorner.Parent = dropdownbtn
				UICorner.CornerRadius = UDim.new(0, 0)

				buttonlabelname.Name = "buttonlabelname"
				buttonlabelname.Parent = dropdownbtn
				buttonlabelname.BackgroundColor3 = Color3.new(1, 1, 1)
				buttonlabelname.BackgroundTransparency = 1
				buttonlabelname.BorderSizePixel = 0
				buttonlabelname.Position = UDim2.new(0.03, 0, 0.2, 0)
				buttonlabelname.Size = UDim2.new(0, 150, 0, 20)
				buttonlabelname.Font = Enum.Font.GothamBold
				buttonlabelname.Text = name or "Button"
				buttonlabelname.TextColor3 = Color3.new(1, 1, 1)
				buttonlabelname.TextSize = 14
				buttonlabelname.TextXAlignment = Enum.TextXAlignment.Left

				click.Name = "click"
				click.Parent = dropdownbtn
				click.BackgroundTransparency = 1
				click.BorderSizePixel = 0
				click.Position = UDim2.new(0.905, 0, 0.2, 0)
				click.Size = UDim2.new(0, 22, 0, 21)
				click.Image = "rbxassetid://119676416425308"

				dropdownbtn.MouseButton1Click:Connect(function()
					if callback then
						pcall(callback)
					end
				end)

				dropdownbtn.MouseEnter:Connect(function()
					TweenService:Create(dropdownbtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.5}):Play()
				end)

				dropdownbtn.MouseLeave:Connect(function()
					TweenService:Create(dropdownbtn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
				end)

				return dropdownbtn
			end

			return dropdownAPI
		end



		function innertab:CreateLabel(name)
			
			local tabtitleframe = Instance.new("Frame")
			local tabpagetitle = Instance.new("TextLabel")

			-- Properties

			tabtitleframe.Name = "tabtitleframe"
			tabtitleframe.Parent = tabPage
			tabtitleframe.BackgroundColor3 = Color3.fromRGB(25,25,25)
			tabtitleframe.BackgroundTransparency = 0
			tabtitleframe.BorderColor3 = Color3.new(0, 0, 0)
			tabtitleframe.BorderSizePixel = 0
			tabtitleframe.Size = UDim2.new(0, 314, 0, 37)

			tabpagetitle.Name = "tabpagetitle"
			tabpagetitle.Parent = tabtitleframe
			tabpagetitle.BackgroundColor3 = Color3.new(1, 1, 1)
			tabpagetitle.BackgroundTransparency = 1
			tabpagetitle.BorderColor3 = Color3.new(0, 0, 0)
			tabpagetitle.BorderSizePixel = 0
			tabpagetitle.Position = UDim2.new(0.0280940551, 0, 0.319610178, 0)
			tabpagetitle.Size = UDim2.new(0, 31, 0, 14)
			tabpagetitle.Font = Enum.Font.GothamBold
			tabpagetitle.Text = name or "tab_title"
			tabpagetitle.TextColor3 = Color3.new(1, 1, 1)
			tabpagetitle.TextSize = 14
			tabpagetitle.TextXAlignment = Enum.TextXAlignment.Left
			
			return self
		end

		function innertab:CreateCheckBox(name, callback)
			
			local checkbox = Instance.new("Frame")
			local tabpagetitle = Instance.new("TextLabel")
			local checkhandler = Instance.new("ImageButton")
			local UICorner = Instance.new("UICorner")

			checkbox.Name = "checkbox"
			checkbox.Parent = tabPage
			checkbox.BackgroundColor3 = Color3.fromRGB(15,15,15)
			checkbox.BorderColor3 = Color3.new(0, 0, 0)
			checkbox.BorderSizePixel = 0
			checkbox.Size = UDim2.new(0, 314, 0, 37)

			tabpagetitle.Name = "tabpagetitle"
			tabpagetitle.Parent = checkbox
			tabpagetitle.BackgroundColor3 = Color3.new(1, 1, 1)
			tabpagetitle.BackgroundTransparency = 1
			tabpagetitle.BorderColor3 = Color3.new(0, 0, 0)
			tabpagetitle.BorderSizePixel = 0
			tabpagetitle.Position = UDim2.new(0.0280940551, 0, 0.319610178, 0)
			tabpagetitle.Size = UDim2.new(0, 31, 0, 14)
			tabpagetitle.Font = Enum.Font.GothamBold
			tabpagetitle.Text = name or "checkbox"
			tabpagetitle.TextColor3 = Color3.new(1, 1, 1)
			tabpagetitle.TextSize = 14
			tabpagetitle.TextXAlignment = Enum.TextXAlignment.Left

			checkhandler.Name = "checkhandler"
			checkhandler.Parent = checkbox
			checkhandler.BackgroundColor3 = Color3.new(0.67451, 0.192157, 0.192157)
			checkhandler.BorderColor3 = Color3.new(0, 0, 0)
			checkhandler.BorderSizePixel = 0
			checkhandler.Position = UDim2.new(0.93450731, 0, 0.300489277, 0)
			checkhandler.Size = UDim2.new(0, 13, 0, 14)
			checkhandler.AutoButtonColor = false

			UICorner.Parent = checkhandler
			UICorner.CornerRadius = UDim.new(0, 0)
			
			local enabled = false
			checkhandler.MouseButton1Click:Connect(function()
				if enabled == false then
					enabled = true
					local speed = 0.1
					local tf = TweenInfo.new(speed, Enum.EasingStyle.Quad , Enum.EasingDirection.In, 0.5)
					local ts = game:GetService("TweenService")
					local checktrue = Color3.fromRGB(33, 149, 27)
					ts:Create(checkhandler,tf, {BackgroundColor3 = checktrue}):Play()
					--toggler.ImageColor3 = Color3.fromRGB(144,255,96)
				else
					enabled = false 
					local speed = 0.1
					local tf = TweenInfo.new(speed, Enum.EasingStyle.Quad , Enum.EasingDirection.Out, 0.5)
					local ts = game:GetService("TweenService")
					local checkfalse = Color3.fromRGB(255,79,79)	
					ts:Create(checkhandler,tf, {BackgroundColor3 = checkfalse}):Play()
					--toggler.ImageColor3 = Color3.fromRGB(255,79,79)
				end
				pcall(callback,enabled)
			end)

			return self
		end

		return innertab
	end

	return createtab



	-- End of Tab Functionality
end

return lib
