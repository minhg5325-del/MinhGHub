local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "minhg beta - FULL FEATURES",
    LoadingTitle = "Loading full script...",
    LoadingSubtitle = "All features + TikTok Fly + Enemy Hitbox!",
    Theme = "Blue"
})

-- BIẾN
local FlyEnabled = false
local FlySpeed = 50
local BodyVelocity
local GodEnabled = false
local NoclipEnabled = false
local WalkSpeed = 16
local JumpPower = 50
local InfJump = false
local HitboxSize = 1
local EnemyHitboxes = {}
local AntiFlingEnabled = false
local OriginalMass = {}
local ESPEnabled = false
local AimbotEnabled = false

-- 🚀 MOVEMENT TAB - FLY TIKTOK STYLE
local MovementTab = Window:CreateTab("🚀 Movement")

-- FLY CHUẨN TIKTOK (C-FLY STYLE)
MovementTab:CreateToggle({
    Name = "TikTok Fly (C để bay)",
    CurrentValue = false,
    Callback = function(Value)
        FlyEnabled = Value
        if Value then
            local Character = game.Players.LocalPlayer.Character
            local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
            
            -- XÓA CŨ
            if BodyVelocity then BodyVelocity:Destroy() end
            
            -- TẠO FLY KIỂU MỚI
            BodyVelocity = Instance.new("BodyVelocity")
            BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            BodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
            BodyVelocity.Parent = HumanoidRootPart
            
            -- BIẾN ĐIỀU KHIỂN
            local flying = true
            local speed = FlySpeed
            
            -- C-FLY CONTROLS
            local function updateFly()
                if not FlyEnabled or not BodyVelocity then return end
                
                local Camera = workspace.CurrentCamera
                local moveDirection = Vector3.new(0, 0, 0)
                local UIS = game:GetService("UserInputService")
                
                -- ĐIỀU KHIỂN WASD + SPACE/SHIFT
                if UIS:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + Camera.CFrame.LookVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - Camera.CFrame.LookVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - Camera.CFrame.RightVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + Camera.CFrame.RightVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                end
                
                -- CẬP NHẬT VẬN TỐC
                if BodyVelocity then
                    BodyVelocity.Velocity = moveDirection * speed
                end
            end
            
            -- FLY LOOP
            local flyLoop
            flyLoop = game:GetService("RunService").Heartbeat:Connect(function()
                updateFly()
            end)
            
            -- TOGGLE FLY BẰNG C
            game:GetService("UserInputService").InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.C then
                    flying = not flying
                    if BodyVelocity then
                        BodyVelocity.Velocity = Vector3.new(0, flying and 0.1 or 0, 0)
                    end
                end
            end)
            
        else
            -- TẮT FLY
            if BodyVelocity then 
                BodyVelocity:Destroy()
                BodyVelocity = nil
            end
        end
    end
})

-- FLY SPEED
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

-- JUMP POWER
MovementTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 200},
    Increment = 10,
    Suffix = "Power",
    CurrentValue = 50,
    Callback = function(Value)
        JumpPower = Value
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.JumpPower = Value
        end
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

-- NO CLIP
MovementTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = function(Value)
        NoclipEnabled = Value
        if Value then
            local noclipLoop
            noclipLoop = game:GetService("RunService").Stepped:Connect(function()
                if not NoclipEnabled then
                    noclipLoop:Disconnect()
                    return
                end
                local character = game.Players.LocalPlayer.Character
                if character then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    end
})

-- ANTI-FLING
MovementTab:CreateToggle({
    Name = "Anti-Fling",
    CurrentValue = false,
    Callback = function(Value)
        AntiFlingEnabled = Value
        if Value then
            local character = game.Players.LocalPlayer.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        OriginalMass[part] = part.Mass
                        part.Mass = 5000
                    end
                end
            end
            
            -- RESPAWN PROTECTION
            game.Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
                wait(1)
                for _, part in pairs(newChar:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Mass = 5000
                    end
                end
            end)
        else
            -- RESTORE MASS
            for part, mass in pairs(OriginalMass) do
                if part and part.Parent then
                    part.Mass = mass
                end
            end
            OriginalMass = {}
        end
    end
})

-- 🎯 HITBOX TAB - CHO KẺ ĐỊCH
local HitboxTab = Window:CreateTab("🎯 Hitbox")

-- HITBOX EXPANSION CHO ENEMY
HitboxTab:CreateSlider({
    Name = "Enemy Hitbox Size",
    Range = {1, 15},
    Increment = 0.5,
    Suffix = "Size",
    CurrentValue = 1,
    Callback = function(Value)
        HitboxSize = Value
        
        -- XÓA HỘP CŨ
        for player, data in pairs(EnemyHitboxes) do
            if data.box then data.box:Destroy() end
        end
        EnemyHitboxes = {}
        
        -- ÁP DỤNG CHO TẤT CẢ ENEMY
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                applyEnemyHitbox(player, Value)
            end
        end
    end
})

-- FUNCTION ÁP DỤNG HITBOX ENEMY
function applyEnemyHitbox(player, size)
    if not player.Character then return end
    
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- TẠO HỘP HITBOX
    local hitbox = Instance.new("Part")
    hitbox.Name = "EnemyHitbox"
    hitbox.Size = Vector3.new(5 * size, 7 * size, 5 * size)
    hitbox.Transparency = 0.7
    hitbox.Color = Color3.new(1, 0, 0)
    hitbox.Material = "Neon"
    hitbox.CanCollide = false
    hitbox.Anchored = false
    hitbox.Parent = player.Character
    
    -- WELD VÀO ROOT PART
    local weld = Instance.new("Weld")
    weld.Part0 = rootPart
    weld.Part1 = hitbox
    weld.C0 = CFrame.new(0, 0, 0)
    weld.Parent = hitbox
    
    -- LƯU VÀO TABLE
    EnemyHitboxes[player] = {box = hitbox, size = size}
    
    -- THEO DÕI RESPAWN
    player.CharacterAdded:Connect(function(newChar)
        wait(1)
        applyEnemyHitbox(player, size)
    end)
end

-- RESET ENEMY HITBOX
HitboxTab:CreateButton({
    Name = "Reset Enemy Hitbox",
    Callback = function()
        for player, data in pairs(EnemyHitboxes) do
            if data.box then 
                data.box:Destroy()
            end
        end
        EnemyHitboxes = {}
        HitboxSize = 1
    end
})

-- HITBOX TRANSPARENCY
HitboxTab:CreateSlider({
    Name = "Hitbox Transparency",
    Range = {0, 1},
    Increment = 0.1,
    Suffix = "Alpha",
    CurrentValue = 0.7,
    Callback = function(Value)
        for player, data in pairs(EnemyHitboxes) do
            if data.box then
                data.box.Transparency = Value
            end
        end
    end
})

-- 🛡️ DEFENSE TAB
local DefenseTab = Window:CreateTab("🛡️ Defense")

-- GOD MODE
DefenseTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Callback = function(Value)
        GodEnabled = Value
        if Value then
            local function makeGod()
                local character = game.Players.LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.Health = math.huge
                        humanoid.MaxHealth = math.huge
                    end
                end
            end
            
            makeGod()
            
            -- BẢO VỆ LIÊN TỤC
            local godLoop
            godLoop = game:GetService("RunService").Heartbeat:Connect(function()
                if not GodEnabled then
                    godLoop:Disconnect()
                    return
                end
                makeGod()
            end)
            
            -- RESPAWN PROTECTION
            game.Players.LocalPlayer.CharacterAdded:Connect(function()
                wait(1)
                makeGod()
            end)
        end
    end
})

-- 👁️ VISUAL TAB
local VisualTab = Window:CreateTab("👁️ Visual")

-- ESP PLAYER
VisualTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Callback = function(Value)
        ESPEnabled = Value
        if Value then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character then
                    createESP(player)
                end
            end
        else
            for _, player in pairs(game.Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("ESPBox") then
                    player.Character.ESPBox:Destroy()
                end
            end
        end
    end
})

-- FUNCTION TẠO ESP
function createESP(player)
    if not player.Character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPBox"
    highlight.FillColor = Color3.new(1, 0, 0)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    highlight.Parent = player.Character
    
    player.CharacterAdded:Connect(function(newChar)
        wait(1)
        if ESPEnabled then
            createESP(player)
        end
    end)
end

-- ⚡ COMBAT TAB
local CombatTab = Window:CreateTab("⚡ Combat")

-- AIMBOT
CombatTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Callback = function(Value)
        AimbotEnabled = Value
        if Value then
            local aimLoop
            aimLoop = game:GetService("RunService").Heartbeat:Connect(function()
                if not AimbotEnabled then
                    aimLoop:Disconnect()
                    return
                end
                
                local closestPlayer = nil
                local closestDistance = math.huge
                local localChar = game.Players.LocalPlayer.Character
                if not localChar then return end
                
                local localPos = localChar.HumanoidRootPart.Position
                
                for _, player in pairs(game.Players:GetPlayers()) do
                    if player ~= game.Players.LocalPlayer and player.Character then
                        local targetPos = player.Character.HumanoidRootPart.Position
                        local distance = (localPos - targetPos).Magnitude
                        
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
                
                if closestPlayer and closestPlayer.Character then
                    local targetHead = closestPlayer.Character:FindFirstChild("Head")
                    if targetHead then
                        workspace.CurrentCamera.CFrame = CFrame.new(
                            workspace.CurrentCamera.CFrame.Position,
                            targetHead.Position
                        )
                    end
                end
            end)
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
            Content = "Game optimized!",
            Duration = 3
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
        humanoid.JumpPower = JumpPower
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
    Title = "🎯 FULL FEATURES LOADED!",
    Content = "TikTok Fly + Enemy Hitbox + All old features!",
    Duration = 6
})

Rayfield:Init()
