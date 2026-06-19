-- Universal Script: Fly + WalkSpeed + Toggle GUI (key M)
-- Управление: F — полёт, M — показать/скрыть меню,
-- колёсико мыши — скорость полёта, слайдер — WalkSpeed

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- === НАСТРОЙКИ ===
local flySpeed = 50
local walkSpeed = 32
local flying = false
local guiVisible = true
local bv, bg

-- === GUI ===
local screenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
screenGui.Name = "FlySpeedGUI"

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 240, 0, 130)
mainFrame.Position = UDim2.new(0, 20, 0, 140)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0.15
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Fly + Speed"
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1

local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0.4, 0)
statusLabel.Text = "Fly: OFF (F)"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.BackgroundTransparency = 1

local wsLabel = Instance.new("TextLabel", mainFrame)
wsLabel.Size = UDim2.new(0.6, 0, 0, 25)
wsLabel.Position = UDim2.new(0, 10, 0.7, 0)
wsLabel.Text = "WalkSpeed: " .. walkSpeed
wsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
wsLabel.Font = Enum.Font.Gotham
wsLabel.BackgroundTransparency = 1

local wsSlider = Instance.new("TextBox", mainFrame)
wsSlider.Size = UDim2.new(0.25, 0, 0, 25)
wsSlider.Position = UDim2.new(0.7, 0, 0.7, 0)
wsSlider.Text = tostring(walkSpeed)
wsSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
wsSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
wsSlider.Font = Enum.Font.Gotham
wsSlider.PlaceholderText = "Speed"

wsSlider.FocusLost:Connect(function()
    local newSpeed = tonumber(wsSlider.Text)
    if newSpeed and newSpeed > 0 and newSpeed <= 200 then
        walkSpeed = newSpeed
        wsLabel.Text = "WalkSpeed: " .. walkSpeed
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = walkSpeed
        end
    else
        wsSlider.Text = tostring(walkSpeed)
    end
end)

-- === ФУНКЦИЯ ПОЛЁТА ===
local function startFly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    flying = true
    statusLabel.Text = "Fly: ON"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    
    local root = char.HumanoidRootPart
    local hum = char.Humanoid
    hum.PlatformStand = true
    
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = root
    
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bg.Parent = root
    
    local flyConnection
    flyConnection = RunService.Heartbeat:Connect(function()
        if not flying or not root.Parent then
            flyConnection:Disconnect()
            return
        end
        local moveDirection = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + (Camera.CFrame.LookVector * Vector3.new(1, 0, 1))
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - (Camera.CFrame.LookVector * Vector3.new(1, 0, 1))
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - (Camera.CFrame.RightVector * Vector3.new(1, 0, 1))
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + (Camera.CFrame.RightVector * Vector3.new(1, 0, 1))
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * flySpeed
        end
        bv.Velocity = moveDirection
        bg.CFrame = Camera.CFrame
    end)
end

local function stopFly()
    flying = false
    statusLabel.Text = "Fly: OFF"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.PlatformStand = false
    end
end

-- === УПРАВЛЕНИЕ ПОЛЁТОМ (F) ===
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        if flying then
            stopFly()
        else
            startFly()
        end
    end
end)

-- === ХОТКЕЙ ДЛЯ GUI (M) ===
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.M then
        guiVisible = not guiVisible
        screenGui.Enabled = guiVisible
    end
end)

-- === РЕГУЛИРОВКА СКОРОСТИ ПОЛЁТА (колёсико) ===
Mouse.WheelForward:Connect(function()
    flySpeed = math.min(flySpeed + 10, 500)
end)
Mouse.WheelBackward:Connect(function()
    flySpeed = math.max(flySpeed - 10, 10)
end)

-- === ПРИМЕНЕНИЕ WalkSpeed ===
LocalPlayer.CharacterAdded:Connect(function(char)
    wait(0.5)
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        hum.WalkSpeed = walkSpeed
    end
end)

-- Первичный запуск
if LocalPlayer.Character then
    wait(0.5)
    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then
        hum.WalkSpeed = walkSpeed
    end
end

print("Скрипт загружен. F — полёт, M — показать/скрыть меню, колёсико — скорость полёта.")  
  
