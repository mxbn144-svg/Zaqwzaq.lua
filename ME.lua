-- ТЕЛЕПОРТ ВПЕРЁД + NOCLIP (С ЗАПОМИНАНИЕМ ПОЗИЦИИ КНОПКИ)
-- Кнопку можно перетаскивать пальцем в любое место экрана – она запоминает положение.

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- ===== GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

-- ===== ПЕРЕМЕННЫЕ =====
local noclipEnabled = false

-- ===== ФУНКЦИЯ УПРАВЛЕНИЯ NOCLIP =====
local function setNoclip(state)
    noclipEnabled = state
    if state then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        -- Обработка нового персонажа
        player.CharacterAdded:Connect(function(newChar)
            character = newChar
            hrp = character:WaitForChild("HumanoidRootPart")
            if noclipEnabled then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- ===== СОЗДАНИЕ КНОПКИ ТЕЛЕПОРТА =====
local teleportBtn = Instance.new("TextButton")
teleportBtn.Size = UDim2.new(0, 80, 0, 80)
teleportBtn.Position = UDim2.new(0.1, 0, 0.4, 0)  -- начальная позиция
teleportBtn.BackgroundColor3 = Color3.fromRGB(30, 144, 255)
teleportBtn.Text = "➡\n5 шагов"
teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportBtn.TextScaled = true
teleportBtn.Font = Enum.Font.SourceSansBold
teleportBtn.BorderSizePixel = 0
teleportBtn.BackgroundTransparency = 0.2
teleportBtn.Parent = screenGui

-- Скругление
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = teleportBtn

-- ===== ПЕРЕТАСКИВАНИЕ КНОПКИ =====
local drag = Instance.new("UIDragDetector")
drag.Parent = teleportBtn
drag.DragDirection = Enum.DragDirection.XY

-- ===== ФУНКЦИЯ ТЕЛЕПОРТА =====
local function teleportForward()
    if not hrp then return end

    -- Сохраняем текущее состояние noclip
    local wasNoclip = noclipEnabled

    -- Включаем noclip на время телепорта (если он был выключен)
    if not wasNoclip then
        setNoclip(true)
    end

    -- Направление взгляда
    local forward = hrp.CFrame.LookVector
    -- Расстояние: 5 шагов ≈ 12.5 студий (можно изменить)
    local distance = 12.5
    local newPos = hrp.Position + forward * distance
    newPos = newPos + Vector3.new(0, 2, 0)  -- небольшой подъём

    -- Телепорт
    hrp.CFrame = CFrame.new(newPos, newPos + forward)

    -- Если noclip был выключен, выключаем его с задержкой
    if not wasNoclip then
        task.wait(0.1)
        setNoclip(false)
    end

    -- Визуальный отклик
    teleportBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    task.wait(0.1)
    teleportBtn.BackgroundColor3 = Color3.fromRGB(30, 144, 255)
end

teleportBtn.MouseButton1Click:Connect(teleportForward)

-- ===== КНОПКА УДАЛЕНИЯ (крестик) =====
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -28, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.TextScaled = true
closeBtn.Parent = teleportBtn
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    if noclipEnabled then setNoclip(false) end
end)

-- ===== КНОПКА ПОСТОЯННОГО NOCLIP (опционально) =====
local noclipBtn = Instance.new("TextButton")
noclipBtn.Size = UDim2.new(0, 60, 0, 60)
noclipBtn.Position = UDim2.new(0.1, 0, 0.7, 0)  -- ниже
noclipBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
noclipBtn.Text = "NOCLIP\nВЫКЛ"
noclipBtn.TextColor3 = Color3.fromRGB(255,255,255)
noclipBtn.TextScaled = true
noclipBtn.Font = Enum.Font.SourceSansBold
noclipBtn.BorderSizePixel = 0
noclipBtn.BackgroundTransparency = 0.2
noclipBtn.Parent = screenGui

local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(1, 0)
corner2.Parent = noclipBtn

-- Перетаскивание
local drag2 = Instance.new("UIDragDetector")
drag2.Parent = noclipBtn
drag2.DragDirection = Enum.DragDirection.XY

noclipBtn.MouseButton1Click:Connect(function()
    setNoclip(not noclipEnabled)
    if noclipEnabled then
        noclipBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        noclipBtn.Text = "NOCLIP\nВКЛ"
    else
        noclipBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        noclipBtn.Text = "NOCLIP\nВЫКЛ"
    end
end)

-- Крестик для noclip кнопки
local closeBtn2 = Instance.new("TextButton")
closeBtn2.Size = UDim2.new(0, 18, 0, 18)
closeBtn2.Position = UDim2.new(1, -22, 0, 5)
closeBtn2.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn2.Text = "✕"
closeBtn2.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn2.TextScaled = true
closeBtn2.Parent = noclipBtn
closeBtn2.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    if noclipEnabled then setNoclip(false) end
end)

print("✅ Скрипт загружен! Кнопки перетаскиваются и запоминают позицию.")
print("• Телепорт на 5 шагов вперёд (с временным noclip)")
print("• Постоянный Noclip (вкл/выкл)")
