--[[
    SPIDERGAMAT - Premium Edition (Mobile & Ceiling Fully Optimized)
    FEATURES:
    - 100% English GUI with custom menu name "SPIDERGAMAT".
    - Complete Player Filtering: Never climb on other players' characters.
    - Advanced Ceiling Vector Projection: Perfectly smooth 360° movement on ceilings for Mobile Joystick.
    - High-fidelity physical damping to completely eliminate jittering and random falls.
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")
local camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera")

-- System States
local isEnabled = false
local isClimbing = false
local bodyVelocity = nil
local bodyGyro = nil

-- Damping & Memory Variables
local smoothedNormal = Vector3.new(0, 1, 0)
local smoothedCFrame = CFrame.new()
local lastWallNormal = Vector3.new(0, 1, 0)
local lastLookDir = Vector3.new(0, 1, 0)
local lastDetachTime = 0
local lastFilterUpdate = 0
local timeInAir = nil 

local climbSpeed = 22
local hoverDistance = 2.4 

local screenGui, mainFrame, toggleButton, statusLabel
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local runAnimTrack = nil

----------------------------------------------------------------
-- 1. ENGLISH INTERFACE (SPIDERGAMAT)
----------------------------------------------------------------
local function createUI()
	local oldGui = player:WaitForChild("PlayerGui"):FindFirstChild("SpiderGamatGui")
	if oldGui then oldGui:Destroy() end

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SpiderGamatGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player:WaitForChild("PlayerGui")

	mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(0, 200, 0, 90)
	mainFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	mainFrame.Parent = screenGui
	Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

	toggleButton = Instance.new("TextButton")
	toggleButton.Size = UDim2.new(0.9, 0, 0.35, 0)
	toggleButton.Position = UDim2.new(0.05, 0, 0.1, 0)
	toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	toggleButton.Text = "SPIDERGAMAT: OFF"
	toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleButton.Font = Enum.Font.SourceSansBold
	toggleButton.TextSize = 14
	toggleButton.Parent = mainFrame
	Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 5)

	statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(0.9, 0, 0.25, 0)
	statusLabel.Position = UDim2.new(0.05, 0, 0.6, 0)
	statusLabel.Text = "Status: Ground"
	statusLabel.TextColor3 = Color3.fromRGB(150, 200, 150)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Font = Enum.Font.SourceSans
	statusLabel.TextSize = 13
	statusLabel.Parent = mainFrame

	-- Smooth GUI Dragging for Mobile/PC
	local dragging, dragStart, startPos
	mainFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true; dragStart = input.Position; startPos = mainFrame.Position
		end
	end)
	mainFrame.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

----------------------------------------------------------------
-- 2. DYNAMIC PLAYER FILTER (ANTI-CLIMB ON PLAYERS)
----------------------------------------------------------------
local function updateRaycastFilter()
	local filterList = {character}
	-- Scan and exclude all players in the server
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then
			table.insert(filterList, p.Character)
		end
	end
	raycastParams.FilterDescendantsInstances = filterList
end

local function raycastWithFilter(origin, direction)
	local currentOrigin = origin
	local currentDirection = direction
	local remainingLength = direction.Magnitude
	local attempts = 0

	while attempts < 5 and remainingLength > 0.2 do
		local hit = Workspace:Raycast(currentOrigin, currentDirection, raycastParams)
		if hit then
			if hit.Instance.CanCollide == true and hit.Instance.Transparency < 1 then
				return hit
			else
				local distanceCasted = (hit.Position - currentOrigin).Magnitude
				currentOrigin = hit.Position + direction.Unit * 0.1
				remainingLength = remainingLength - distanceCasted - 0.1
				currentDirection = direction.Unit * remainingLength
			end
		else
			break
		end
		attempts = attempts + 1
	end
	return nil
end

local function setGhostMode(state)
	for _, part in ipairs(character:GetChildren()) do
		if part:IsA("BasePart") then
			part.CanCollide = (part.Name == "HumanoidRootPart") or (not state)
		end
	end
end

local function getRunAnimation()
	local animator = humanoid:FindFirstChild("Animator") or humanoid:WaitForChild("Animator")
	local animateScript = character:FindFirstChild("Animate")
	if animateScript and animator then
		local runObj = animateScript:FindFirstChild("run") or animateScript:FindFirstChild("walk")
		local anim = runObj and runObj:FindFirstChildOfClass("Animation")
		if anim then
			local track = animator:LoadAnimation(anim)
			track.Priority = Enum.AnimationPriority.Action
			track.Looped = true
			return track
		end
	end
	return nil
end

local function resetClimbState()
	isClimbing = false
	timeInAir = nil
	humanoid.PlatformStand = false
	humanoid.AutoRotate = true
	setGhostMode(false) 

	if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
	if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
	statusLabel.Text = "Status: Ground"

	if runAnimTrack then 
		runAnimTrack:Stop(0.05) 
		runAnimTrack = nil 
	end

	local animateScript = character:FindFirstChild("Animate")
	if animateScript then animateScript.Disabled = false end

	if humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

----------------------------------------------------------------
-- 3. DISTANCE-BASED RAYCASTING
----------------------------------------------------------------
local function findActiveSurface(moveDir)
	camera = Workspace.CurrentCamera or camera
	local look = moveDir.Magnitude > 0 and moveDir or hrp.CFrame.LookVector

	if isClimbing then
		local lockRay = raycastWithFilter(hrp.Position, -lastWallNormal * 6.5)
		local frontRay = raycastWithFilter(hrp.Position + hrp.CFrame.UpVector * 1.0, look.Unit * 5.5)
		local ceilingRay = raycastWithFilter(hrp.Position, hrp.CFrame.UpVector * 6.0)

		if ceilingRay and ceilingRay.Normal.Y < -0.5 then return ceilingRay end

		if frontRay and (not lockRay or frontRay.Distance < lockRay.Distance + 0.5) then
			return frontRay
		elseif lockRay then
			return lockRay
		elseif frontRay then
			return frontRay
		end
	else
		local frontRay = raycastWithFilter(hrp.Position, hrp.CFrame.LookVector * 4.5)
		if frontRay and frontRay.Normal.Y < 0.71 then return frontRay end
		
		local angleRay = raycastWithFilter(hrp.Position, (hrp.CFrame.LookVector + Vector3.new(0, 0.3, 0)).Unit * 4.5)
		if angleRay and angleRay.Normal.Y < 0.71 then return angleRay end
	end
	return nil
end

----------------------------------------------------------------
-- 4. ULTRA-SMOOTH OMNI RUNNING LOOP (CEILING & MOBILE OPTIMIZED)
----------------------------------------------------------------
local function updateWallClimb()
	if not isEnabled or not hrp or not hrp.Parent then 
		if isClimbing then resetClimbState() end
		return 
	end

	if os.clock() - lastDetachTime < 0.4 then return end

	-- Throttle filter updates to every 1 second to maximize performance/FPS
	if os.clock() - lastFilterUpdate > 1.0 then
		lastFilterUpdate = os.clock()
		updateRaycastFilter()
	end

	camera = Workspace.CurrentCamera or camera
	local moveDir = humanoid.MoveDirection
	local wall = findActiveSurface(moveDir)

	if wall then
		timeInAir = nil
	else
		if isClimbing then
			if not timeInAir then timeInAir = os.clock() end
			if os.clock() - timeInAir < 0.45 then
				wall = {
					Position = hrp.Position - lastWallNormal * hoverDistance,
					Normal = lastWallNormal
				}
			else
				resetClimbState()
				return
			end
		end
	end

	if wall then
		if not isClimbing then
			isClimbing = true
			setGhostMode(true) 
			humanidStateConn = humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			humanoid.AutoRotate = false
			
			smoothedNormal = wall.Normal
			smoothedCFrame = hrp.CFrame
			lastLookDir = hrp.CFrame.LookVector
			
			local animateScript = character:FindFirstChild("Animate")
			if animateScript then animateScript.Disabled = true end
		end
		
		if humanoid:GetState() ~= Enum.HumanoidStateType.Physics then
			humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		end
		
		smoothedNormal = smoothedNormal:Lerp(wall.Normal, 0.25).Unit
		lastWallNormal = wall.Normal
		statusLabel.Text = "Status: Climbing 🕷️"

		if not bodyVelocity or not bodyVelocity.Parent then
			bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			bodyVelocity.Parent = hrp
		end

		if not bodyGyro or not bodyGyro.Parent then
			bodyGyro = Instance.new("BodyGyro")
			bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
			bodyGyro.P = 12000 
			bodyGyro.D = 350  
			bodyGyro.Parent = hrp
		end

		local currentDistance = (hrp.Position - wall.Position):Dot(smoothedNormal)
		local distanceError = hoverDistance - currentDistance
		local clampedError = math.clamp(distanceError, -2.5, 2.5)
		local hoverVelocity = smoothedNormal * (clampedError * 16)

		local targetVelocity = Vector3.new(0, 0, 0)
		
		-- MOBILE & CEILING MATRIX DIRECTION PROJECTOR
		local wallUpDir
		local wallRightDir
		
		if math.abs(smoothedNormal.Y) > 0.85 then
			-- CEILING/FLOOR SYSTEM: Project movement vectors perfectly matching Mobile Screen/Joystick Space
			local camRight = camera.CFrame.RightVector
			wallRightDir = (camRight - camRight:Dot(smoothedNormal) * smoothedNormal).Unit
			wallUpDir = smoothedNormal:Cross(wallRightDir).Unit
		else
			-- VERTICAL WALL SYSTEM: W always moves Upwards seamlessly
			local worldUp = Vector3.new(0, 1, 0)
			wallUpDir = (worldUp - worldUp:Dot(smoothedNormal) * smoothedNormal).Unit
			wallRightDir = wallUpDir:Cross(smoothedNormal).Unit
		end

		-- Screen-space joystick extraction
		local rawMoveX = 0
		local rawMoveZ = 0
		if moveDir.Magnitude > 0.05 and camera then
			local camRight = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z).Unit
			local camLook = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit
			rawMoveX = moveDir:Dot(camRight)
			rawMoveZ = moveDir:Dot(camLook)
		end

		local isMovingIntended = (math.abs(rawMoveX) > 0.05 or math.abs(rawMoveZ) > 0.05)
		local lookDir = nil

		if isMovingIntended then
			if not runAnimTrack then runAnimTrack = getRunAnimation() end
			if runAnimTrack and not runAnimTrack.IsPlaying then runAnimTrack:Play() end
			if runAnimTrack then runAnimTrack:AdjustSpeed(climbSpeed / 16) end

			-- Smooth calculation based on surface orientation
			if math.abs(smoothedNormal.Y) > 0.85 then
				targetVelocity = (wallUpDir * rawMoveZ + wallRightDir * rawMoveX).Unit * climbSpeed
			else
				targetVelocity = (wallUpDir * rawMoveZ + wallRightDir * rawMoveX).Unit * climbSpeed
			end
			
			lastLookDir = targetVelocity.Unit
			lookDir = lastLookDir
		else
			if runAnimTrack and runAnimTrack.IsPlaying then 
				runAnimTrack:Stop(0.02) 
			end
			lookDir = lastLookDir
		end

		-- Auto Ground Landing Detector
		if targetVelocity.Y < -0.1 or smoothedNormal.Y > 0.6 then
			local floorCheck = raycastWithFilter(hrp.Position, Vector3.new(0, -3.8, 0))
			if floorCheck and floorCheck.Normal.Y >= 0.75 then
				resetClimbState()
				return
			end
		end

		bodyVelocity.Velocity = targetVelocity + hoverVelocity

		-- Construct secure CFrame orientation matrix
		local rightVec = lookDir.Unit:Cross(smoothedNormal).Unit
		local backVec = rightVec:Cross(smoothedNormal).Unit
		local targetCFrame = CFrame.fromMatrix(hrp.Position, rightVec, smoothedNormal, backVec)
		
		smoothedCFrame = smoothedCFrame:Lerp(targetCFrame, 0.25)
		bodyGyro.CFrame = smoothedCFrame
	else
		if isClimbing then
			resetClimbState()
		end
	end
end

----------------------------------------------------------------
-- 5. INITIALIZATION & CONNECTIONS
----------------------------------------------------------------
local function handleJumpRequest()
	if isClimbing and hrp then
		lastDetachTime = os.clock()
		local jumpNormal = lastWallNormal
		resetClimbState()
		hrp.AssemblyLinearVelocity = (jumpNormal * 50) + Vector3.new(0, 58, 0)
	end
end

local function toggleSystem(state)
	if state == nil then isEnabled = not isEnabled else isEnabled = state end
	if isEnabled then
		toggleButton.Text = "SPIDERGAMAT: ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(50, 160, 50)
		updateRaycastFilter()
		RunService:BindToRenderStep("GhostSpiderClimb", Enum.RenderPriority.Character.Value, updateWallClimb)
	else
		toggleButton.Text = "SPIDERGAMAT: OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		RunService:UnbindFromRenderStep("GhostSpiderClimb")
		resetClimbState()
	end
end

player.CharacterAdded:Connect(function(newChar)
	toggleSystem(false)
	character = newChar
	humanoid = character:WaitForChild("Humanoid")
	hrp = character:WaitForChild("HumanoidRootPart")
	camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera")
	updateRaycastFilter()
	runAnimTrack = nil
end)

createUI()
updateRaycastFilter()
toggleButton.MouseButton1Click:Connect(function() toggleSystem() end)
local jumpConn = UserInputService.JumpRequest:Connect(handleJumpRequest)

script.Destroying:Connect(function()
	toggleSystem(false)
	if jumpConn then jumpConn:Disconnect() end
	if screenGui then screenGui:Destroy() end
end)
