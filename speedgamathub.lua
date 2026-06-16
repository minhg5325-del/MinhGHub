-- [[ CONFIG ]]
local targetSpeed = 40
local bypassActive = false

local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

-- [[ GUI SETUP ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CleanBypass"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Nút hiện GUI (Nhỏ, Gọn, Góc dưới trái)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "Toggle"
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 0.85, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Text = "⚡"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)

-- Main Menu (Bo tròn, hiện đại)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 180, 0, 120)
MainFrame.Position = UDim2.new(0.5, -90, 0.5, -60)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- UI Elements
local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(0, 150, 0, 30)
SpeedBox.Position = UDim2.new(0, 15, 0, 15)
SpeedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedBox.Text = "40"
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.PlaceholderText = "Speed"
SpeedBox.Parent = MainFrame
Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 6)

local ActionBtn = Instance.new("TextButton")
ActionBtn.Size = UDim2.new(0, 150, 0, 30)
ActionBtn.Position = UDim2.new(0, 15, 0, 55)
ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
ActionBtn.Text = "START"
ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionBtn.Parent = MainFrame
Instance.new("UICorner", ActionBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 150, 0, 20)
CloseBtn.Position = UDim2.new(0, 15, 0, 92)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "Close Menu"
CloseBtn.TextColor3 = Color3.fromRGB(100, 100, 100)
CloseBtn.Parent = MainFrame

-- [[ LOGIC ]]
ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

ActionBtn.MouseButton1Click:Connect(function()
    bypassActive = not bypassActive
    ActionBtn.Text = bypassActive and "STOP" or "START"
    ActionBtn.BackgroundColor3 = bypassActive and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 120, 255)
    targetSpeed = tonumber(SpeedBox.Text) or 40
end)

-- Anti-Cheat: Spoof Velocity
RunService.RenderStepped:Connect(function()
    if bypassActive then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            local hum = char.Humanoid
            if hum.MoveDirection.Magnitude > 0 then
                root.CFrame = root.CFrame + (hum.MoveDirection * (targetSpeed / 50))
            end
            hum.WalkSpeed = 16 -- Giữ chuẩn server
        end
    end
end)
