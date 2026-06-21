-- Modern GUI: Fly + Speed + Noclip + JumpPower
-- Управление: F — полёт, M — показать/скрыть меню, клик по заголовку — перетаскивание

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- === НАСТРОЙКИ ===
local flySpeed = 50
local walkSpeed = 32
local jumpPower = 50
local flying = false
local noclip = false
local guiVisible = true
local bv, bg, noclipConnection

-- === СОЗДАНИЕ GUI ===
local screenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
screenGui.Name = "ModernMenu"

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 340, 0, 380)
mainFrame.Position = UDim2.new(0.5, -170, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Тень (эффект) 
local shadow = Instance.new("Frame", mainFrame)
shadow.Size = UDim2.new(1, 0, 1, 0)
shadow.Position = UDim2.new(0, 0, 0, 0)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.5
shadow.BorderSizePixel = 0
shadow.ZIndex = 0
Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 12)

-- Заголовок (перетаскивание)
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
titleBar.BackgroundTransparency = 0.1
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)
local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.Text = "⚡ CONTROL PANEL"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.BackgroundTransparency = 1
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Position = UDim2.new(0, 15, 0, 0)

-- Кнопка закрытия (скрыть)
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.BackgroundTransparency = 1
closeBtn.BorderSizePixel = 0
closeBtn.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    screenGui.Enabled = guiVisible
end)

-- === ВКЛАДКИ ===
local tabBar = Instance.new("Frame", mainFrame)
tabBar.Size = UDim2.new(1, 0, 0, 35)
tabBar.Position = UDim2.new(0, 0, 0, 40)
tabBar.BackgroundTransparency = 1

local tabs = {"Fly", "Speed", "Extra"}
local tabButtons = {}
local currentTab = "Fly"

local function createTabButton(name, position)
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(0, 100, 1, 0)
    btn.Position = UDim2.new(0, position, 0, 0)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    return btn
end

for i, name in ipairs(tabs) do
    local btn = createTabButton(name, (i-1)*105 + 10)
    tabButtons[name] = btn
    btn.MouseButton1Click:Connect(function()
        currentTab = name
        for _, b in pairs(tabButtons) do
            b.TextColor3 = Color3.fromRGB(180, 180, 200)
        end
        btn.TextColor3 = Color3.fromRGB(100, 200, 255)
        -- Обновить содержимое
        updateContent(name)
    end)
end
-- Выделить первую вкладку
tabButtons["Fly"].TextColor3 = Color3.fromRGB(100, 200, 255)

-- Контентная область
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, -20, 1, -110)
contentFrame.Position = UDim2.new(0, 10, 0, 80)
contentFrame.BackgroundTransparency = 1

-- === ФУНКЦИЯ ОБНОВЛЕНИЯ КОНТЕНТА ===
local function updateContent(tab)
    -- Очистить старые элементы
    for _, child in pairs(contentFrame:GetChildren()) do
        child:Destroy()
    end
    
    if tab == "Fly" then
        -- Переключатель полёта
        local flyToggle = Instance.new("TextButton", contentFrame)
        flyToggle.Size = UDim2.new(1, 0, 0, 40)
        flyToggle.Position = UDim2.new(0, 0, 0, 0)
        flyToggle.BackgroundColor3 = flying and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(60, 60, 80)
        Instance.new("UICorner", flyToggle).CornerRadius = UDim.new(0, 8)
        flyToggle.Text = flying and "✈️ FLY: ON" or "✈️ FLY: OFF"
        flyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        flyToggle.Font = Enum.Font.GothamBold
        flyToggle.TextSize = 16
        flyToggle.MouseButton1Click:Connect(function()
            if flying then stopFly() else startFly() end
            flyToggle.Text = flying and "✈️ FLY: ON" or "✈️ FLY: OFF"
            flyToggle.BackgroundColor3 = flying and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(60, 60, 80)
        end)
        
        -- Скорость полёта (слайдер)
        local flySpeedLabel = Instance.new("TextLabel", contentFrame)
        flySpeedLabel.Size = UDim2.new(1, 0, 0, 25)
        flySpeedLabel.Position = UDim2.new(0, 0, 0, 50)
        flySpeedLabel.Text = "Fly Speed: " .. flySpeed
        flySpeedLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
        flySpeedLabel.Font = Enum.Font.Gotham
        flySpeedLabel.TextSize = 14
        flySpeedLabel.BackgroundTransparency = 1
        
        local flySlider = Instance.new("TextBox", contentFrame)
        flySlider.Size = UDim2.new(1, 0, 0, 30)
        flySlider.Position = UDim2.new(0, 0, 0, 75)
        flySlider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        Instance.new("UICorner", flySlider).CornerRadius = UDim.new(0, 6)
        flySlider.Text = tostring(flySpeed)
        flySlider.TextColor3 = Color3.fromRGB(255, 255, 255)
        flySlider.Font = Enum.Font.Gotham
        flySlider.TextSize = 14
        flySlider.FocusLost:Connect(function()
            local val = tonumber(flySlider.Text)
            if val and val >= 10 and val <= 500 then
                flySpeed = val
                flySpeedLabel.Text = "Fly Speed: " .. flySpeed
            else
                flySlider.Text = tostring(flySpeed)
            end
        end)
        
    elseif tab == "Speed" then
        -- WalkSpeed
        local wsLabel = Instance.new("TextLabel", contentFrame)
        wsLabel.Size = UDim2.new(1, 0, 0, 25)
        wsLabel.Position = UDim2.new(0, 0, 0, 0)
        wsLabel.Text = "Walk Speed: " .. walkSpeed
        wsLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
        wsLabel.Font = Enum.Font.Gotham
        wsLabel.TextSize = 14
        wsLabel.BackgroundTransparency = 1
        
        local wsSlider = Instance.new("TextBox", contentFrame)
        wsSlider.Size = UDim2.new(1, 0, 0, 30)
        wsSlider.Position = UDim2.new(0, 0, 0, 25)
        wsSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        Instance.new("UICorner", wsSlider).CornerRadius = UDim.new(0, 6)
        wsSlider.Text = tostring(walkSpeed)
        wsSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
        wsSlider.Font = Enum.Font.Gotham
        wsSlider.TextSize = 14
        wsSlider.FocusLost:Connect(function()
            local val = tonumber(wsSlider.Text)
            if val and val >= 0 and val <= 200 then
                walkSpeed = val
                wsLabel.Text = "Walk Speed: " .. walkSpeed
                applyWalkSpeed()
            else
                wsSlider.Text = tostring(walkSpeed)
            end
        end)
        
        -- JumpPower
        local jpLabel = Instance.new("TextLabel", contentFrame)
        jpLabel.Size = UDim2.new(1, 0, 0, 25)
        jpLabel.Position = UDim2.new(0, 0, 0, 65)
        jpLabel.Text = "Jump Power: " .. jumpPower
        jpLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
        jpLabel.Font = Enum.Font.Gotham
        jpLabel.TextSize = 14
        jpLabel.BackgroundTransparency = 1
        
        local jpSlider = Instance.new("TextBox", contentFrame)
        jpSlider.Size = UDim2.new(1, 0, 0, 30)
        jpSlider.Position = UDim2.new(0, 0, 0, 90)
        jpSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        Instance.new("UICorner", jpSlider).CornerRadius = UDim.new(0, 6)
        jpSlider.Text = tostring(jumpPower)
        jpSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
        jpSlider.Font = Enum.Font.Gotham
        jpSlider.TextSize = 14
        jpSlider.FocusLost:Connect(function()
            local val = tonumber(jpSlider.Text)
            if val and val >= 0 and val <= 500 then
                jumpPower = val
                jpLabel.Text = "Jump Power: " .. jumpPower
                applyJumpPower()
            else
                jpSlider.Text = tostring(jumpPower)
            end
        end)
        
    elseif tab == "Extra" then
        -- Noclip toggle
        local noclipBtn = Instance.new("TextButton", contentFrame)
        noclipBtn.Size = UDim2.new(1, 0, 0, 40)
        noclipBtn.Position = UDim2.new(0, 0, 0, 0)
        noclipBtn.BackgroundColor3 = noclip and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(60, 60, 80)
        Instance.new("UICorner", noclipBtn).CornerRadius = UDim.new(0, 8)
        noclipBtn.Text = noclip and "🛡️ NOCLIP: ON" or "🛡️ NOCLIP: OFF"
        noclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        noclipBtn.Font = Enum.Font.GothamBold
        noclipBtn.TextSize = 16
        noclipBtn.MouseButton1Click:Connect(function()
            noclip = not noclip
            noclipBtn.Text = noclip and "🛡️ NOCLIP: ON" or "🛡️ NOCLIP: OFF"
            noclipBtn.BackgroundColor3 = noclip and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(60, 60, 80)
            if noclip then
                enableNoclip()
            else
                disableNoclip()
            end
        end)
        
        -- Информация
        local info = Instance.new("TextLabel", contentFrame)
        info.Size = UDim2.new(1, 0, 0, 60)
        info.Position = UDim2.new(0, 0, 0, 55)
        info.Text = "Hotkeys:\nF - Fly toggle\nM - Hide/show menu"
        info.TextColor3 = Color3.fromRGB(180, 180, 200)
        info.Font = Enum.Font.Gotham
        info.TextSize = 13
        info.BackgroundTransparency = 1
        info.TextXAlignment = Enum.TextXAlignment.Left
    end
end

-- === ФУНКЦИИ ПОЛЁТА ===
function startFly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    flying = true
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

function stopFly()
    flying = false
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.PlatformStand = false
    end
end

-- === NOCLIP ===
function enableNoclip()
    local char = LocalPlayer.Character
    if not char then return end
    noclipConnection = RunService.Heartbeat:Connect(function()
        if not char or not char.Parent then
            noclipConnection:Disconnect()
            return
        end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

function disableNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- === ПРИМЕНЕНИЕ СКОРОСТИ ===
function applyWalkSpeed()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = walkSpeed
    end
end

function applyJumpPower()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = jumpPower
    end
end

-- === ПЕРЕТАСКИВАНИЕ ОКНА ===
local dragging = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- === ХОТКЕИ ===
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        if flying then stopFly() else startFly() end
        updateContent(currentTab) -- обновить кнопку на вкладке Fly
    end
    if input.KeyCode == Enum.KeyCode.M then
        guiVisible = not guiVisible
        screenGui.Enabled = guiVisible
    end
end)

-- === ИНИЦИАЛИЗАЦИЯ ===
LocalPlayer.CharacterAdded:Connect(function(char)
    wait(0.5)
    applyWalkSpeed()
    applyJumpPower()
    if noclip then
        enableNoclip()
    end
end)

if LocalPlayer.Character then
    wait(0.5)
    applyWalkSpeed()
    applyJumpPower()
end

-- Загрузить первую вкладку
updateContent("Fly")

print("✅ Modern menu loaded. F - Fly, M - Hide GUI")
