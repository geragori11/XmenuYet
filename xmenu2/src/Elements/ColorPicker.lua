-- [File: src/Elements/ColorPicker.lua]
local Theme = import("src/Theme.lua")
local UserInputService = game:GetService("UserInputService")

-- Вспомогательная функция для создания кольца-указателя
local function createRingPointer(size, thickness)
    local ring = Instance.new("Frame")
    ring.Size = UDim2.fromOffset(size, size)
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.BackgroundTransparency = 1
    ring.ZIndex = 210

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

local function Color3ToHex(c)
    local function toHex(num)
        local n = math.floor(num * 255)
        return string.format("%02X", n)
    end
    return "#" .. toHex(c.R) .. toHex(c.G) .. toHex(c.B)
end

local function HexToColor3(hex)
    hex = hex:gsub("#", "")
    if #hex == 6 then
        local r = tonumber(hex:sub(1, 2), 16) or 0
        local g = tonumber(hex:sub(3, 4), 16) or 0
        local b = tonumber(hex:sub(5, 6), 16) or 0
        return Color3.new(r / 255, g / 255, b / 255)
    end
    return nil
end

return function(container, text, defaultColor, callback, flagName)
    local currentColor = defaultColor or Color3.fromRGB(255, 0, 0)
    local popupOpen = false

    -- 1. Элемент строки в контейнере настроек (26px)
    local frame = Instance.new("Frame")
    frame.Name = "ColorPickerRow"
    frame.Size = UDim2.new(1, 0, 0, 26)
    frame.BackgroundColor3 = Theme.ElementBackground
    frame.LayoutOrder = #container:GetChildren()
    frame.Parent = container

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = Theme.ElementCorner
    rowCorner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, -8, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.TextColor
    label.Font = Enum.Font.SourceSans
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    -- Кнопка-превью цвета справа
    local colorPreview = Instance.new("TextButton")
    colorPreview.Size = UDim2.new(0, 32, 0, 16)
    colorPreview.Position = UDim2.new(1, -38, 0.5, -8)
    colorPreview.BackgroundColor3 = currentColor
    colorPreview.Text = ""
    colorPreview.AutoButtonColor = false
    colorPreview.Parent = frame

    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 4)
    previewCorner.Parent = colorPreview

    local previewStroke = Instance.new("UIStroke")
    previewStroke.Thickness = 1
    previewStroke.Color = Color3.fromRGB(60, 60, 70)
    previewStroke.Parent = colorPreview

    local function setColor(color, skipCallback)
        currentColor = color
        colorPreview.BackgroundColor3 = color

        if not skipCallback and callback then
            callback(color)
        end

        if flagName then
            local Lib = import("init.lua")
            if Lib.Flags and Lib.Flags[flagName] then
                Lib.Flags[flagName].Value = color
            end
        end
    end

    -- 2. Создание всплывающего окна (Popup) с глобальным управлением
    local function openPopup()
        if popupOpen then return end

        -- Закрыть предыдущий попап, если он существует
        if _G.__CurrentColorPickerOverlay then
            _G.__CurrentColorPickerOverlay:Destroy()
            _G.__CurrentColorPickerOverlay = nil
        end

        popupOpen = true

        local screenGui = container:FindFirstAncestorOfClass("ScreenGui") or game:GetService("CoreGui")

        -- Тёмная подложка-оверлей
        local overlay = Instance.new("Frame")
        overlay.Name = "ColorPickerOverlay"
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        overlay.BackgroundTransparency = 0.5
        overlay.ZIndex = 200
        overlay.Parent = screenGui

        -- Сохраняем в глобальную переменную для закрытия при открытии нового
        _G.__CurrentColorPickerOverlay = overlay

        -- Модальное окно выбора цвета
        local popup = Instance.new("Frame")
        popup.Name = "ColorPickerPopup"
        popup.Size = UDim2.new(0, 230, 0, 250)
        popup.Position = UDim2.new(0.5, -115, 0.5, -125)
        popup.BackgroundColor3 = Theme.ColumnBackground
        popup.ZIndex = 201
        popup.Parent = overlay

        local popupCorner = Instance.new("UICorner")
        popupCorner.CornerRadius = Theme.ColumnCorner
        popupCorner.Parent = popup

        -- Заголовок модального окна
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -16, 0, 28)
        title.Position = UDim2.new(0, 10, 0, 4)
        title.BackgroundTransparency = 1
        title.Text = text
        title.TextColor3 = Theme.TextColor
        title.Font = Enum.Font.SourceSansBold
        title.TextSize = 13
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 202
        title.Parent = popup

        local h, s, v = currentColor:ToHSV()

        -- --- SV Поле (Насыщенность / Яркость) ---
        local svBox = Instance.new("Frame")
        svBox.Name = "SVBox"
        svBox.Size = UDim2.new(0, 165, 0, 165)
        svBox.Position = UDim2.new(0, 10, 0, 34)
        svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        svBox.ZIndex = 202
        svBox.Parent = popup

        local svCorner = Instance.new("UICorner")
        svCorner.CornerRadius = UDim.new(0, 6)
        svCorner.Parent = svBox

        -- Белый градиент
        local satFrame = Instance.new("Frame")
        satFrame.Size = UDim2.fromScale(1, 1)
        satFrame.BackgroundTransparency = 1
        satFrame.ZIndex = 203
        satFrame.Parent = svBox
        local satCorner = Instance.new("UICorner")
        satCorner.CornerRadius = UDim.new(0, 6)
        satCorner.Parent = satFrame
        local satGradient = Instance.new("UIGradient")
        satGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        satGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        satGradient.Parent = satFrame

        -- Чёрный градиент
        local valFrame = Instance.new("Frame")
        valFrame.Size = UDim2.fromScale(1, 1)
        valFrame.BackgroundTransparency = 1
        valFrame.ZIndex = 204
        valFrame.Parent = svBox
        local valCorner = Instance.new("UICorner")
        valCorner.CornerRadius = UDim.new(0, 6)
        valCorner.Parent = valFrame
        local valGradient = Instance.new("UIGradient")
        valGradient.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
        valGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0)
        })
        valGradient.Rotation = 90
        valGradient.Parent = valFrame

        local svPointer = createRingPointer(16, 2.5)
        svPointer.Parent = svBox

        -- --- Hue Полоса (Оттенок) ---
        local hueBar = Instance.new("Frame")
        hueBar.Name = "HueBar"
        hueBar.Size = UDim2.new(0, 18, 0, 165)
        hueBar.Position = UDim2.new(0, 185, 0, 34)
        hueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        hueBar.ZIndex = 202
        hueBar.Parent = popup

        local hueCorner = Instance.new("UICorner")
        hueCorner.CornerRadius = UDim.new(1, 0)
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

        local huePointer = createRingPointer(18, 2.5)
        huePointer.Parent = hueBar

        -- --- HEX Поле ввода ---
        local hexBox = Instance.new("TextBox")
        hexBox.Size = UDim2.new(0, 95, 0, 24)
        hexBox.Position = UDim2.new(0, 10, 0, 210)
        hexBox.BackgroundColor3 = Theme.ElementBackground
        hexBox.Text = Color3ToHex(currentColor)
        hexBox.TextColor3 = Theme.TextColor
        hexBox.Font = Enum.Font.SourceSans
        hexBox.TextSize = 12
        hexBox.ZIndex = 202
        hexBox.Parent = popup

        local hexCorner = Instance.new("UICorner")
        hexCorner.CornerRadius = Theme.ElementCorner
        hexCorner.Parent = hexBox

        -- --- Кнопка "OK" ---
        local okBtn = Instance.new("TextButton")
        okBtn.Size = UDim2.new(0, 80, 0, 24)
        okBtn.Position = UDim2.new(0, 123, 0, 210)
        okBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 70)
        okBtn.Text = "OK"
        okBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        okBtn.Font = Enum.Font.SourceSansBold
        okBtn.TextSize = 12
        okBtn.ZIndex = 202
        okBtn.Parent = popup

        local okCorner = Instance.new("UICorner")
        okCorner.CornerRadius = Theme.ElementCorner
        okCorner.Parent = okBtn

        -- Функция обновления состояния цвета
        local function updateUI()
            local col = Color3.fromHSV(h, s, v)
            svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            svPointer.Position = UDim2.fromScale(s, 1 - v)
            huePointer.Position = UDim2.fromScale(0.5, h)
            hexBox.Text = Color3ToHex(col)
            setColor(col)
        end

        -- Ручной ввод HEX
        hexBox.FocusLost:Connect(function()
            local col = HexToColor3(hexBox.Text)
            if col then
                h, s, v = col:ToHSV()
                updateUI()
            else
                hexBox.Text = Color3ToHex(currentColor)
            end
        end)

        -- Перетаскивание (Drag logic)
        local draggingSV = false
        local draggingHue = false

        local function updateSVFromInput(input)
            local absPos = svBox.AbsolutePosition
            local absSize = svBox.AbsoluteSize
            s = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
            v = 1 - math.clamp((input.Position.Y - absPos.Y) / absSize.Y, 0, 1)
            updateUI()
        end

        local function updateHueFromInput(input)
            local absPos = hueBar.AbsolutePosition
            local absSize = hueBar.AbsoluteSize
            h = math.clamp((input.Position.Y - absPos.Y) / absSize.Y, 0, 1)
            updateUI()
        end

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

        local inputEndedConn, inputChangedConn, overlayClickConn

        inputEndedConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSV = false
                draggingHue = false
            end
        end)

        inputChangedConn = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if draggingSV then
                    updateSVFromInput(input)
                elseif draggingHue then
                    updateHueFromInput(input)
                end
            end
        end)

        local function closePopup()
            if inputEndedConn then inputEndedConn:Disconnect() end
            if inputChangedConn then inputChangedConn:Disconnect() end
            if overlayClickConn then overlayClickConn:Disconnect() end
            overlay:Destroy()
            popupOpen = false
            _G.__CurrentColorPickerOverlay = nil
        end

        -- Закрытие только при клике строго вне popup
        overlayClickConn = overlay.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if input.Target and not input.Target:IsDescendantOf(popup) and input.Target ~= popup then
                    closePopup()
                end
            end
        end)

        okBtn.MouseButton1Click:Connect(closePopup)

        updateUI()
    end

    colorPreview.MouseButton1Click:Connect(openPopup)

    -- Регистрация флага
    if flagName then
        local Lib = import("init.lua")
        if Lib.RegisterFlag then
            Lib:RegisterFlag(flagName, currentColor, function(val)
                setColor(val)
            end)
        end
    end

    return frame
end