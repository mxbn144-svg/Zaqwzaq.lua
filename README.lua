-- ТЕЛЕПОРТ + NOCLIP (ДВЕ ПЕРЕТАСКИВАЕМЫЕ КНОПКИ)
-- Для телефона: двигайте кнопки пальцем, нажимайте для действий

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- ===== GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

-- ===== ВСПОМОГАТЕЛЬНАЯ ФУНКЦИЯ СОЗДАНИЯ КНОПКИ =====
local function createButton(text, defaultPos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 0, 80)
    btn.Position = defaultPos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.SourceSansBold
    btn.BorderSizePixel = 0
    btn.BackgroundTransparency = 0.2
    btn.Parent = screenGui

    -- Скругление
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn

    -- Перетаскивание (для телефона)
    local drag = Instance.new("UIDragDetector")
    drag.Parent = btn
    drag.DragDirection = Enum.DragDirection.XY

    return btn
end

-- ===== КНОПКА ТЕЛЕПОРТА =====
local teleportBtn = createButton("5 шагов", UDim2.new(0.1, 0, 0.3, 0), Color3.fromRGB(30, 144, 255))

-- ===== КНОПКА NOCLIP (ПЕРЕКЛЮЧАТЕЛЬ) =====
local noclipBtn = createButton("Noclip: ВЫКЛ", UDim2.new(0.1, 0, 0.6, 0), Color3.fromRGB(200, 50, 50))

-- ===== ПЕРЕМЕННЫЕ ДЛЯ NOCLIP =====
local noclipEnabled = false
local noclipConnections = {}

-- ===== ФУНКЦИЯ ВКЛЮЧЕНИЯ/ВЫКЛЮЧЕНИЯ NOCLIP =====
local function setNoclip(state)
    noclipEnabled = state
    if state then
        noclipBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        noclipBtn.Text = "Noclip: ВКЛ"
        -- Отключаем коллизию для всех частей персонажа
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        -- Отслеживаем новые части (например, при пересоздании персонажа)
        player.CharacterAdded:Connect(function(newChar)
            character = newChar
            hrp = character:WaitForChild("HumanoidRootPart")
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        noclipBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        noclipBtn.Text = "Noclip: ВЫКЛ"
        -- Включаем коллизию обратно
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- ===== ОБРАБОТЧИК КНОПКИ NOCLIP =====
noclipBtn.MouseButton1Click:Connect(function()
    setNoclip(not noclipEnabled)
end)

-- ===== ФУНКЦИЯ ТЕЛЕПОРТА НА 5 ШАГОВ =====
local function teleportFiveSteps()
    if not hrp then return end

    -- Сохраняем текущее состояние noclip
    local wasNoclip = noclipEnabled

    -- Временно включаем noclip, чтобы пройти сквозь стены при телепорте
    if not wasNoclip then
        setNoclip(true)
    end

    -- Направление вперёд
    local forward = hrp.CFrame.LookVector
    -- Длина шага (условно 5 шагов ≈ 5 * 2.5 = 12.5 студий, но возьмём 15 для наглядности)
    local distance = 15 -- можно подогнать под "шаг"
    local newPos = hrp.Position + forward * distance
    newPos = newPos + Vector3.new(0, 2, 0) -- небольшой подъём

    -- Телепортируем
    hrp.CFrame = CFrame.new(newPos, newPos + forward)

    -- Если noclip был выключен, выключаем его обратно (с задержкой, чтобы не застрять)
    if not wasNoclip then
        task.wait(0.1) -- даём время на проход
        setNoclip(false)
    end

    -- Визуальный отклик (мигание)
    teleportBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    task.wait(0.1)
    teleportBtn.BackgroundColor3 = Color3.fromRGB(30, 144, 255)
end

teleportBtn.MouseButton1Click:Connect(teleportFiveSteps)

-- ===== КНОПКА УДАЛЕНИЯ GUI (опционально) =====
-- Можно добавить общую кнопку закрытия, но для удобства сделаем крестик на каждой?
-- Добавим маленький крестик на каждой кнопке для удаления всего интерфейса.
local function addCloseButton(parent)
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 20, 0, 20)
    close.Position = UDim2.new(1, -25, 0, 5)
    close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    close.Text = "✕"
    close.TextColor3 = Color3.fromRGB(255,255,255)
    close.TextScaled = true
    close.Parent = parent
    close.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        -- Сбрасываем noclip при удалении
        if noclipEnabled then setNoclip(false) end
    end)
end

addCloseButton(teleportBtn)
addCloseButton(noclipBtn)

print("✅ Скрипт загружен. Кнопки перетаскиваются пальцем.")
print("• Телепорт на 5 шагов (с временным noclip)")
print("• Noclip: вкл/выкл")
