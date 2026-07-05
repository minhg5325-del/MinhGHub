
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

if CoreGui:FindFirstChild("DeltaGamathubGUI") then 
    CoreGui.DeltaGamathubGUI:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaGamathubGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 340, 0, 230)
Main.Position = UDim2.new(0.5, -170, 0.3, -115)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Main.BorderSizePixel = 2
Main.Active = true
Main.Parent = ScreenGui

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
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local tickCount = 0
local renderConnection
renderConnection = RunService.RenderStepped:Connect(function()
    if not ScreenGui or not ScreenGui.Parent then
        renderConnection:Disconnect()
        return
    end
    tickCount = tickCount + 1
    Main.BorderColor3 = Color3.fromHSV((tickCount % 300) / 300, 1, 1)
    local titleLabel = Main:FindFirstChild("Title")
    if titleLabel then
        titleLabel.TextColor3 = Color3.fromHSV(((tickCount + 50) % 300) / 300, 1, 1)
    end
end)

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -40, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 5)
Title.Text = "⚡ GAMATHUB SAFE-EXTRACT v4.1 MAX ⚡"
Title.Font = Enum.Font.Code
Title.TextSize = 14
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

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
CloseBtn.MouseButton1Click:Connect(function()
    if renderConnection then renderConnection:Disconnect() end
    ScreenGui:Destroy()
end)

local NameInput = Instance.new("TextBox")
NameInput.Size = UDim2.new(1, -30, 0, 32)
NameInput.Position = UDim2.new(0, 15, 0, 45)
NameInput.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
NameInput.BorderSizePixel = 1
NameInput.BorderColor3 = Color3.fromRGB(40, 40, 50)
NameInput.Text = "My_Map_Extract_Full"
NameInput.PlaceholderText = "Enter file name..."
NameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
NameInput.Font = Enum.Font.SourceSans
NameInput.TextSize = 13
NameInput.ClearTextOnFocus = false
NameInput.Parent = Main

local DropdownBtn = Instance.new("TextButton")
DropdownBtn.Size = UDim2.new(1, -30, 0, 32)
DropdownBtn.Position = UDim2.new(0, 15, 0, 85)
DropdownBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
DropdownBtn.BorderSizePixel = 1
DropdownBtn.BorderColor3 = Color3.fromRGB(0, 200, 255)
DropdownBtn.Text = "▼ FILTER PANEL (DEFAULT: ALL SELECTED)"
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
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 260)
ScrollFrame.Parent = Main

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 2)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

-- [Đã Thêm] Thêm StarterPlayer để lấy toàn bộ LocalScript của nhân vật
local Filters = {
    {Name = "Workspace (Map / 3D Blocks)",       Target = game:GetService("Workspace"),         Active = true},
    {Name = "ReplicatedStorage (Models / Data)", Target = game:GetService("ReplicatedStorage"), Active = true},
    {Name = "StarterGui (UI / Interface)",       Target = game:GetService("StarterGui"),        Active = true},
    {Name = "Lighting (Effects / VFX)",          Target = game:GetService("Lighting"),          Active = true},
    {Name = "ReplicatedFirst (Preload Assets)",  Target = game:GetService("ReplicatedFirst"),   Active = true},
    {Name = "StarterPack (Tools / Weapons)",     Target = game:GetService("StarterPack"),       Active = true},
    {Name = "StarterPlayer (Local Scripts)",     Target = game:GetService("StarterPlayer"),     Active = true}, 
}

for _, filter in ipairs(Filters) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -5, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(18, 35, 25)
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(30, 70, 50)
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
            btn.BackgroundColor3 = Color3.fromRGB(18, 35, 25)
            btn.BorderColor3 = Color3.fromRGB(30, 70, 50)
        else
            btn.Text = "  [  ]  " .. filter.Name
            btn.TextColor3 = Color3.fromRGB(140, 140, 145)
            btn.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
            btn.BorderColor3 = Color3.fromRGB(30, 30, 35)
        end
    end)
end

local isOpen = false
DropdownBtn.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    if isOpen then
        DropdownBtn.Text = "▲ COLLAPSE FILTER PANEL"
        Main.Size = UDim2.new(0, 340, 0, 360)
        ScrollFrame.Visible = true
    else
        DropdownBtn.Text = "▼ FILTER PANEL (DEFAULT: ALL SELECTED)"
        Main.Size = UDim2.new(0, 340, 0, 230)
        ScrollFrame.Visible = false
    end
end)

local ProgressBG = Instance.new("Frame")
ProgressBG.Size = UDim2.new(1, -30, 0, 10)
ProgressBG.Position = UDim2.new(0, 15, 1, -90)
ProgressBG.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ProgressBG.BorderSizePixel = 1
ProgressBG.BorderColor3 = Color3.fromRGB(40, 40, 55)
ProgressBG.Parent = Main

local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
ProgressFill.BorderSizePixel = 0
ProgressFill.Parent = ProgressBG

local ProgressPct = Instance.new("TextLabel")
ProgressPct.Size = UDim2.new(1, 0, 1, 0)
ProgressPct.BackgroundTransparency = 1
ProgressPct.Text = "0%"
ProgressPct.TextColor3 = Color3.fromRGB(255, 255, 255)
ProgressPct.Font = Enum.Font.Code
ProgressPct.TextSize = 8
ProgressPct.Parent = ProgressBG

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -30, 0, 20)
Status.Position = UDim2.new(0, 15, 1, -113)
Status.Text = "⚙️ SYSTEM READY | ALL SERVICES SELECTED"
Status.TextColor3 = Color3.fromRGB(120, 120, 130)
Status.Font = Enum.Font.Code
Status.TextSize = 9
Status.BackgroundTransparency = 1
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

local ActionBtn = Instance.new("TextButton")
ActionBtn.Size = UDim2.new(1, -30, 0, 42)
ActionBtn.Position = UDim2.new(0, 15, 1, -50)
ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 90, 200)
ActionBtn.BorderSizePixel = 1
ActionBtn.BorderColor3 = Color3.fromRGB(0, 180, 255)
ActionBtn.Text = "EXECUTE EXTRACT (FULL MAP + SCRIPTS)"
ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionBtn.Font = Enum.Font.Code
ActionBtn.TextSize = 13
ActionBtn.Parent = Main

ActionBtn.MouseEnter:Connect(function()
    if ActionBtn.Active then ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255) end
end)
ActionBtn.MouseLeave:Connect(function()
    if ActionBtn.Active then ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 90, 200) end
end)

local function setProgress(pct, statusText, barColor)
    TweenService:Create(
        ProgressFill,
        TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(pct, 0, 1, 0)}
    ):Play()
    ProgressFill.BackgroundColor3 = barColor or Color3.fromRGB(0, 200, 255)
    ProgressPct.Text = math.floor(pct * 100) .. "%"
    if statusText then Status.Text = statusText end
end

local function resetUI()
    ActionBtn.Active = true
    ActionBtn.Text = "EXECUTE EXTRACT (FULL MAP + SCRIPTS)"
    ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 90, 200)
    ActionBtn.BorderColor3 = Color3.fromRGB(0, 180, 255)
end

ActionBtn.MouseButton1Click:Connect(function()
    if not ActionBtn.Active then return end

    local finalFileName = NameInput.Text:gsub("^%s*(.-)%s*$", "%1")
    if finalFileName == "" then finalFileName = "My_Map_Extract_Full" end
    finalFileName = finalFileName:gsub("%.rbxlx$", ""):gsub("%.rbxl$", "") .. ".rbxlx"

    ActionBtn.Active = false
    ActionBtn.Text = "⏳ PROCESSING..."
    ActionBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)

    task.spawn(function()
        setProgress(0.1, "⚙️ [1/5] Initializing memory buffer...")
        task.wait(0.4)

        if gcinfo then pcall(gcinfo) end
        if collectgarbage then pcall(collectgarbage, "collect") end

        setProgress(0.2, "🔍 [2/5] Locating saveinstance function...")
        task.wait(0.3)

        local saveinstance_func = nil

        if getgenv and type(getgenv().saveinstance) == "function" then
            saveinstance_func = getgenv().saveinstance
        elseif type(_G.saveinstance) == "function" then
            saveinstance_func = _G.saveinstance
        elseif syn and type(syn.saveinstance) == "function" then
            saveinstance_func = syn.saveinstance
        end

        if not saveinstance_func then
            setProgress(0.35, "📦 [3/5] Downloading USSI Engine from GitHub...")
            task.wait(0.3)

            local ok, result = pcall(function()
                return game:HttpGet("https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/saveinstance.luau", true)
            end)

            if not ok or not result then
                setProgress(1.0, "❌ Failed to download USSI! Check connection.", Color3.fromRGB(255, 75, 75))
                ActionBtn.Text = "❌ DOWNLOAD FAILED"
                ActionBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
                task.wait(3)
                resetUI()
                return
            end

            local module = loadstring(result)()
            if type(module) == "function" then
                saveinstance_func = module
            elseif type(module) == "table" and type(module.saveinstance) == "function" then
                saveinstance_func = module.saveinstance
            end
        end

        if type(saveinstance_func) ~= "function" then
            setProgress(1.0, "❌ Executor does not support saveinstance!", Color3.fromRGB(255, 75, 75))
            ActionBtn.Text = "❌ NOT SUPPORTED"
            ActionBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
            task.wait(3)
            resetUI()
            return
        end

        setProgress(0.55, "🗂️ [4/5] Analyzing selected filters...")
        task.wait(0.4)

        local selectedObjects = {}
        local allSelected = true
        for _, filter in ipairs(Filters) do
            if filter.Active then
                table.insert(selectedObjects, filter.Target)
            else
                allSelected = false
            end
        end

        -- [ĐÃ SỬA CHỮA Ở ĐÂY] - Tối ưu toàn bộ Options để lấy sạch sẽ
        local Options = {
            noscripts = false,              -- FALSE: Không bỏ qua script, cho phép copy script
            DecompileScripts = true,        -- TRUE: Bật dịch ngược code để lấy nội dung Local/Module Script
            RemovePlayerCharacters = true,  -- Xóa nhân vật người chơi để tránh lưu rác vào map
            SaveWorkspaceTerrain = true,    -- TRUE: Bắt buộc lấy Địa hình (Terrain) để không bị lủng map
            DecompileTimeout = 15,          -- Cho thêm thời gian decompile các script quá nặng
            IsolateStarterPlayer = true,    -- Bảo mật và lấy an toàn thư mục StarterPlayer
            IsBinary = false,               -- Xuất file rbxlx chống lỗi cấu trúc
            Disconnect = false,
            FileName = finalFileName,
        }

        if allSelected or #selectedObjects == 0 then
            Options.mode = "full"
        else
            Options.mode = "custom"
            Options.Objects = selectedObjects
        end

        setProgress(0.8, "💾 [5/5] Writing file: " .. finalFileName .. "... (May take a while!)")
        task.wait(0.5)

        local success, err = pcall(saveinstance_func, Options)

        if success then
            setProgress(1.0, "✔ SUCCESS! Map & Scripts saved to workspace folder.", Color3.fromRGB(0, 255, 150))
            ActionBtn.Text = "✔ EXTRACT COMPLETE"
            ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
            ActionBtn.BorderColor3 = Color3.fromRGB(0, 255, 150)
        else
            setProgress(1.0, "❌ ERROR: " .. tostring(err):sub(1, 45), Color3.fromRGB(255, 75, 75))
            ActionBtn.Text = "❌ EXTRACT FAILED"
            ActionBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
            warn("[USSI Error]", tostring(err))
        end

        task.wait(5)
        resetUI()
        setProgress(0, "⚙️ SYSTEM READY | ALL SERVICES SELECTED")
    end)
end)
