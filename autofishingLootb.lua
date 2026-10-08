--!nonstrict
--[[
	=========================================================
	AutoFish.delta.luau  —  LootBound
	Bản Delta Mobile + Anti-AFK tích hợp
	=========================================================
	DÁN vào Delta > Execute (không cần đặt vào StarterPlayerScripts).
	Yêu cầu: đứng cạnh nước, KHÔNG lên thuyền.
	=========================================================
	ANTI-AFK: tự động, không cần bật. 3 tầng phòng ngừa:
	  1. Hook LocalPlayer.Idled (chuẩn Roblox, fire sau ~20 phút)
	  2. Reset timer mỗi 60s qua VirtualUser
	  3. Mouse move ảo mỗi 45s (nếu executor có mousemoverel)
	=========================================================
]]

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local HapticService     = game:GetService("HapticService")
local VirtualUser       = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- ==========================================================
-- CẤU HÌNH
-- ==========================================================
local CONFIG = {
	Enabled = false,
	ToggleKey = Enum.KeyCode.F8,

	ButtonPos = UDim2.new(0.5, -80, 0, 50),
	SafeAreaTop = 36,

	CastRetryDelay = 1.2,
	MaxRetryDelay  = 6.0,
	CatchCooldown  = 1.0,

	DefaultBarWidth    = 300,
	DefaultFishWidth   = 30,
	DefaultPlayerWidth = 80,

	ShowStatus        = true,
	HapticOnCatch     = true,
	HapticDuration    = 0.15,
	MinimizeOnTap     = false,
}

-- ==========================================================
-- ANTI-AFK — tự động, không cần bật
-- ==========================================================
-- Tầng 1: hook sự kiện chuẩn — fire khi Roblox sắp kick vì AFK (~20 phút)
LocalPlayer.Idled:Connect(function()
	pcall(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end)
end)

-- Tầng 2: tự reset timer mỗi 60s — một số game patch Idled nên cần proactive
task.spawn(function()
	while true do
		task.wait(60)
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
	end
end)

-- Tầng 3: mouse move ảo mỗi 45s — executor-specific, chỉ chạy nếu có API
if type(mousemoverel) == "function" then
	task.spawn(function()
		while true do
			task.wait(45)
			pcall(function()
				mousemoverel(1, 0)
				task.wait(0.05)
				mousemoverel(-1, 0)
			end)
		end
	end)
end

-- ==========================================================
-- MODULE LOADER (Delta-safe)
-- ==========================================================
local function softRequire(name)
	local folder = ReplicatedStorage:FindFirstChild("Module")
		or ReplicatedStorage:WaitForChild("Module", 10)
	if not folder then return nil end
	local ms = folder:FindFirstChild(name, true)
	if not ms or not ms:IsA("ModuleScript") then return nil end
	local ok, mod = pcall(require, ms)
	if ok and type(mod) == "table" then return mod end
	return nil
end

local FishingController, ReelController, GameConfig

local playerSpeed = 0.82
local enabled = CONFIG.Enabled
local holdSent = nil
local lastHeld = false
local myPos = 0.5
local lastFishCenter = 0.5
local retryDelay = CONFIG.CastRetryDelay
local nextCastAt = 0
local lastState = ""
local catchCount = 0
local holdFrames = 0
local barNode, fishNode, playerNode
local lastTapAt = 0
local minimized = false

-- ==========================================================
-- HAPTIC
-- ==========================================================
local function pulse()
	if not CONFIG.HapticOnCatch then return end
	pcall(function()
		HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 1)
		task.delay(CONFIG.HapticDuration, function()
			pcall(function() HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0) end)
		end)
	end)
	if type(executorvibrate) == "function" then
		pcall(executorvibrate, CONFIG.HapticDuration)
	end
end

-- ==========================================================
-- UI
-- ==========================================================
local gui, holder, toggleBtn, statusLbl, counterLbl, miniBtn

local COL_ON  = Color3.fromRGB(46, 160, 94)
local COL_OFF = Color3.fromRGB(160, 52, 52)
local COL_BG  = Color3.fromRGB(24, 24, 28)

local function setStatus(text)
	if statusLbl and CONFIG.ShowStatus and not minimized then
		statusLbl.Text = text
	end
end

local function refreshButton()
	if not toggleBtn then return end
	if enabled then
		toggleBtn.Text = "AUTO CÂU: BẬT"
		toggleBtn.BackgroundColor3 = COL_ON
	else
		toggleBtn.Text = "AUTO CÂU: TẮT"
		toggleBtn.BackgroundColor3 = COL_OFF
	end
	toggleBtn.TextColor3 = Color3.new(1, 1, 1)
end

local function setEnabled(v)
	enabled = v
	refreshButton()
	if not enabled then
		setHold(false, true)
		setStatus("Đã tắt")
	else
		retryDelay = CONFIG.CastRetryDelay
		nextCastAt = 0
		setStatus("Đang câu...")
	end
end

local function setMinimized(v)
	minimized = v
	if holder then holder.Visible = not v end
	if miniBtn then miniBtn.Visible = v end
end

local function buildUI()
	local pg = LocalPlayer:WaitForChild("PlayerGui", 10)
	if not pg then
		warn("[AutoFish] không lấy được PlayerGui")
		return
	end

	local old = pg:FindFirstChild("AutoFishGui")
	if old then old:Destroy() end

	gui = Instance.new("ScreenGui")
	gui.Name = "AutoFishGui"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 500
	gui.IgnoreGuiInset = false
	gui.Parent = pg

	holder = Instance.new("Frame")
	holder.Name = "Holder"
	holder.AnchorPoint = Vector2.new(0.5, 0)
	holder.Position = CONFIG.ButtonPos + UDim2.new(0, 0, 0, CONFIG.SafeAreaTop)
	holder.Size = UDim2.fromOffset(200, 104)
	holder.BackgroundColor3 = COL_BG
	holder.BackgroundTransparency = 0.15
	holder.BorderSizePixel = 0
	holder.Active = true
	holder.Draggable = true
	holder.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = holder

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.Parent = holder

	toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "Toggle"
	toggleBtn.Position = UDim2.fromOffset(0, 0)
	toggleBtn.Size = UDim2.new(1, 0, 0, 52)
	toggleBtn.BackgroundColor3 = COL_OFF
	toggleBtn.BorderSizePixel = 0
	toggleBtn.AutoButtonColor = true
	toggleBtn.Font = Enum.Font.GothamBold
	toggleBtn.TextSize = 16
	toggleBtn.Text = "AUTO CÂU: TẮT"
	toggleBtn.TextColor3 = Color3.new(1, 1, 1)
	toggleBtn.Parent = holder
	local cb = Instance.new("UICorner")
	cb.CornerRadius = UDim.new(0, 10)
	cb.Parent = toggleBtn

	local minBtn = Instance.new("TextButton")
	minBtn.Size = UDim2.fromOffset(32, 32)
	minBtn.Position = UDim2.new(1, -32, 0, 0)
	minBtn.BackgroundTransparency = 1
	minBtn.Text = "▼"
	minBtn.TextColor3 = Color3.new(1, 1, 1)
	minBtn.Font = Enum.Font.GothamBold
	minBtn.TextSize = 14
	minBtn.Parent = holder
	minBtn.MouseButton1Click:Connect(function() setMinimized(true) end)

	statusLbl = Instance.new("TextLabel")
	statusLbl.Name = "Status"
	statusLbl.Position = UDim2.fromOffset(0, 56)
	statusLbl.Size = UDim2.new(1, 0, 0, 16)
	statusLbl.BackgroundTransparency = 1
	statusLbl.Font = Enum.Font.Gotham
	statusLbl.TextSize = 12
	statusLbl.TextXAlignment = Enum.TextXAlignment.Left
	statusLbl.TextColor3 = Color3.fromRGB(235, 235, 235)
	statusLbl.TextStrokeTransparency = 0.45
	statusLbl.Text = "Chạm để bật/tắt"
	statusLbl.Parent = holder

	counterLbl = Instance.new("TextLabel")
	counterLbl.Name = "Counter"
	counterLbl.Position = UDim2.fromOffset(0, 74)
	counterLbl.Size = UDim2.new(1, 0, 0, 16)
	counterLbl.BackgroundTransparency = 1
	counterLbl.Font = Enum.Font.Gotham
	counterLbl.TextSize = 12
	counterLbl.TextXAlignment = Enum.TextXAlignment.Left
	counterLbl.TextColor3 = Color3.fromRGB(255, 225, 140)
	counterLbl.TextStrokeTransparency = 0.45
	counterLbl.Text = "Đã câu: 0"
	counterLbl.Parent = holder

	toggleBtn.MouseButton1Click:Connect(function()
		local now = os.clock()
		if CONFIG.MinimizeOnTap then
			setMinimized(true)
			return
		end
		setEnabled(not enabled)
		lastTapAt = now
	end)

	miniBtn = Instance.new("TextButton")
	miniBtn.Name = "Mini"
	miniBtn.AnchorPoint = Vector2.new(0.5, 0)
	miniBtn.Position = CONFIG.ButtonPos + UDim2.new(0, 0, 0, CONFIG.SafeAreaTop)
	miniBtn.Size = UDim2.fromOffset(56, 56)
	miniBtn.BackgroundColor3 = COL_OFF
	miniBtn.BorderSizePixel = 0
	miniBtn.Text = "🎣"
	miniBtn.TextSize = 26
	miniBtn.TextColor3 = Color3.new(1, 1, 1)
	miniBtn.Visible = false
	miniBtn.Draggable = true
	miniBtn.Parent = gui
	local mb = Instance.new("UICorner")
	mb.CornerRadius = UDim.new(1, 0)
	mb.Parent = miniBtn

	miniBtn.MouseButton1Click:Connect(function()
		setMinimized(false)
		refreshButton()
	end)

	refreshButton()
end

-- ==========================================================
-- HÀNH ĐỘNG
-- ==========================================================
local function setHold(h, force)
	if not force and h == holdSent then return end
	holdSent = h
	if ReelController and type(ReelController.SetExternalHeld) == "function" then
		pcall(ReelController.SetExternalHeld, h)
	end
end

local function getState()
	if not FishingController or type(FishingController.GetCurrentState) ~= "function" then
		return "NONE"
	end
	local ok, s = pcall(FishingController.GetCurrentState)
	if ok and type(s) == "string" then return s end
	return "NONE"
end

local function resolveReelNodes()
	if barNode and barNode.Parent
		and fishNode and fishNode.Parent
		and playerNode and playerNode.Parent then
		return true
	end
	local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	if not pg then return false end
	local root = pg:FindFirstChild("reel", true)
	if not root then return false end
	local b = root:FindFirstChild("bar") or root:FindFirstChild("bar", true)
	if not b or not b:IsA("GuiObject") then return false end
	local f = b:FindFirstChild("fish") or b:FindFirstChild("fish", true)
	local p = b:FindFirstChild("playerbar") or b:FindFirstChild("playerbar", true)
	if not f or not p then return false end
	barNode, fishNode, playerNode = b, f, p
	return true
end

local function resetReelTracking()
	myPos = 0.5
	lastFishCenter = 0.5
	lastHeld = false
end

local function solveReel(dt)
	local usingGui = resolveReelNodes()
	local barW, fishW, pW, fishPos, pPos

	if usingGui then
		barW  = barNode.AbsoluteSize.X
		fishW = fishNode.AbsoluteSize.X
		pW    = playerNode.AbsoluteSize.X
		fishPos = fishNode.Position.X.Scale
		pPos    = playerNode.Position.X.Scale
		if barW <= 0 or pW <= 0 or fishW <= 0 or barW <= pW then
			usingGui = false
		end
	end

	if not usingGui then
		barW  = CONFIG.DefaultBarWidth
		fishW = CONFIG.DefaultFishWidth
		pW    = CONFIG.DefaultPlayerWidth
		local ok, fp = false, nil
		if ReelController and type(ReelController.GetFishPosition) == "function" then
			ok, fp = pcall(ReelController.GetFishPosition)
		end
		if ok and type(fp) == "number" then fishPos = fp else fishPos = 0.5 end
		pPos = myPos
	end

	local fishScale = fishW / barW
	local pScale    = pW / barW
	local fishCenter = fishPos * (1 - fishScale) + fishScale * 0.5
	local pMin = pPos * (1 - pScale)
	local pMax = pMin + pScale
	local selfCenter = (pMin + pMax) * 0.5

	local lead = math.min(dt, 0.05)
	local nextSelf = math.clamp(pPos + (lastHeld and 1 or -1) * playerSpeed * lead, 0, 1)
	local nextMin = nextSelf * (1 - pScale)
	local nextSelfCenter = (nextMin + nextMin + pScale) * 0.5

	local fishVel = (fishCenter - lastFishCenter) / math.max(dt, 1e-4)
	fishVel = math.clamp(fishVel, -4, 4)
	lastFishCenter = fishCenter
	local nextFish = math.clamp(fishCenter + fishVel * lead, 0, 1)

	local diff = nextFish - nextSelfCenter
	local dead = pScale * 0.12
	local hold
	if diff > dead then
		hold = true
	elseif diff < -dead then
		hold = false
	else
		hold = lastHeld
	end

	lastHeld = hold
	if hold then holdFrames += 1 end
	setHold(hold)

	if not usingGui then
		myPos = math.clamp(pPos + (hold and 1 or -1) * playerSpeed * dt, 0, 1)
	end
end

-- ==========================================================
-- VÒNG LẶP CHÍNH
-- ==========================================================
RunService.Heartbeat:Connect(function(dt)
	if not enabled then
		setHold(false)
		return
	end

	if not FishingController or not ReelController then
		FishingController = FishingController or softRequire("FishingController")
		ReelController    = ReelController    or softRequire("ReelController")
		if not GameConfig then
			GameConfig = softRequire("GameConfig")
			if GameConfig and GameConfig.Reeling
				and type(GameConfig.Reeling.PlayerSpeed) == "number" then
				playerSpeed = math.clamp(GameConfig.Reeling.PlayerSpeed, 0.05, 5)
			end
		end
		if not FishingController or not ReelController then
			setStatus("Chờ module câu cá...")
			return
		end
	end

	local state = getState()

	if state ~= lastState then
		if state == "CAUGHT" then
			catchCount += 1
			nextCastAt = os.clock() + CONFIG.CatchCooldown
			if counterLbl then
				counterLbl.Text = "Đã câu: " .. tostring(catchCount)
			end
			pulse()
		end
		lastState = state
	end

	if state == "REELING" then
		solveReel(dt)
		setStatus((lastHeld and "● Đang giữ" or "○ Đang thả") .. " — kéo cá...")

	elseif state == "EQUIPPED" then
		setHold(false)
		resetReelTracking()
		local now = os.clock()
		if now >= nextCastAt then
			if type(FishingController.StartCharging) == "function" then
				pcall(FishingController.StartCharging)
			end
			if getState() == "EQUIPPED" then
				retryDelay = math.min(retryDelay * 1.6, CONFIG.MaxRetryDelay)
			else
				retryDelay = CONFIG.CastRetryDelay
			end
			nextCastAt = now + retryDelay
		end
		setStatus("Sẵn sàng ném cần...")

	elseif state == "NONE" then
		setHold(false)
		resetReelTracking()
		if type(FishingController.TryRecoverEquip) == "function" then
			pcall(FishingController.TryRecoverEquip)
		end
		setStatus("Chưa cầm cần — trang bị cần")

	else
		setHold(false)
		if state == "CHARGING" then
			setStatus("Đang tụ lực...")
		elseif state == "CASTING" then
			setStatus("Đang ném...")
		elseif state == "WAITING" then
			setStatus("Đợi cá cắn...")
		elseif state == "CAUGHT" then
			setStatus("Bắt được rồi!")
		else
			setStatus(state)
		end
	end
end)

-- ==========================================================
-- RESPAWN HANDLER
-- ==========================================================
LocalPlayer.CharacterAdded:Connect(function()
	FishingController = nil
	ReelController = nil
	GameConfig = nil
	barNode, fishNode, playerNode = nil, nil, nil
	resetReelTracking()
	nextCastAt = 0
	retryDelay = CONFIG.CastRetryDelay
	if enabled then setStatus("Respawn — nạp lại module...") end
end)

-- ==========================================================
-- PHÍM TẮT (Bluetooth keyboard — optional)
-- ==========================================================
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.Keyboard
		and input.KeyCode == CONFIG.ToggleKey then
		setEnabled(not enabled)
	end
end)

-- ==========================================================
-- CLEANUP
-- ==========================================================
getgenv().AutoFishCleanup = function()
	pcall(function()
		if ReelController and type(ReelController.SetExternalHeld) == "function" then
			ReelController.SetExternalHeld(false)
		end
	end)
	if gui then pcall(function() gui:Destroy() end) end
end

task.spawn(buildUI)
task.wait(0.2)
setStatus("Chạm nút để bật/tắt")
print("[AutoFish Delta] loaded — Anti-AFK ON · kéo nút để di chuyển, chạm để bật/tắt")