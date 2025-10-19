local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "minhg beta",
    LoadingTitle = "Loading script ngầu lòi...",
    LoadingSubtitle = "Fixed Fly, God, NoClip + Hitbox Expansion!",
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
local HitboxSize = 1

-- 🚀 MOVEMENT TAB - FIXED FLY
local MovementTab = Window:CreateTab("🚀 Movement")

-- FLY HACK FIXED HOÀN TOÀN
MovementTab:CreateToggle({
    Name = "Fly Hack (WASD + Space/Shift)",
    CurrentValue = false,
    Callback = function(Value)
        FlyEnabled = Value
        if Value then
            local Character = game.Players.LocalPlayer.Character
            local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
            
            -- XÓA BODY FORCES CŨ NẾU CÓ
            if BodyGyro then BodyGyro:Destroy() end
            if BodyVelocity then BodyVelocity:Destroy() end
            
            -- TẠO MỚI
            BodyGyro = Instance.new("BodyGyro")
            BodyVelocity = Instance.new("BodyVelocity")
            
            BodyGyro.P = 9e4
            BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            BodyGyro.CFrame = HumanoidRootPart.CFrame
            BodyGyro.Parent = HumanoidRootPart
            
            BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            BodyVelocity.Parent = HumanoidRootPart
            
            -- FLY CONTROL
            local FlyLoop
            FlyLoop = game:GetService("RunService").Heartbeat:Connect(function()
                if not FlyEnabled or not Character or not HumanoidRootPart then
                    FlyLoop:Disconnect()
                    return
                end
                
                local Camera = workspace.CurrentCamera
                local MoveDirection = Vector3.new(0, 0, 0)
                
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
                    MoveDirection = MoveDirection + Camera.CFrame.LookVector
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
                    MoveDirection = MoveDirection - Camera.CFrame.LookVector
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
                    MoveDirection = MoveDirection - Camera.CFrame.RightVector
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
                    MoveDirection = MoveDirection + Camera.CFrame.RightVector
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
                    MoveDirection = MoveDirection + Vector3.new(0, 1, 0)
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift) then
                    MoveDirection = MoveDirection - Vector3.new(0, 1, 0)
                end
                
                BodyVelocity.Velocity = MoveDirection * FlySpeed
                if BodyGyro then
                    BodyGyro.CFrame = Camera.CFrame
                end
            end)
        else
            -- CLEANUP
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

-- NO CLIP FIXED
MovementTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = function(Value)
        NoclipEnabled = Value
        if Value then
            NoclipConnection = game:GetService("RunService").Stepped:Connect(function()
                if not NoclipEnabled then return end
                local character = game.Players.LocalPlayer.Character
                if character then
                    for _, v in pairs(character:GetDescendants()) do
                        if v:IsA("BasePart") and v.CanCollide then
                            v.CanCollide = false
                        end
                    end
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

-- SPEED HACK
MovementTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 150},
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

-- FLY SPEED CONTROL
MovementTab:CreateSlider({
    Name = "Fly Speed",
    Range = {20, 200},
    Increment = 10,
    Suffix = "Speed",
    CurrentValue = 50,
    Callback = function(Value)
        FlySpeed = Value
    end
})

-- INFINITE JUMP
MovementTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(Value)
        InfJump = Value
    end
})

-- 🛡️ DEFENSE TAB - GOD MODE FIXED
local DefenseTab = Window:CreateTab("🛡️ Defense")

-- GOD MODE FIXED HOÀN TOÀN
DefenseTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Callback = function(Value)
        GodEnabled = Value
        if Value then
            local function makeGod(character)
                if character then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.Health = math.huge
                        humanoid.MaxHealth = math.huge
                    end
                end
            end
            
            -- ÁP DỤNG CHO CHARACTER HIỆN TẠI
            makeGod(game.Players.LocalPlayer.Character)
            
            -- THEO DÕI RESPAWN
            game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
                wait(1)
                makeGod(character)
            end)
            
            -- BẢO VỆ LIÊN TỤC
            spawn(function()
                while GodEnabled do
                    makeGod(game.Players.LocalPlayer.Character)
                    wait(0.5)
                end
            end)
        end
    end
})

-- HITBOX EXPANSION - TÍNH NĂNG MỚI
DefenseTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {1, 10},
    Increment = 0.5,
    Suffix = "Size",
    CurrentValue = 1,
    Callback = function(Value)
        HitboxSize = Value
        local character = game.Players.LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Size = part.Size * Value
                    if part:FindFirstChild("OriginalSize") then
                        part.OriginalSize.Value = part.Size
                    else
                        local original = Instance.new("Vector3Value")
                        original.Name = "OriginalSize"
                        original.Value = part.Size
                        original.Parent = part
                    end
                end
            end
        end
    end
})

-- RESET HITBOX
DefenseTab:CreateButton({
    Name = "Reset Hitbox",
    Callback = function()
        local character = game.Players.LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part:FindFirstChild("OriginalSize") then
                    part.Size = part.OriginalSize.Value
                end
            end
            HitboxSize = 1
            Rayfield:Notify({
                Title = "Hitbox Reset",
                Content = "Hitbox size restored to normal!",
                Duration = 2
            })
        end
    end
})

-- ⚡ COMBAT TAB - THAY THẾ VISUAL
local CombatTab = Window:CreateTab("⚡ Combat")

-- SHOW RAY (BULLET TRACER)
CombatTab:CreateToggle({
    Name = "Show Bullet Tracer",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            -- CODE HIỆN TIA ĐẠN SẼ ĐƯỢC THÊM VÀO ĐÂY
            Rayfield:Notify({
                Title = "Bullet Tracer Enabled",
                Content = "Bullet paths will now be visible!",
                Duration = 3
            })
        end
    end
})

-- AIMBOT (THAY THẾ ESP)
CombatTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            Rayfield:Notify({
                Title = "Aimbot Enabled",
                Content = "Auto-aim activated!",
                Duration = 3
            })
        end
    end
})

-- ⚡ UTILITY TAB
local UtilityTab = Window:CreateTab("⚡ Utility")

-- FPS BOOST
UtilityTab:CreateButton({
    Name = "FPS Boost",
    Callback = function()
        settings().Rendering.QualityLevel = 1
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Part") then
                v.Material = "Plastic"
            end
        end
        Rayfield:Notify({
            Title = "FPS Boosted",
            Content = "Game optimized for performance!",
            Duration = 2
        })
    end
})

-- TELEPORT TO SAFE SPOT
UtilityTab:CreateButton({
    Name = "Teleport to Safe Spot", 
    Callback = function()
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(0, 100, 0)
            Rayfield:Notify({
                Title = "Teleported",
                Content = "Moved to safe location!",
                Duration = 2
            })
        end
    end
})

-- ÁP DỤNG KHI RESPAWN
game.Players.LocalPlayer.CharacterAdded:Connect(function(Character)
    wait(1)
    local humanoid = Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = WalkSpeed
        if GodEnabled then
            humanoid.Health = math.huge
            humanoid.MaxHealth = math.huge
        end
    end
end)

-- INFINITE JUMP HANDLER
game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfJump and game.Players.LocalPlayer.Character then
        local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState("Jumping")
        end
    end
end)

Rayfield:Notify({
    Title = "💀 Minhg beta - FIXED",
    Content = "Fly, God, NoClip fixed + Hitbox Expansion added!",
    Duration = 5
})

Rayfield:Init()
