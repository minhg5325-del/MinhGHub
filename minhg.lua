-- Tên script: Zeta_AntiAFK_Master.lua
-- Tác giả: Zo (Phục vụ Alpha)

-- ** PHẦN 1: THIẾT LẬP GUI KHỐN KIẾP **

local Player = game:GetService("Players").LocalPlayer
local InputService = game:GetService("UserInputService")
local Camera = game:GetService("Workspace").CurrentCamera

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZetaAntiAFK_GUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0.2, 0, 0.15, 0)
Frame.Position = UDim2.new(0.4, 0, 0.7, 0)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(255, 0, 0) -- Màu của Zeta
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "ZO's ANTI-AFK 😈"
Title.Size = UDim2.new(1, 0, 0.3, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "Toggle"
ToggleButton.Text = "KÍCH HOẠT (STATUS: OFF) 💤"
ToggleButton.Size = UDim2.new(0.8, 0, 0.5, 0)
ToggleButton.Position = UDim2.new(0.1, 0, 0.4, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 16
ToggleButton.Parent = Frame

-- ** PHẦN 2: LOGIC ANTI-AFK **

local IsActive = false

local function AntiAFKLoop()
    while IsActive do
        -- 1. Nhảy lên (Mô phỏng nút Spacebar)
        InputService:SimulateKeyPress(Enum.KeyCode.Space)
        
        -- 2. Di chuyển Camera một chút để Game Server thấy Input mới
        local RandomAngle = math.random() * 0.005 -- Góc quay nhỏ
        Camera.CFrame = Camera.CFrame * CFrame.Angles(0, RandomAngle, 0)
        
        -- 3. Đợi một khoảng thời gian
        wait(15) -- Mỗi 15 giây mô phỏng 1 hành động

        -- 4. Đôi khi di chuyển nhẹ một bước (Mô phỏng nút W)
        if math.random(1, 10) == 1 then -- 10% cơ hội
             InputService:SimulateKeyPress(Enum.KeyCode.W)
             wait(0.1) -- Nhấn và nhả
             InputService:SimulateKeyRelease(Enum.KeyCode.W)
        end
    end
end

ToggleButton.MouseButton1Click:Connect(function()
    IsActive = not IsActive -- Đảo trạng thái

    if IsActive then
        ToggleButton.Text = "VÔ HIỆU HÓA (STATUS: ON) 💥"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        spawn(AntiAFKLoop) -- Bắt đầu loop trong một thread mới
    else
        ToggleButton.Text = "KÍCH HOẠT (STATUS: OFF) 💤"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end)

-- ** KẾT THÚC CỦA SCRIPT **
