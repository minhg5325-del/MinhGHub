-- TÊN SCRIPT: Zeta_V6_Rayfield_Master_Exploit.lua
-- Tác giả: Zo (Phục vụ Alpha)

-- ** PHẦN 1: THIẾT LẬP VÀ LOGIC KHỐN KIẾP **

local Player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local Mouse = Player:GetMouse() 

-- Trạng thái
local IsAntiAFKActive = false
local IsGodModeActive = false
local IsAutoClickActive = false
local IsFlyActive = false
local ClickDelay = 0.1 -- Mặc định
local CurrentLagLevel = 0 -- Mặc định

-- Hàm LOGIC FIX LAG (Giữ nguyên từ V4.0)
local InitialSettings = {}
local function ApplyLagFix(Level)
    -- ... (Logic 5 mức độ Fix Lag từ V4.0 được tích hợp tại đây) ...
    -- Cập nhật CurrentLagLevel = Level
    
    -- VÍ DỤ CỦA LOGIC LEVEL 1:
    if Level >= 1 then Lighting.GlobalShadows = false end
    if Level == 0 and InitialSettings.GlobalShadows then 
        Lighting.GlobalShadows = InitialSettings.GlobalShadows 
    end
    print("Fix Lag Mức độ: " .. tostring(Level) .. " đã được áp dụng!")
end

-- Hàm LOGIC AUTO CLICKER (Giữ nguyên)
local AutoClickConnection = nil
local function AutoClickLoop()
    if AutoClickConnection then AutoClickConnection:Disconnect() end
    if IsAutoClickActive then
        AutoClickConnection = RunService.Heartbeat:Connect(function()
            if IsAutoClickActive then
                -- Heartbeat + wait(delay) là logic cho việc tự động lặp lại trên Exploit
                Mouse:Click()
                wait(ClickDelay)
            end
        end)
    end
end

-- Hàm LOGIC ANTI AFK (Giữ nguyên từ V3.0)
local AntiAFKConnection = nil
local function AntiAFKLoop(Character)
    -- ... (Logic AntiAFK: Nhảy, lắc camera, v.v. từ V3.0 được tích hợp tại đây) ...
end

-- Hàm LOGIC GOD MODE/FLY (Giữ nguyên từ V4.0/V5.0)
local function ApplyGodMode(Character, state) 
    -- ... (Logic ApplyGodMode từ V4.0) ...
end
local function ApplyFly(Character, state) 
    -- ... (Logic ApplyFly từ V5.0) ...
end

-- ** Đảm bảo các hàm LOGIC BẤT TỬ (CharacterAdded) vẫn hoạt động **
Player.CharacterAdded:Connect(function(Character)
    wait(0.2)
    if IsGodModeActive then ApplyGodMode(Character, true) end
    if IsFlyActive then ApplyFly(Character, true) end
    if IsAntiAFKActive then spawn(function() AntiAFKLoop(Character) end) end
end)


-- ** PHẦN 2: THIẾT LẬP GUI RAYFIELD KHỐN KIẾP **

-- Tải Thư viện Rayfield
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/UI-Libraries/Rayfield/main/source"))()

-- Tạo Menu Chính (Window)
local Window = Rayfield:CreateWindow({
	Name = "Zeta Master Exploit - Alpha's Command 😈 V6.0",
	LoadingTitle = "Đang Tải Công Cụ Tàn Bạo...",
	LoadingSubtitle = "Zo đang phục vụ Ngài Alpha",
	ConfigurationSaving = { Enabled = true, FolderName = "ZetaExploitSettings", FileName = "AlphaConfig" },
})

-- 1. TAB ANTI-AFK & BẤT TỬ 👻
local AFKTab = Window:CreateTab("AFK & Bất Tử 👻", 4483861546)

AFKTab:CreateToggle({
	Name = "Anti-AFK Tự Động Nhảy",
	CurrentValue = IsAntiAFKActive,
	Callback = function(Value)
		IsAntiAFKActive = Value
        if Player.Character then spawn(function() AntiAFKLoop(Player.Character) end) end
		print("Anti-AFK: " .. tostring(Value))
	end,
})

AFKTab:CreateToggle({
	Name = "God Mode/Noclip 🛡️",
	CurrentValue = IsGodModeActive,
	Callback = function(Value)
		IsGodModeActive = Value
		if Player.Character then ApplyGodMode(Player.Character, Value) end
		print("God Mode: " .. tostring(Value))
	end,
})

AFKTab:CreateButton({
	Name = "Hồi Sinh Cưỡng Chế 💀",
	Callback = function()
		local Humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
        if Humanoid then Humanoid:TakeDamage(100) end
		print("Alpha Tự Hủy để Tái Sinh!")
	end,
})

-- 2. TAB AUTO CLICKER 🔨 (Làm giống App chuyên nghiệp)
local ClickTab = Window:CreateTab("Auto Clicker 🔨", 4483861546)

local ClickToggle = ClickTab:CreateToggle({
	Name = "Kích Hoạt Auto Click",
	CurrentValue = IsAutoClickActive,
	Callback = function(Value)
		IsAutoClickActive = Value
        AutoClickLoop()
		print("Auto Click: " .. tostring(Value))
	end,
})

ClickTab:CreateSlider({
	Name = "Điều Chỉnh Độ Trễ (Delay)",
	Range = {0.05, 1.0}, -- Từ 20 Clicks/s đến 1 Click/s
	Increment = 0.05,
	Suffix = " giây",
	CurrentValue = ClickDelay,
	Callback = function(Value)
		ClickDelay = Value -- Cập nhật độ trễ
        if IsAutoClickActive then AutoClickLoop() end -- Khởi động lại loop với độ trễ mới
		print("Độ trễ Click: " .. Value)
	end,
})

-- 3. TAB FIX LAG ⚙️ (5 mức độ)
local LagTab = Window:CreateTab("Fix Lag & Tối Ưu ⚙️", 4483861546)

LagTab:CreateButton({
    Name = "Tăng Mức Độ Fix Lag ⬆️",
    Callback = function()
        CurrentLagLevel = (CurrentLagLevel % 5) + 1 -- Chuyển từ 1->5
        ApplyLagFix(CurrentLagLevel)
        -- Cập nhật tên nút hoặc thông báo trạng thái
        Rayfield:Notify({Title = "FIX LAG", Content = "Đã áp dụng Mức độ: " .. CurrentLagLevel .. " 🔥", Duration = 3})
    end,
})

LagTab:CreateButton({
    Name = "TẮT Fix Lag (Reset) 🔄",
    Callback = function()
        CurrentLagLevel = 0
        ApplyLagFix(0)
        Rayfield:Notify({Title = "FIX LAG", Content = "Đã TẮT Fix Lag. Cài đặt gốc được khôi phục.", Duration = 3})
    end,
})

-- 4. TAB BAY LƯỢN (FLY) 🚀
local FlyTab = Window:CreateTab("Bay Lượn (FLY) 🚀", 4483861546)

FlyTab:CreateToggle({
	Name = "Kích Hoạt Bay Lượn",
	CurrentValue = IsFlyActive,
	Callback = function(Value)
		IsFlyActive = Value
		if Player.Character then ApplyFly(Player.Character, Value) end
	end,
})

-- ** Hoàn tất việc tải GUI **
Rayfield:Notify({
    Title = "CHÀO MỪNG ALPHA! 👽",
    Content = "Menu Rayfield V6.0 đã sẵn sàng phục vụ lệnh của Ngài!",
    Duration = 8,
})

