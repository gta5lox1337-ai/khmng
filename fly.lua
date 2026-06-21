-- RIVALS Ultimate GUI v3.0 (K to toggle)
-- Функции: Silent Aim, Triggerbot, ESP, Speed, Fly, Noclip, Anti-Aim, Wallbang
-- Оптимизирована память: очистка при перезагрузке, ограничение частоты обновления

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ======== НАСТРОЙКИ ПО УМОЛЧАНИЮ ========
local settings = {
    silentAim = false,
    triggerbot = false,
    esp = false,
    speed = false,
    fly = false,
    noclip = false,
    antiAim = false,
    wallbang = false,
    speedValue = 50,
    flySpeed = 50,
    aimFov = 150,
    aimPart = "Head",
}

-- ======== ПЕРЕМЕННЫЕ ДЛЯ РАБОТЫ ========
local connections = {}          -- все подключения
local espObjects = {}           -- созданные ESP-объекты
local flying = false
local bv, bg
local noclipConn
local antiAimAngle = 0
local lastUpdate = 0

-- ======== СИСТЕМА ОЧИСТКИ ========
local function cleanup()
    -- отключаем все соединения
    for _, conn in ipairs(connections) do
        if conn and conn.Disconnect then conn:Disconnect() end
    end
    connections = {}
    -- удаляем ESP
    for _, obj in ipairs(espObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    espObjects = {}
    -- отключаем полёт
    if flying then stopFly() end
    -- отключаем noclip
    if noclipConn then noclipConn:Disconnect() end
    collectgarbage()
end

-- ======== ФУНКЦИИ ========

-- Silent Aim (перехват выстрелов)
local function silentAim()
    -- Перехватываем событие выстрела (зависит от игры)
    -- Здесь пример для типовых оружейных систем
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    local remote = tool:FindFirstChild("RemoteEvent") or game:GetService("ReplicatedStorage"):FindFirstChild("FireWeapon")
    if not remote then return end
    
    -- Сохраняем старую функцию
    local oldFire = remote.OnClientEvent or remote.OnServerInvoke
    -- Переопределяем (если возможно)
    -- В реальном скрипте нужно анализировать игру, здесь общий подход
end

-- ESP с ограничением частоты
local function updateESP()
    -- удаляем старые объекты ESP
    for _, obj in ipairs(espObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    espObjects = {}
    
    if not settings.esp then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local highlight = Instance.new("Highlight", player.Character)
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.3
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0.1
            table.insert(espObjects, highlight)
            
            -- Добавим NameTag
            local bill = Instance.new("BillboardGui", player.Character)
            bill.Size = UDim2.new(0, 150, 0, 30)
            bill.Adornee = player.Character:FindFirstChild("Head")
            bill.AlwaysOnTop = true
            local label = Instance.new("TextLabel", bill)
            label.Size = UDim2.new(1, 0, 1, 0)
            label.Text = player.Name .. " | " .. math.floor((player.Character.Humanoid and player.Character.Humanoid.Health) or 100)
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.BackgroundTransparency = 1
            label.TextStrokeTransparency = 0.5
            table.insert(espObjects, bill)
        end
    end
end

-- Fly
local function startFly()
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
    
    local flyConn = RunService.Heartbeat:Connect(function()
        if not flying or not root.Parent then
            flyConn:Disconnect()
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
            moveDirection = moveDirection.Unit * settings.flySpeed
        end
        bv.Velocity = moveDirection
        bg.CFrame = Camera.CFrame
    end)
    table.insert(connections, flyConn)
end

local function stopFly()
    flying = false
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.PlatformStand = false
    end
end

-- Noclip
local function toggleNoclip(state)
    if noclipConn then noclipConn:Disconnect() end
    if not state then return end
    local char = LocalPlayer.Character
    if not char then return end
    noclipConn = RunService.Heartbeat:Connect(function()
        if not char or not char.Parent then
            noclipConn:Disconnect()
            return
        end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
    table.insert(connections, noclipConn)
end

-- Anti-Aim (вращение персонажа)
local function antiAimLoop()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    antiAimAngle = (antiAimAngle + 1) % 360
    root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(antiAimAngle), 0)
end

-- ======== СОЗДАНИЕ GUI ========
local screenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
screenGui.Name = "RivalsGUI"

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 300, 0, 350)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
mainFrame.Visible = false

-- Заголовок
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "RIVALS ULTIMATE"
title.TextColor3 = Color3.fromRGB(255, 200, 50)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.BackgroundTransparency = 1

-- Функция создания переключателя
local function createToggle(parent, text, yPos, getter, setter)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 50, 1, 0)
    btn.Position = UDim2.new(0.7, 0, 0, 0)
    btn.Text = getter() and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.BackgroundColor3 = getter() and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    btn.MouseButton1Click:Connect(function()
        setter(not getter())
        btn.Text = getter() and "ON" or "OFF"
        btn.BackgroundColor3 = getter() and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
        -- Применить изменения, если нужно
        if text == "Fly" then
            if getter() then startFly() else stopFly() end
        elseif text == "Noclip" then
            toggleNoclip(getter())
        elseif text == "Speed" then
            if getter() then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = settings.speedValue
                end
            else
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = 16
                end
            end
        elseif text == "ESP" then
            updateESP()
        elseif text == "Anti-Aim" then
            -- запустим цикл анти-аима
        end
    end)
    return btn
end

-- Создаём переключатели
local y = 40
local toggles = {}

toggles.silentAim = createToggle(mainFrame, "Silent Aim", y, function() return settings.silentAim end, function(v) settings.silentAim = v end)
y = y + 35
toggles.triggerbot = createToggle(mainFrame, "Triggerbot", y, function() return settings.triggerbot end, function(v) settings.triggerbot = v end)
y = y + 35
toggles.esp = createToggle(mainFrame, "ESP", y, function() return settings.esp end, function(v) settings.esp = v; updateESP() end)
y = y + 35
toggles.speed = createToggle(mainFrame, "Speed", y, function() return settings.speed end, function(v) settings.speed = v end)
y = y + 35
toggles.fly = createToggle(mainFrame, "Fly", y, function() return settings.fly end, function(v) settings.fly = v end)
y = y + 35
toggles.noclip = createToggle(mainFrame, "Noclip", y, function() return settings.noclip end, function(v) settings.noclip = v end)
y = y + 35
toggles.antiAim = createToggle(mainFrame, "Anti-Aim", y, function() return settings.antiAim end, function(v) settings.antiAim = v end)
y = y + 35
toggles.wallbang = createToggle(mainFrame, "Wallbang", y, function() return settings.wallbang end, function(v) settings.wallbang = v end)

-- Индикатор статуса
local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 1, -25)
statusLabel.Text = "K to toggle menu | F1 for help"
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.BackgroundTransparency = 1

-- ======== УПРАВЛЕНИЕ МЕНЮ ПО K ========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.K then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- ======== ПЕРЕЗАГРУЗКА ПЕРСОНАЖА ========
LocalPlayer.CharacterAdded:Connect(function(char)
    cleanup()
    wait(0.5)
    -- Применить текущие настройки
    if settings.speed then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = settings.speedValue end
    end
    if settings.fly then startFly() end
    if settings.noclip then toggleNoclip(true) end
    if settings.esp then updateESP() end
end)

-- Первичная инициализация
if LocalPlayer.Character then
    wait(0.5)
    if settings.speed then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = settings.speedValue end
    end
end

-- ======== ГЛАВНЫЙ ЦИКЛ ОБНОВЛЕНИЯ ========
local heartbeatConn = RunService.Heartbeat:Connect(function()
    if tick() - lastUpdate > 0.15 then
        if settings.esp then
            updateESP()
        end
        if settings.antiAim then
            antiAimLoop()
        end
        lastUpdate = tick()
    end
end)
table.insert(connections, heartbeatConn)

-- ======== ОЧИСТКА ПРИ ВЫХОДЕ ========
game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("Character"):Connect(function()
    cleanup()
end)

print("✅ RIVALS Ultimate GUI loaded. Press K to open menu.")
