-- =================================================================
-- FIX LAG GAMAT // ANTI-DETECTION // METAMETHOD SPOOFER
-- =================================================================

local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local Mode = "NONE"
local MasterCache = {}

local FoliageKeywords = {"leaf", "leaves", "grass", "bush", "foliage", "plant", "tree", "flower"}

-- CHỐNG XÓA NHÂN VẬT
local function IsCharacter(obj)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and obj:IsDescendantOf(player.Character) then
            return true
        end
    end
    return false
end

-- BỘ LỌC NHẬN DIỆN CÂY CỎ TRANG TRÍ
local function IsFoliage(obj)
    if not obj:IsA("BasePart") then return false end
    
    local name = obj.Name:lower()
    for _, keyword in ipairs(FoliageKeywords) do
        if name:find(keyword) then
            if not name:find("trunk") and not name:find("wood") and not name:find("floor") and not name:find("ground") then
                return true
            end
        end
    end
    return false
end

-- LƯU TRẠNG THÁI GỐC ĐỂ PHỤC HỒI VÀ QUA MẶT ANTI-CHEAT
local function DeepBackup(obj)
    if MasterCache[obj] then return end
    if IsCharacter(obj) then return end
    
    if obj:IsA("BasePart") then
        MasterCache[obj] = {
            Material = obj.Material,
            CastShadow = obj.CastShadow,
            Reflectance = obj.Reflectance,
            Transparency = obj.Transparency
        }
    elseif obj:IsA("Texture") or obj:IsA("Decal") then
        MasterCache[obj] = { Transparency = obj.Transparency }
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") then
        MasterCache[obj] = { Enabled = obj.Enabled }
    elseif obj:IsA("Terrain") then
        MasterCache[obj] = { Decoration = obj.Decoration }
    end
end

-- THỰC THI TỐI ƯU HÓA THÔNG MINH
local function ApplyEngine(obj)
    if IsCharacter(obj) then return end
    
    DeepBackup(obj)
    local data = MasterCache[obj]
    if not data then return end

    if Mode == "POTATO" then
        if obj:IsA("BasePart") then
            if IsFoliage(obj) and obj.CanCollide == false then
                obj.Transparency = 1 
            else
                obj.Material = Enum.Material.SmoothPlastic 
                obj.Transparency = data.Transparency
            end
            obj.CastShadow = false
            obj.Reflectance = 0
        elseif obj:IsA("Texture") or obj:IsA("Decal") then
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") then
            obj.Enabled = false
        elseif obj:IsA("Terrain") then
            obj.Decoration = false
        end
        
    elseif Mode == "BALANCE" then
        if obj:IsA("BasePart") then
            obj.Material = data.Material
            obj.Transparency = data.Transparency
            obj.CastShadow = false
            obj.Reflectance = 0
        elseif obj:IsA("Texture") or obj:IsA("Decal") then
            obj.Transparency = data.Transparency
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") then
            obj.Enabled = data.Enabled
        elseif obj:IsA("Terrain") then
            obj.Decoration = false
        end
        
    elseif Mode == "LIGHT" then
        if obj:IsA("BasePart") then
            obj.Material = data.Material
            obj.Transparency = data.Transparency
            obj.CastShadow = false
            obj.Reflectance = data.Reflectance
        end
        
    elseif Mode == "NONE" then
        if obj:IsA("BasePart") then
            obj.Material = data.Material
            obj.Transparency = data.Transparency
            obj.CastShadow = data.CastShadow
            obj.Reflectance = data.Reflectance
        elseif obj:IsA("Texture") or obj:IsA("Decal") then
            obj.Transparency = data.Transparency
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") then
            obj.Enabled = data.Enabled
        elseif obj:IsA("Terrain") then
            obj.Decoration = data.Decoration
        end
    end
end

-- Real-time listener nạp địa hình mới
Workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.1)
    ApplyEngine(obj)
end)

-- Bộ chuyển đổi chế độ
local function SwitchMode(targetMode)
    Mode = targetMode
    
    local items = {}
    for _, v in ipairs(Workspace:GetDescendants()) do table.insert(items, v) end
    for _, v in ipairs(Lighting:GetDescendants()) do table.insert(items, v) end
    
    task.spawn(function()
        local count = 0
        for i = 1, #items do
            count = count + 1
            if count % 400 == 0 then 
                task.wait() 
            end
            pcall(ApplyEngine, items[i])
        end
    end)
    
    if Mode == "POTATO" or Mode == "BALANCE" then
        Lighting.GlobalShadows = false
    else
        Lighting.GlobalShadows = true
    end
end

-- =================================================================
-- LỚP BẢO VỆ CHỐNG ANTI-CHEAT (SPOOFING LAYER)
-- =================================================================
if hookmetamethod and checkcaller then
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        -- Nếu KHÔNG PHẢI do script này gọi (tức là script anti-cheat của game đang quét)
        if not checkcaller() then 
            -- Nếu vật thể nằm trong bộ nhớ cache đã tối ưu, trả về thông số gốc để lừa game
            if MasterCache[self] and MasterCache[self][key] ~= nil then
                return MasterCache[self][key]
            end
            -- Đánh lừa trạng thái đổ bóng toàn cục của Lighting
            if self == Lighting and key == "GlobalShadows" and (Mode == "POTATO" or Mode == "BALANCE") then
                return true
            end
        end
        return oldIndex(self, key)
    end)
end

-- =================================================================
-- INTERFACE TERMINAL GUI // FIX LAG GAMAT
-- =================================================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "FixLagGamatGui"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 170, 0, 180)
Main.Position = UDim2.new(0.05, 0, 0.5, -90)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Main.BorderSizePixel = 1
Main.BorderColor3 = Color3.fromRGB(70, 70, 75)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "// FIX LAG GAMAT"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.Code
Title.TextSize = 11
Title.BackgroundTransparency = 1

local function CreateBtn(text, pos, color, callback)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0.9, 0, 0, 26)
    b.Position = pos
    b.Text = text
    b.TextColor3 = color
    b.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    b.Font = Enum.Font.Code
    b.TextSize = 10
    b.BorderSizePixel = 1
    b.BorderColor3 = Color3.fromRGB(35, 35, 40)
    b.MouseButton1Click:Connect(callback)
    return b
end

CreateBtn("[ POTATO MODE ]", UDim2.new(0.05, 0, 0.20, 0), Color3.fromRGB(255, 70, 70), function() SwitchMode("POTATO") end)
CreateBtn("[ BALANCE MODE ]", UDim2.new(0.05, 0, 0.38, 0), Color3.fromRGB(255, 180, 50), function() SwitchMode("BALANCE") end)
CreateBtn("[ LIGHT MODE ]", UDim2.new(0.05, 0, 0.56, 0), Color3.fromRGB(100, 200, 255), function() SwitchMode("LIGHT") end)
CreateBtn("[ REAL RESET ]", UDim2.new(0.05, 0, 0.78, 0), Color3.fromRGB(0, 255, 150), function() SwitchMode("NONE") end)

local Toggle = Instance.new("TextButton", ScreenGui)
Toggle.Size = UDim2.new(0, 35, 0, 35)
Toggle.Position = UDim2.new(0, 5, 0.5, -135)
Toggle.Text = "[G]"
Toggle.Font = Enum.Font.Code
Toggle.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.BorderSizePixel = 1
Toggle.BorderColor3 = Color3.fromRGB(70, 70, 75)
Toggle.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)