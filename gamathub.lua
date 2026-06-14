local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

if CoreGui:FindFirstChild("DeltaUssiCyberGUI") then 
    CoreGui.DeltaUssiCyberGUI:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaUssiCyberGUI"
ScreenGui.Parent = CoreGui

-- 1. KHUNG CHÍNH (PHONG CÁCH CYBERPUNK VUÔNG VỨC)
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 340, 0, 210) 
Main.Position = UDim2.new(0.5, -170, 0.3, -105)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Main.BorderSizePixel = 2 -- Tăng độ dày viền để hiện hiệu ứng Neon
Main.Active = true
Main.Parent = ScreenGui

-- Kéo thả mượt mà trên Mobile của ông
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
Main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- LOGIC HOẠT ẢNH RAINBOW SÓNG CHUYỂN MÀU RGB XỊN ĐÉT
local tickCount = 0
RunService.RenderStepped:Connect(function()
    tickCount = tickCount + 1
    local hue1 = (tickCount % 300) / 300
    local hue2 = ((tickCount + 50) % 300) / 300
    
    local rgbColor1 = Color3.fromHSV(hue1, 1, 1)
    local rgbColor2 = Color3.fromHSV(hue2, 1, 1)
    
    -- Đổi màu viền neon và chữ tiêu đề liên tục tạo hiệu ứng lấp lánh
    Main.BorderColor3 = rgbColor1
    if Main:FindFirstChild("Title") then
        Main.Title.TextColor3 = rgbColor2
    end
end)

-- Tiêu đề (Sẽ tự động nhận hiệu ứng Rainbow)
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -40, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 5)
Title.Text = "⚡ USSI CYBERPUNK RGB v3.0 ⚡"
Title.Font = Enum.Font.Code
Title.TextSize = 14
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

-- Nút X tắt nhanh phong cách góc cạnh
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -35, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(25, 15, 15)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 75, 75)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 18
CloseBtn.BorderSizePixel = 1
CloseBtn.BorderColor3 = Color3.fromRGB(80, 30, 30)
CloseBtn.Parent = Main
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Ô đặt tên file (Thiết kế chìm sang trọng)
local NameInput = Instance.new("TextBox")
NameInput.Size = UDim2.new(1, -30, 0, 32)
NameInput.Position = UDim2.new(0, 15, 0, 45)
NameInput.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
NameInput.BorderSizePixel = 1
NameInput.BorderColor3 = Color3.fromRGB(40, 40, 50)
NameInput.Text = "Gamer_Map_Chuan_Fix" 
NameInput.PlaceholderText = "Đặt tên file..."
NameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
NameInput.Font = Enum.Font.SourceSans
NameInput.TextSize = 13
NameInput.ClearTextOnFocus = false
NameInput.Parent = Main

-- 2. THANH TRƯỢT/MỞ RỘNG BỘ LỌC CHỨC NĂNG (GỌN GÀNG)
local DropdownBtn = Instance.new("TextButton")
DropdownBtn.Size = UDim2.new(1, -30, 0, 32)
DropdownBtn.Position = UDim2.new(0, 15, 0, 85)
DropdownBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
DropdownBtn.BorderSizePixel = 1
DropdownBtn.BorderColor3 = Color3.fromRGB(0, 200, 255)
DropdownBtn.Text = "▼ MỞ BẢNG BỘ LỌC (MẶC ĐỊNH: FULL MAP)"
DropdownBtn.TextColor3 = Color3.fromRGB(0, 220, 255)
DropdownBtn.Font = Enum.Font.SourceSansBold
DropdownBtn.TextSize = 12
DropdownBtn.Parent = Main

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -30, 0, 120) 
ScrollFrame.Position = UDim2.new(0, 15, 0, 117)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
ScrollFrame.BorderSizePixel = 1
ScrollFrame.BorderColor3 = Color3.fromRGB(40, 40, 45)
ScrollFrame.Visible = false 
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 230) 
ScrollFrame.Parent = Main

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 2)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

-- DANH SÁCH BỘ LỌC TẬP TIN
local Filters = {
    {Name = "Workspace (Khối 3D/Map)", Target = game:GetService("Workspace"), Active = true},
    {Name = "StarterGui (Giao diện/UI)", Target = game:GetService("StarterGui"), Active = true},
    {Name = "ReplicatedStorage (Mô hình/Data)", Target = game:GetService("ReplicatedStorage"), Active = true},
    {Name = "Lighting (Ánh sáng/VFX)", Target = game:GetService("Lighting"), Active = true},
    {Name = "ReplicatedFirst (Loading Game)", Target = game:GetService("ReplicatedFirst"), Active = true},
    {Name = "StarterPack (Túi đồ/Vũ khí)", Target = game:GetService("StarterPack"), Active = true},
}

-- Khởi tạo nút chọn trong thanh trượt mở rộng
for i, filter in ipairs(Filters) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -5, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(30, 30, 35)
    btn.Text = "  [✓]  " .. filter.Name
    btn.TextColor3 = Color3.fromRGB(0, 255, 150)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = ScrollFrame
    
    btn.MouseButton1Click:Connect(function()
        filter.Active = not filter.Active
        if filter.Active then
            btn.Text = "  [✓]  " .. filter.Name
            btn.TextColor3 = Color3.fromRGB(0, 255, 150)
            btn.BorderColor3 = Color3.fromRGB(30, 70, 50)
        else
            btn.Text = "  [  ]  " .. filter.Name
            btn.TextColor3 = Color3.fromRGB(140, 140, 145)
            btn.BorderColor3 = Color3.fromRGB(30, 30, 35)
        end
    end)
end

-- Hiệu ứng đóng mở bảng trượt mượt mà
local isOpen = false
DropdownBtn.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    if isOpen then
        DropdownBtn.Text = "▲ THU GỌN DANH SÁCH BỘ LỌC"
        Main.Size = UDim2.new(0, 340, 0, 340) 
        ScrollFrame.Visible = true
    else
        DropdownBtn.Text = "▼ MỞ BẢNG BỘ LỌC (MẶC ĐỊNH: FULL MAP)"
        Main.Size = UDim2.new(0, 340, 0, 210) 
        ScrollFrame.Visible = false
    end
end)

-- Trạng thái cố định
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -30, 0, 25)
Status.Position = UDim2.new(0, 15, 1, -75)
Status.Text = "⚙️ SYSTEM: OPTIMIZED RAM | OUTPUT: XML (.RBXLX)"
Status.TextColor3 = Color3.fromRGB(120, 120, 130)
Status.Font = Enum.Font.Code
Status.TextSize = 10
Status.BackgroundTransparency = 1
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

-- NÚT BẤM KÍCH HOẠT CHÍNH
local ActionBtn = Instance.new("TextButton")
ActionBtn.Size = UDim2.new(1, -30, 0, 42)
ActionBtn.Position = UDim2.new(0, 15, 1, -50) 
ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 90, 200)
ActionBtn.BorderSizePixel = 1
ActionBtn.BorderColor3 = Color3.fromRGB(0, 180, 255)
ActionBtn.Text = "EXECUTE EXTRACT PROJECT"
ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionBtn.Font = Enum.Font.Code
ActionBtn.TextSize = 13
ActionBtn.Parent = Main

-- Hiệu ứng hover đổi màu nhẹ cho nút bấm chính
ActionBtn.MouseEnter:Connect(function() ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255) end)
ActionBtn.MouseLeave:Connect(function() ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 90, 200) end)

ActionBtn.MouseButton1Click:Connect(function()
    local finalFileName = NameInput.Text:gsub("^%s*(.-)%s*$", "%1")
    if finalFileName == "" then finalFileName = "Gamer_Map_Chuan_Fix" end
    if not finalFileName:match("%.rbxlx$") and not finalFileName:match("%.rbxl$") then
        finalFileName = finalFileName .. ".rbxlx"
    end

    Main.Visible = false 
    if gcinfo then gcinfo() end 
    task.wait(0.3)
    
    local success, err = pcall(function()
        local USSI_Script = game:HttpGet("https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/saveinstance.luau", true)
        local USSI_Module = loadstring(USSI_Script)()
        
        local saveinstance_func
        if type(USSI_Module) == "function" then
            saveinstance_func = USSI_Module
        elseif type(USSI_Module) == "table" then
            saveinstance_func = USSI_Module.saveinstance
        end
        if type(saveinstance_func) ~= "function" then
            saveinstance_func = (getgenv and getgenv().saveinstance) or _G.saveinstance or _G.synsaveinstance
        end
        
        if type(saveinstance_func) ~= "function" then
            error("Engine USSI không phản hồi!")
        end
        
        local selectedObjects = {}
        local allSelected = true
        
        for _, filter in ipairs(Filters) do
            if filter.Active then
                table.insert(selectedObjects, filter.Target)
            else
                allSelected = false
            end
        end
        
        local Options = {
            noscripts = true,
            RemovePlayerCharacters = true,
            SaveWorkspaceTerrain = false, 
            IsBinary = false, 
            FileName = finalFileName 
        }
        
        if allSelected or #selectedObjects == 0 then
            Options.mode = "full"
        else
            Options.mode = "custom"
            Options.Objects = selectedObjects 
        end
        
        saveinstance_func(Options)
    end)
    
    Main.Visible = true 
    
    if success then
        Status.Text = "✔ SUCCESS: Saved to Delta/workspace!"
        Status.TextColor3 = Color3.fromRGB(0, 255, 150)
        ActionBtn.Text = "EXTRACT COMPLETED"
        ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
        ActionBtn.BorderColor3 = Color3.fromRGB(0, 255, 150)
    else
        Status.Text = "❌ ERROR: Check Console F9!"
        Status.TextColor3 = Color3.fromRGB(255, 75, 75)
        ActionBtn.Text = "EXTRACT FAILED"
        ActionBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        ActionBtn.BorderColor3 = Color3.fromRGB(255, 75, 75)
        print("Lỗi USSI: ", err)
    end
end)