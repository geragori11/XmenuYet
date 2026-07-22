local Theme = import("src/Theme.lua")
local UserInputService = game:GetService("UserInputService")

-- Вспомогательная функция для создания кольца-указателя
local function createRingPointer(size, thickness)
    local ring = Instance.new("Frame")
    ring.Size = UDim2.fromOffset(size, size)
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.BackgroundTransparency = 1
    ring.ZIndex = 10

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ring

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 2.5
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = ring

    return ring
end

return function(container, text, defaultColor, callback, flagName)
    local currentColor = defaultColor or Color3.fromRGB(255, 0, 0)
    local h, s, v = currentColor:ToHSV()

    -- Главный контейнер
    local frame = Instance.new("Frame")
    frame.Name = "ColorPickerContainer"
    frame.Size = UDim2.new(1, -8, 0, 180)
    frame.BackgroundTransparency = 1
    frame.Parent = container

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = frame

    -- ==========================================
    -- 1. Поле Выбора Насыщенности и Яркости (SV)
    -- ==========================================
    local svBox = Instance.new("Frame")
    svBox.Name = "SVBox"
    svBox.Size = UDim2.new(1, -28, 1, 0) -- Авто-размер с учетом ширины полосы Hue
    svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    svBox.ClipsDescendants = false
    svBox.LayoutOrder = 1
    svBox.Parent = frame

    local svCorner = Instance.new("UICorner")
    svCorner.CornerRadius = UDim.new(0, 8)
    svCorner.Parent = svBox

    -- Белый градиент (Слева направо: Насыщенность)
    local satFrame = Instance.new("Frame")
    satFrame.Size = UDim2.fromScale(1, 1)
    satFrame.BackgroundTransparency = 1
    satFrame.Parent = svBox

    local satCorner = Instance.new("UICorner")
    satCorner.CornerRadius = UDim.new(0, 8)
    satCorner.Parent = satFrame

    local satGradient = Instance.new("UIGradient")
    satGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    satGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    satGradient.Rotation = 0
    satGradient.Parent = satFrame

    -- Черный градиент (Сверху вниз: Яркость)
    local valFrame = Instance.new("Frame")
    valFrame.Size = UDim2.fromScale(1, 1)
    valFrame.BackgroundTransparency = 1
    valFrame.Parent = svBox

    local valCorner = Instance.new("UICorner")
    valCorner.CornerRadius = UDim.new(0, 8)
    valCorner.Parent = valFrame

    local valGradient = Instance.new("UIGradient")
    valGradient.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
    valGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    })
    valGradient.Rotation = 90
    valGradient.Parent = valFrame

    -- Кольцевой указатель для SV
    local svPointer = createRingPointer(18, 3)
    svPointer.Parent = svBox

    -- ==========================================
    -- 2. Вертикальная Полоса Оттенка (Hue Bar)
    -- ==========================================
    local hueBar = Instance.new("Frame")
    hueBar.Name = "HueBar"
    hueBar.Size = UDim2.new(0, 18, 1, 0)
    hueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueBar.ClipsDescendants = false
    hueBar.LayoutOrder = 2
    hueBar.Parent = frame

    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(1, 0) -- Закругление в форме пилюли
    hueCorner.Parent = hueBar

    local hueGradient = Instance.new("UIGradient")
    hueGradient.Rotation = 90
    hueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
    })
    hueGradient.Parent = hueBar

    -- Кольцевой указатель для Hue
    local huePointer = createRingPointer(18, 3)
    huePointer.Parent = hueBar

    -- ==========================================
    -- Логика обновления и взаимодействия
    -- ==========================================
    local function updateColor()
        currentColor = Color3.fromHSV(h, s, v)

        -- Обновляем цвет фона SV поля
        svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)

        -- Обновляем позицию пикера SV
        svPointer.Position = UDim2.fromScale(s, 1 - v)

        -- Обновляем позицию пикера Hue
        huePointer.Position = UDim2.fromScale(0.5, h)

        -- Колбэк и флаги
        if callback then callback(currentColor) end
        if flagName then
            local Lib = import("init.lua")
            if Lib.Flags and Lib.Flags[flagName] then
                Lib.Flags[flagName].Value = currentColor
            end
        end
    end

    local draggingSV = false
    local draggingHue = false

    local function updateSVFromInput(input)
        local absPos = svBox.AbsolutePosition
        local absSize = svBox.AbsoluteSize
        local mousePos = input.Position

        local relativeX = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
        local relativeY = math.clamp((mousePos.Y - absPos.Y) / absSize.Y, 0, 1)

        s = relativeX
        v = 1 - relativeY
        updateColor()
    end

    local function updateHueFromInput(input)
        local absPos = hueBar.AbsolutePosition
        local absSize = hueBar.AbsoluteSize
        local mousePos = input.Position

        local relativeY = math.clamp((mousePos.Y - absPos.Y) / absSize.Y, 0, 1)
        h = relativeY
        updateColor()
    end

    -- Обработка событий ввода
    svBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSV = true
            updateSVFromInput(input)
        end
    end)

    hueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingHue = true
            updateHueFromInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSV = false
            draggingHue = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if draggingSV then
                updateSVFromInput(input)
            elseif draggingHue then
                updateHueFromInput(input)
            end
        end
    end)

    -- Регистрация флага
    if flagName then
        local Lib = import("init.lua")
        if Lib.RegisterFlag then
            Lib:RegisterFlag(flagName, currentColor, function(val)
                h, s, v = val:ToHSV()
                updateColor()
            end)
        end
    end

    -- Первоначальная установка
    updateColor()

    return frame
end