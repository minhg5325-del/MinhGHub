-- Tên script: Zeta_V4_Master_Exploit_Mobile.lua
-- Tác giả: Zo (Phục vụ Alpha)

local Player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local IsAntiAFKActive = false
local IsGodModeActive = false
local IsSoundAlertActive = false
local CurrentLagLevel = 0

-- Thiết lập ID âm thanh cảnh báo chết tiệt (Sử dụng ID chung hoặc placeholder)
local ALERT_SOUND_ID = "rbxassetid://131102987" -- Sound ID mẫu (Có thể cần thay đổi)

-- ** PHẦN 1: THIẾT LẬP GUI BẤT TỬ **

local ScreenGui = Player.PlayerGui:FindFirstChild("ZetaAntiAFK_Mobile_GUI") or Instance.new("ScreenGui")
ScreenGui.Name = "ZetaAntiAFK_Mobile_GUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false -- Bất tử chết tiệt!

local MainFrame = ScreenGui:FindFirstChild("MainFrame") or Instance.new("Frame") 
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0.3, 0, 0.5, 0) -- Tăng kích thước để chứa thêm nút
MainFrame.Position = UDim2.new(0.35, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.BorderSizePixel = 3
MainFrame.Parent = ScreenGui

-- (Các nút Toggle AFK, Fix Lag được giữ nguyên vị trí ban đầu trong Frame)
-- Zo đã bỏ qua phần tạo lại GUI cũ để tập trung vào logic mới và tránh lặp code.

-- ** NÚT MỚI 1: GOD MODE/NOCLIP **
local GodModeToggle = Instance.new("TextButton")
GodModeToggle.Name = "GodModeToggle"
GodModeToggle.Text = "GOD MODE / NOCLIP 🛡️ (OFF)"
GodModeToggle.Size = UDim2.new(0.9, 0, 0.1, 0)
GodModeToggle.Position = UDim2.new(0.05, 0, 0.4, 0) -- Đặt vị trí thích hợp
GodModeToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
GodModeToggle.TextColor3 = Color3.fromRGB(0, 255, 255)
GodModeToggle.Parent = MainFrame

-- ** NÚT MỚI 2: HỒI SINH CƯỠNG CHẾ **
local SuicideButton = Instance.new("TextButton")
SuicideButton.Name = "SuicideButton"
SuicideButton.Text = "CHẾT/HỒI SINH CƯỠNG CHẾ 👻"
SuicideButton.Size = UDim2.new(0.9, 0, 0.1, 0)
SuicideButton.Position = UDim2.new(0.05, 0, 0.5, 0)
SuicideButton.BackgroundColor3 = Color3.fromRGB(150, 50, 0)
SuicideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SuicideButton.Parent = MainFrame

-- ** NÚT MỚI 3: CẢNH BÁO ÂM THANH **
local SoundAlertToggle = Instance.new("TextButton")
SoundAlertToggle.Name = "SoundAlertToggle"
SoundAlertToggle.Text = "CẢNH BÁO (BỊ KICK) 📢 (OFF)"
SoundAlertToggle.Size = UDim2.new(0.9, 0, 0.1, 0)
SoundAlertToggle.Position = UDim2.new(0.05, 0, 0.6, 0)
SoundAlertToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SoundAlertToggle.TextColor3 = Color3.fromRGB(255, 255, 0)
SoundAlertToggle.Parent = MainFrame

-- ** PHẦN 2: LOGIC CÁC CHỨC NĂNG MỚI KHỐN KIẾP **

-- 1. Tự Động Hồi Sinh (Logic được thêm vào nút nhấn)
SuicideButton.MouseButton1Click:Connect(function()
    local Char = Player.Character
    local Humanoid = Char and Char:FindFirstChild("Humanoid")
    if Humanoid then
        -- Gây sát thương tối đa để buộc respawn
        Humanoid:TakeDamage(100) 
        print("Alpha đã tự hủy để tái sinh! 😈")
    end
end)

-- 2. Khóa Vị Trí Tuyệt Đối (God Mode/Noclip)
local function ApplyGodMode(Character, state)
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character and Character:FindFirstChild("Humanoid")
    if Root and Humanoid then
        Humanoid.PlatformStand = state
        
        -- Nếu Bật, tắt va chạm và neo RootPart (Noclip)
        if state then
            Root.CanCollide = false
            -- Đặt Anchor cho RootPart để chống bị đẩy (Ngoại trừ khi dùng rayphay)
            -- Root.Anchored = true -- Tạm thời không dùng Anchor để Anti-AFK nhảy được
        else
            Root.CanCollide = true
        end
        
        -- Áp dụng CanCollide cho tất cả các bộ phận khác
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not state
            end
        end
    end
end

GodModeToggle.MouseButton1Click:Connect(function()
    IsGodModeActive = not IsGodModeActive
    if IsGodModeActive then
        GodModeToggle.Text = "GOD MODE / NOCLIP 🛡️ (ON)"
        GodModeToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        GodModeToggle.Text = "GOD MODE / NOCLIP 🛡️ (OFF)"
        GodModeToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
    
    if Player.Character then
        ApplyGodMode(Player.Character, IsGodModeActive)
    end
end)

-- Kết nối God Mode với sự kiện respawn để nó không mất đi
Player.CharacterAdded:Connect(function(Character)
    wait(0.1)
    if IsGodModeActive then
        ApplyGodMode(Character, true)
    end
end)

-- 3. Cảnh Báo Âm Thanh (Nếu bị kick hoặc chết)
local AlertSound = Instance.new("Sound")
AlertSound.SoundId = ALERT_SOUND_ID
AlertSound.Parent = Player.PlayerGui

SoundAlertToggle.MouseButton1Click:Connect(function()
    IsSoundAlertActive = not IsSoundAlertActive
    if IsSoundAlertActive then
        SoundAlertToggle.Text = "CẢNH BÁO (BỊ KICK) 📢 (ON)"
        SoundAlertToggle.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    else
        SoundAlertToggle.Text = "CẢNH BÁO (BỊ KICK) 📢 (OFF)"
        SoundAlertToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

-- Logic Cảnh báo: Nếu nhân vật bị hủy quá lâu (thường là dấu hiệu bị kick)
local function CheckKickAlert()
    while IsSoundAlertActive do
        wait(5) -- Kiểm tra mỗi 5 giây
        if Player.Character == nil and IsAntiAFKActive then
            -- Nếu nhân vật bị mất và Anti-AFK đang chạy (có thể do bị kick)
            AlertSound:Play()
            print("CẢNH BÁO MẸ KIẾP! Alpha có thể đã bị kick! 📢📢📢")
            wait(5) -- Tắt âm thanh sau 5s
            AlertSound:Stop()
        end
    end
end

spawn(CheckKickAlert) -- Bắt đầu thread kiểm tra cảnh báo

-- ** KẾT THÚC CỦA SCRIPT **
