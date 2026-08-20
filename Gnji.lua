-- УСКОРИТЕЛЬ ×5 (ПРОСТАЯ КНОПКА ВКЛ/ВЫКЛ)
-- Нажмите на кнопку – скорость машины умножается на 5, ещё раз – отключается.

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- ===== GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

-- Кнопка-переключатель
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 80, 0, 80)
btn.Position = UDim2.new(0.02, 0, 0.02, 0)  -- левый верхний угол (можно перетащить, если нужно)
btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)  -- красный (выкл)
btn.Text = "×5 ВЫКЛ"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextScaled = true
btn.Font = Enum.Font.SourceSansBold
btn.BorderSizePixel = 0
btn.Parent = screenGui

-- Скругление
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = btn

-- ===== ПЕРЕМЕННЫЕ =====
local enabled = false
local bodyVelocity = nil
local targetPart = nil
local loopRunning = false
local BASE_SPEED = 50  -- базовая скорость (подгоните под свою игру)
local MULTIPLIER = 5   -- множитель

-- ===== ПОИСК СИДЕНЬЯ =====
local function findSeat()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("VehicleSeat") and obj.Occupant == character then
            return obj
        end
        if obj:IsA("Seat") and obj.Occupant == character then
            return obj
        end
    end
    return nil
end

-- ===== ОПРЕДЕЛЕНИЕ ГЛАВНОЙ ЧАСТИ МАШИНЫ =====
local function getMainPart(seat)
    if not seat then return nil end
    local model = seat.Parent
    if model:IsA("Model") then
        if model.PrimaryPart then return model.PrimaryPart end
        for _, name in pairs({"Body", "Chassis", "Main", "Root", "Vehicle"}) do
            local p = model:FindFirstChild(name)
            if p and p:IsA("BasePart") then return p end
        end
        for _, child in pairs(model:GetChildren()) do
            if child:IsA("BasePart") then return child end
        end
    end
    return seat
end

-- ===== ЦИКЛ УСКОРЕНИЯ =====
local function boostLoop()
    while loopRunning do
        wait(0.05)
        if not enabled then break end

        local seat = findSeat()
        if seat then
            local newPart = getMainPart(seat)
            if newPart and newPart ~= targetPart then
                targetPart = newPart
                if bodyVelocity then bodyVelocity:Destroy() end
                bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(1e8, 1e8, 1e8)
                bodyVelocity.Parent = targetPart
            end
            if bodyVelocity and targetPart then
                local forward = seat.CFrame.LookVector
                local speed = BASE_SPEED * MULTIPLIER
                bodyVelocity.Velocity = forward * speed
            end
        else
            if bodyVelocity then
                bodyVelocity:Destroy()
                bodyVelocity = nil
                targetPart = nil
            end
        end
    end
    -- очистка при остановке
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
        targetPart = nil
    end
end

-- ===== ПЕРЕКЛЮЧЕНИЕ =====
local function toggle()
    enabled = not enabled
    if enabled then
        loopRunning = true
        spawn(boostLoop)
        btn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        btn.Text = "×5 ВКЛ"
    else
        loopRunning = false
        btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        btn.Text = "×5 ВЫКЛ"
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
            targetPart = nil
        end
    end
end

btn.MouseButton1Click:Connect(toggle)

-- ===== ОПЦИОНАЛЬНО: КНОПКА УДАЛЕНИЯ =====
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -25, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.TextScaled = true
closeBtn.Parent = btn
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    if bodyVelocity then bodyVelocity:Destroy() end
end)

print("✅ Ускоритель ×5 загружен! Кнопка в левом верхнем углу.")
print("Нажмите, чтобы включить/выключить. Красный – выкл, зелёный – вкл.")
