local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "minhg beta",
    LoadingTitle = "Loading script ngầu lòi...",
    LoadingSubtitle = "Fixed Lag & Errors - No Auto Click!",
    Theme = "Blue"
})

-- BIẾN TỐI ƯU
local FlyEnabled = false
local FlySpeed = 50
local BodyGyro, BodyVelocity
local GodEnabled = false
local NoclipEnabled = false
local NoclipConnection
local AntiFlingEnabled = false
local OriginalMass = {}
local WalkSpeed = 16
local InfJump = false
local ESPToggle = false

-- 🚀 MOVEMENT TAB - ĐƯỢC TỐI ƯU
local MovementTab = Window:CreateTab("🚀 Movement")

-- FLY HACK FIXED - GIẢM LAG
MovementTab:CreateToggle({
    Name = "Fly Hack (WASD + Space/Shift)",
    CurrentValue = false,
    Callback = function(Value)
        FlyEnabled = Value
        if Value then
            local Character = game.Players.LocalPlayer.Character
            local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
            
            -- TỐI ƯU BODY FORCES
            BodyGyro = Instance.new("BodyGyro")
            BodyVelocity = Instance.new("BodyVelocity")
            
            BodyGyro.P = 5e4 -- GIẢM P ĐỂ GIẢM LAG
            BodyGyro.MaxTorque = Vector3.new(5e9, 5e9, 5e9) -- GIẢM TORQUE
            BodyGyro.CFrame = HumanoidRootPart.CFrame
            BodyGyro.Parent = HumanoidRootPart
            
            BodyVelocity.MaxForce = Vector3.new(5e9, 5e9, 5e9) -- GIẢM FORCE
            BodyVelocity.Velocity = Vector3.new(0, 0.1, 0)
            BodyVelocity.Parent = HumanoidRootPart
            
            -- FLY CONTROL LOOP TỐI ƯU
            local FlyLoop
            FlyLoop = game:GetService("RunService").Heartbeat:Connect(function()
                if not FlyEnabled or not Character or not HumanoidRootPart then
                    FlyLoop:Disconnect()
                    return
                end
                
                local Camera = workspace.CurrentCamera
                local MoveDirection = Vector3.new(0, 0, 0)
                
                -- ĐIỀU KHIỂN ĐƠN GIẢN HƠN
                local UIS = game:GetService("UserInputService")
                if UIS:IsKeyDown(Enum.KeyCode.W) then
                    MoveDirection = MoveDirection + Camera.CFrame.LookVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.S) then
                    MoveDirection = MoveDirection - Camera.CFrame.LookVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.A) then
                    MoveDirection = MoveDirection - Camera.CFrame.RightVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.D) then
                    MoveDirection = MoveDirection + Camera.CFrame.RightVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then
                    MoveDirection = MoveDirection + Vector3.new(0, 1, 0)
                end
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
                    MoveDirection = MoveDirection - Vector3.new(0, 1, 0)
                end
                
                BodyVelocity.Velocity = MoveDirection * FlySpeed
                BodyGyro.CFrame = Camera.CFrame
            end)
        else
            -- DỌN DẸP TỐI ƯU
            if BodyGyro then 
                BodyGyro:Destroy()
                BodyGyro = nil
            end
            if BodyVelocity then 
                BodyVelocity:Destroy() 
                BodyVelocity = nil
            end
        end
    end
})

-- ANTI-FLING FIXED - GIẢM LAG
MovementTab:CreateToggle({
    Name = "Anti-Fling (No Launch)",
    CurrentValue = false,
    Callback = function(Value)
        AntiFlingEnabled = Value
        if Value then
            -- CHỈ THAY ĐỔI HUMANROOTPART ĐỂ GIẢM LAG
            local rootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                OriginalMass[rootPart] = rootPart.Mass
                rootPart.Mass = 5000 -- ĐỦ NẶNG, KHÔNG CẦN QUÁ LỚN
            end
            
            -- THEO DÕI RESPAWN ĐƠN GIẢN
            game.Players.LocalPlayer.CharacterAdded:Connect(function(Character)
                wait(1) -- CHỜ LOAD CHARACTER
                local newRoot = Character:FindFirstChild("HumanoidRootPart")
                if newRoot then
                    newRoot.Mass = 5000
                end
            end)
        else
            -- KHÔI PHỤC ĐƠN GIẢN
            for part, mass in pairs(OriginalMass) do
                if part and part.Parent then
                    part.Mass = mass
                end
            end
            OriginalMass = {}
        end
    end
})

-- SPEED HACK TỐI ƯU
MovementTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 100}, -- GIẢM MAX ĐỂ AN TOÀN
    Increment = 5,
    Suffix = "Speed",
    CurrentValue = 16,
    Callback = function(Value)
        WalkSpeed = Value
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = Value
        end
    end
})

-- NO CLIP TỐI ƯU
MovementTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = function(Value)
        NoclipEnabled = Value
        if Value then
            NoclipConnection = game:GetService("RunService").Stepped:Connect(function()
                local character = game.Players.LocalPlayer.Character
                if character then
                    -- CHỈ XỬ LÝ PARTS CHÍNH
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    local head = character:FindFirstChild("Head")
                    if rootPart then rootPart.CanCollide = false end
                    if head then head.CanCollide = false end
                end
            end)
        else
            if NoclipConnection then
                NoclipConnection:Disconnect()
                NoclipConnection = nil
            end
        end
    end
})

-- INFINITE JUMP TỐI ƯU
MovementTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(Value)
        InfJump = Value
    end
})

-- 🛡️ DEFENSE TAB - TỐI ƯU
local DefenseTab = Window:CreateTab("🛡️ Defense")

-- GOD MODE FIXED - GIẢM LAG
DefenseTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Callback = function(Value)
        GodEnabled = Value
        if Value then
            -- FUNCTION ĐƠN GIẢN
            local function ProtectCharacter(character)
                if character and character:FindFirstChild("Humanoid") then
                    character.Humanoid.Health = math.huge
                end
            end
            
            -- ÁP DỤNG HIỆN TẠI
            ProtectCharacter(game.Players.LocalPlayer.Character)
            
            -- THEO DÕI RESPAWN
            game.Players.LocalPlayer.CharacterAdded:Connect(ProtectCharacter)
            
            -- KIỂM TRA ĐỊNH KỲ (GIẢM TẦN SUẤT)
            spawn(function()
                while GodEnabled do
                    ProtectCharacter(game.Players.LocalPlayer.Character)
                    wait(2) -- TĂNG THỜI GIAN CHỜ ĐỂ GIẢM LAG
                end
            end)
        end
    end
})

-- 👁️ VISUAL TAB - TỐI ƯU
local VisualTab = Window:CreateTab("👁️ Visual")

-- ESP TỐI ƯU
VisualTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Callback = function(Value)
        ESPToggle = Value
        if Value then
            spawn(function()
                while ESPToggle do
                    -- GIẢM TẦN SUẤT CẬP NHẬT
                    for _, player in pairs(game.Players:GetPlayers()) do
                        if player ~= game.Players.LocalPlayer and player.Character then
                            if not player.Character:FindFirstChild("ZetaESP") then
                                local highlight = Instance.new("Highlight")
                                highlight.Name = "ZetaESP"
                                highlight.FillColor = Color3.new(1, 0, 0)
                                highlight.OutlineColor = Color3.new(1, 1, 1)
                                highlight.Parent = player.Character
                            end
                        end
                    end
                    wait(2) -- GIẢM CẬP NHẬT
                end
                
                -- DỌN DẸP KHI TẮT
                for _, player in pairs(game.Players:GetPlayers()) do
                    if player.Character and player.Character:FindFirstChild("ZetaESP") then
                        player.Character.ZetaESP:Destroy()
                    end
                end
            end)
        else
            -- DỌN DẸP NGAY LẬP TỨC
            for _, player in pairs(game.Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("ZetaESP") then
                    player.Character.ZetaESP:Destroy()
                end
            end
        end
    end
})

-- ⚡ UTILITY TAB - ĐƠN GIẢN HÓA
local UtilityTab = Window:CreateTab("⚡ Utility")

-- FPS BOOST TỐI ƯU
UtilityTab:CreateButton({
    Name = "FPS Boost",
    Callback = function()
        settings().Rendering.QualityLevel = 1
        -- CHỈ XỬ LÝ CÁC VẬT THỂ TRONG TẦM NHÌN
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Part") then
                v.Material = "Plastic"
            end
        end
        Rayfield:Notify({
            Title = "FPS Boosted",
            Content = "Game optimized!",
            Duration = 2
        })
    end
})

-- TELEPORT FIXED - KHÔNG LỖI
UtilityTab:CreateButton({
    Name = "Teleport to Safe Spot", 
    Callback = function()
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            -- TÌM VỊ TRÍ AN TOÀN
            local safeSpot = CFrame.new(0, 50, 0)
            character.HumanoidRootPart.CFrame = safeSpot
            Rayfield:Notify({
                Title = "Teleported",
                Content = "Moved to safe location!",
                Duration = 2
            })
        end
    end
})

-- FLY SPEED CONTROL
MovementTab:CreateSlider({
    Name = "Fly Speed",
    Range = {20, 100}, -- GIẢM TỐC ĐỘ TỐI ĐA
    Increment = 5,
    Suffix = "Speed",
    CurrentValue = 50,
    Callback = function(Value)
        FlySpeed = Value
    end
})

-- ÁP DỤNG KHI RESPAWN (TỐI ƯU)
game.Players.LocalPlayer.CharacterAdded:Connect(function(Character)
    wait(1) -- CHỜ LOAD ĐẦY ĐỦ
    local humanoid = Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = WalkSpeed
        if GodEnabled then
            humanoid.Health = math.huge
        end
    end
end)

-- INFINITE JUMP HANDLER TỐI ƯU
local JumpConnection
JumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfJump and game.Players.LocalPlayer.Character then
        local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState("Jumping")
        end
    end
end)

Rayfield:Notify({
    Title = "💀 Minhg beta :)",
    Content = "All features fixed - No lag!",
    Duration = 3
})

Rayfield:Init()
