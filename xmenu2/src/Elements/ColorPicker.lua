-- [File: src/Elements/ColorPicker.lua]
local Theme = import("src/Theme.lua")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ===== Вспомогательные функции =====
local function Color3ToHSV(c)
    local r, g, b = c.R, c.G, c.B
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v
    v = max
    if max == 0 then
        s = 0
        h = 0
    else
        s = (max - min) / max
        if max == r then
            h = (g - b) / (max - min)
        elseif max == g then
            h = 2 + (b - r) / (max - min)
        else
            h = 4 + (r - g) / (max - min)
        end
        h = h / 6
        if h < 0 then h = h + 1 end
    end
    return h, s, v
end

local function HSVToColor3(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    else r, g, b = v, p, q
    end
    return Color3.new(r, g, b)
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
        local r = tonumber(hex:sub(1,2), 16) or 0
        local g = tonumber(hex:sub(3,4), 16) or 0
        local b = tonumber(hex:sub(5,6), 16) or 0
        return Color3.new(r/255, g/255, b/255)
    end
    return nil
end

-- ===== Основная функция =====
return function(container, text, defaultColor, callback, flagName)
    local currentColor = defaultColor or Color3.fromRGB(255, 255, 255)
    local popupOpen = false

    -- Элемент в списке
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -8, 0, 26)
    frame.BackgroundColor3 = Theme.ElementBackground
    frame.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.TextColor
    label.Font = Enum.Font.SourceSans
    label.TextSize = 12
    label.Parent = frame

    local colorPreview = Instance.new("TextButton")
    colorPreview.Size = UDim2.new(0.2, 0, 0.7, 0)
    colorPreview.Position = UDim2.new(0.75, 0, 0.15, 0)
    colorPreview.BackgroundColor3 = currentColor
    colorPreview.Text = ""
    colorPreview.Parent = frame

    local function setColor(color)
        currentColor = color
        colorPreview.BackgroundColor3 = color
        if callback then callback(color) end
        if flagName then
            local Lib = import("init.lua")
            if Lib.Flags[flagName] then
                Lib.Flags[flagName].Value = color
            end
        end
    end

    -- ===== Создание Popup =====
    local function openPopup()
        if popupOpen then return end
        popupOpen = true

        local overlay = Instance.new("Frame")
        overlay.Name = "ColorPickerOverlay"
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.new(0, 0, 0)
        overlay.BackgroundTransparency = 0.5
        overlay.ZIndex = 200
        overlay.Parent = container:FindFirstAncestorOfClass("ScreenGui") or game:GetService("CoreGui")

        local popup = Instance.new("Frame")
        popup.Name = "ColorPickerPopup"
        popup.Size = UDim2.new(0, 340, 0, 340)
        popup.Position = UDim2.new(0.5, -170, 0.5, -170)
        popup.BackgroundColor3 = Theme.ColumnBackground
        popup.ZIndex = 201
        popup.Parent = overlay

        local popupCorner = Instance.new("UICorner")
        popupCorner.CornerRadius = Theme.ColumnCorner
        popupCorner.Parent = popup

        -- Заголовок
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -16, 0, 28)
        title.Position = UDim2.new(0, 8, 0, 6)
        title.BackgroundTransparency = 1
        title.Text = "Выбор цвета"
        title.TextColor3 = Theme.TextColor
        title.Font = Enum.Font.SourceSansBold
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 202
        title.Parent = popup

        -- Hue полоса
        local hueBar = Instance.new("Frame")
        hueBar.Size = UDim2.new(0.85, 0, 0, 18)
        hueBar.Position = UDim2.new(0.075, 0, 0, 40)
        hueBar.BackgroundColor3 = Color3.new(1, 1, 1)
        hueBar.ZIndex = 202
        hueBar.Parent = popup

        local hueGradient = Instance.new("UIGradient")
        hueGradient.Rotation = 0
        hueGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
            ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255,255,0)),
            ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,255,0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
            ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0,0,255)),
            ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,0,255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
        }
        hueGradient.Parent = hueBar

        local hueCorner = Instance.new("UICorner")
        hueCorner.CornerRadius = UDim.new(0, 4)
        hueCorner.Parent = hueBar

        -- Hue указатель
        local huePicker = Instance.new("TextButton")
        huePicker.Size = UDim2.new(0, 6, 1, 0)
        huePicker.Position = UDim2.new(0, 0, 0, 0) -- будет обновляться
        huePicker.BackgroundColor3 = Color3.new(1, 1, 1)
        huePicker.BackgroundTransparency = 0.3
        huePicker.Text = ""
        huePicker.ZIndex = 203
        huePicker.Parent = hueBar

        local pickerCorner = Instance.new("UICorner")
        pickerCorner.CornerRadius = UDim.new(0, 2)
        pickerCorner.Parent = huePicker

        -- SV квадрат
        local svBox = Instance.new("Frame")
        svBox.Size = UDim2.new(0.55, 0, 0, 150)
        svBox.Position = UDim2.new(0.075, 0, 0, 65)
        svBox.BackgroundColor3 = Color3.new(1, 1, 1)
        svBox.ZIndex = 202
        svBox.Parent = popup

        local svCorner = Instance.new("UICorner")
        svCorner.CornerRadius = UDim.new(0, 4)
        svCorner.Parent = svBox

        -- SV градиент (насыщенность по X, яркость по Y)
        local svGradientX = Instance.new("UIGradient")
        svGradientX.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
        }
        svGradientX.Rotation = 0
        svGradientX.Parent = svBox

        -- Заменяем: создаём два градиента: один для насыщенности, второй для яркости (накладываем)
        -- Проще: использовать ImageLabel с Texture, но мы сделаем через два Frame с UIGradient.
        -- Сначала создадим Frame для насыщенности (прозрачный)
        local satFrame = Instance.new("Frame")
        satFrame.Size = UDim2.new(1, 0, 1, 0)
        satFrame.BackgroundTransparency = 1
        satFrame.ZIndex = 202
        satFrame.Parent = svBox

        local satGrad = Instance.new("UIGradient")
        satGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
        }
        satGrad.Rotation = 0
        satGrad.Parent = satFrame

        -- Далее, для яркости (вертикальный градиент от белого к черному) - накладываем сверху
        local valFrame = Instance.new("Frame")
        valFrame.Size = UDim2.new(1, 0, 1, 0)
        valFrame.BackgroundTransparency = 1
        valFrame.ZIndex = 202
        valFrame.Parent = svBox

        local valGrad = Instance.new("UIGradient")
        valGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1, Color3.new(0,0,0))
        }
        valGrad.Rotation = 90
        valGrad.Parent = valFrame

        -- Теперь hue-оттенок накладываем поверх (как цветной слой с режимом смешивания? Но проще использовать UIGradient с нужным цветом для каждого пикселя. В Roblox нет режима смешивания. Поэтому сделаем другой подход: используем ImageLabel с Texture, но мы сделаем через цветную подложку и градиенты.

        -- Более простой способ: использовать один ImageLabel с рендерингом текстуры в коде, но это сложно. Мы пойдём на хитрость: создадим Frame, который будет перекрывать SV квадрат и иметь прозрачный фон, а цвет зададим через BackgroundColor3 и BackgroundTransparency = 0? Нет.

        -- Вместо этого, мы можем динамически менять цвет фона SV-квадрата на текущий оттенок, а градиенты накладывать как есть. Тогда получится, что цвет в точке определяется оттенком (фон) + градиенты насыщенности и яркости. На самом деле, при насыщенности=0 цвет становится белым, при яркости=0 - черным. Если мы наложим сверху градиент от белого к прозрачному (по X) и от прозрачного к черному (по Y), то при оттенке H это даст правильный HSV-квадрат.

        -- Итак, делаем:
        -- 1. Фон svBox устанавливаем в текущий цвет (чистый оттенок, s=1, v=1)
        -- 2. Создаём слой satFrame с градиентом от белого (x=0) к прозрачному (x=1), но прозрачность в Roblox не работает с цветами через UIGradient? UIGradient может задавать альфа-канал. Да, можно задать ColorSequence с прозрачностью. Итак:
        local satGrad2 = Instance.new("UIGradient")
        satGrad2.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
        }
        satGrad2.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        }
        satGrad2.Rotation = 0
        satGrad2.Parent = satFrame

        -- 3. Слой valFrame с градиентом от прозрачного к черному (по Y)
        local valGrad2 = Instance.new("UIGradient")
        valGrad2.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
            ColorSequenceKeypoint.new(1, Color3.new(0,0,0))
        }
        valGrad2.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0)
        }
        valGrad2.Rotation = 90
        valGrad2.Parent = valFrame

        -- Теперь для обновления оттенка будем менять BackgroundColor3 svBox, а градиенты останутся.

        -- Указатель на SV
        local svPicker = Instance.new("ImageLabel")
        svPicker.Size = UDim2.new(0, 12, 0, 12)
        svPicker.Position = UDim2.new(0, 0, 0, 0)
        svPicker.BackgroundTransparency = 1
        svPicker.Image = "rbxassetid://6031091834" -- круглая рамка
        svPicker.ImageColor3 = Color3.new(1,1,1)
        svPicker.ZIndex = 203
        svPicker.Parent = svBox

        -- RGB ползунки
        local sliders = {}
        local sliderNames = {"R", "G", "B"}
        local sliderValues = {currentColor.R*255, currentColor.G*255, currentColor.B*255}
        for i, name in ipairs(sliderNames) do
            local yPos = 225 + (i-1)*28
            local bg = Instance.new("Frame")
            bg.Size = UDim2.new(0.7, 0, 0, 20)
            bg.Position = UDim2.new(0.075, 0, 0, yPos)
            bg.BackgroundColor3 = Theme.ElementBackground
            bg.ZIndex = 202
            bg.Parent = popup
            local bgCorner = Instance.new("UICorner")
            bgCorner.CornerRadius = Theme.ElementCorner
            bgCorner.Parent = bg

            local labelR = Instance.new("TextLabel")
            labelR.Size = UDim2.new(0.15, 0, 1, 0)
            labelR.BackgroundTransparency = 1
            labelR.Text = name
            labelR.TextColor3 = Theme.TextColor
            labelR.Font = Enum.Font.SourceSansBold
            labelR.TextSize = 11
            labelR.TextXAlignment = Enum.TextXAlignment.Center
            labelR.ZIndex = 203
            labelR.Parent = bg

            local sliderTrack = Instance.new("Frame")
            sliderTrack.Size = UDim2.new(0.7, -10, 0.4, 0)
            sliderTrack.Position = UDim2.new(0.2, 0, 0.3, 0)
            sliderTrack.BackgroundColor3 = Color3.fromRGB(50,50,60)
            sliderTrack.ZIndex = 203
            sliderTrack.Parent = bg
            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1,0)
            trackCorner.Parent = sliderTrack

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(sliderValues[i]/255, 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(255,255,255)
            fill.ZIndex = 203
            fill.Parent = sliderTrack
            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1,0)
            fillCorner.Parent = fill

            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0.15, 0, 1, 0)
            valueLabel.Position = UDim2.new(0.85, 0, 0, 0)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(sliderValues[i])
            valueLabel.TextColor3 = Theme.SubTextColor
            valueLabel.Font = Enum.Font.SourceSans
            valueLabel.TextSize = 10
            valueLabel.TextXAlignment = Enum.TextXAlignment.Center
            valueLabel.ZIndex = 203
            valueLabel.Parent = bg

            -- Сохраняем данные
            sliders[i] = {
                Track = sliderTrack,
                Fill = fill,
                ValueLabel = valueLabel,
                Value = sliderValues[i],
                Name = name
            }

            -- Drag handling
            local dragging = false
            local function updateSlider(input)
                local posX = math.clamp(input.Position.X - sliderTrack.AbsolutePosition.X, 0, sliderTrack.AbsoluteSize.X)
                local pct = posX / sliderTrack.AbsoluteSize.X
                local val = math.floor(pct * 255)
                val = math.clamp(val, 0, 255)
                sliders[i].Value = val
                fill.Size = UDim2.new(val/255, 0, 1, 0)
                valueLabel.Text = tostring(val)
                updateColorFromSliders()
            end

            sliderTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateSlider(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
        end

        -- HEX поле
        local hexBox = Instance.new("TextBox")
        hexBox.Size = UDim2.new(0.2, 0, 0, 20)
        hexBox.Position = UDim2.new(0.7, 0, 0, 225)
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

        hexBox.FocusLost:Connect(function(enterPressed)
            local col = HexToColor3(hexBox.Text)
            if col then
                setColorFromRGB(col.R*255, col.G*255, col.B*255)
            else
                hexBox.Text = Color3ToHex(currentColor)
            end
        end)

        -- Кнопки OK / Cancel
        local okBtn = Instance.new("TextButton")
        okBtn.Size = UDim2.new(0.3, 0, 0, 28)
        okBtn.Position = UDim2.new(0.1, 0, 1, -36)
        okBtn.BackgroundColor3 = Color3.fromRGB(40,150,70)
        okBtn.Text = "OK"
        okBtn.TextColor3 = Color3.new(1,1,1)
        okBtn.Font = Enum.Font.SourceSansBold
        okBtn.TextSize = 12
        okBtn.ZIndex = 202
        okBtn.Parent = popup
        local okCorner = Instance.new("UICorner")
        okCorner.CornerRadius = Theme.ElementCorner
        okCorner.Parent = okBtn

        local cancelBtn = Instance.new("TextButton")
        cancelBtn.Size = UDim2.new(0.3, 0, 0, 28)
        cancelBtn.Position = UDim2.new(0.6, 0, 1, -36)
        cancelBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
        cancelBtn.Text = "Отмена"
        cancelBtn.TextColor3 = Color3.new(1,1,1)
        cancelBtn.Font = Enum.Font.SourceSansBold
        cancelBtn.TextSize = 12
        cancelBtn.ZIndex = 202
        cancelBtn.Parent = popup
        local cancelCorner = Instance.new("UICorner")
        cancelCorner.CornerRadius = Theme.ElementCorner
        cancelCorner.Parent = cancelBtn

        -- ===== Функции обновления =====
        local function updateColorFromSliders()
            local r = sliders[1].Value
            local g = sliders[2].Value
            local b = sliders[3].Value
            local color = Color3.new(r/255, g/255, b/255)
            setColor(color)
            -- Обновляем SV и Hue, а также HEX
            local h, s, v = Color3ToHSV(color)
            updateSV(h, s, v)
            updateHue(h)
            updateHex(color)
        end

        local function updateHex(color)
            hexBox.Text = Color3ToHex(color)
        end

        local function updateSV(h, s, v)
            -- Обновляем фон svBox (оттенок)
            svBox.BackgroundColor3 = HSVToColor3(h, 1, 1)
            -- Обновляем позицию пикера
            local x = s * svBox.AbsoluteSize.X
            local y = (1 - v) * svBox.AbsoluteSize.Y
            svPicker.Position = UDim2.new(0, x - 6, 0, y - 6)
        end

        local function updateHue(h)
            -- Позиция пикера на hueBar
            local x = h * hueBar.AbsoluteSize.X
            huePicker.Position = UDim2.new(0, x - 3, 0, 0)
        end

        local function setColorFromRGB(r, g, b)
            local color = Color3.new(r/255, g/255, b/255)
            setColor(color)
            local h, s, v = Color3ToHSV(color)
            updateSV(h, s, v)
            updateHue(h)
            updateHex(color)
            -- Обновляем слайдеры
            sliders[1].Value = r
            sliders[1].Fill.Size = UDim2.new(r/255, 0, 1, 0)
            sliders[1].ValueLabel.Text = tostring(r)
            sliders[2].Value = g
            sliders[2].Fill.Size = UDim2.new(g/255, 0, 1, 0)
            sliders[2].ValueLabel.Text = tostring(g)
            sliders[3].Value = b
            sliders[3].Fill.Size = UDim2.new(b/255, 0, 1, 0)
            sliders[3].ValueLabel.Text = tostring(b)
        end

        -- Инициализация UI текущим цветом
        local h, s, v = Color3ToHSV(currentColor)
        updateSV(h, s, v)
        updateHue(h)
        updateHex(currentColor)

        -- Обработка кликов на SV квадрате
        local svDragging = false
        local function updateSVFromInput(input)
            local pos = input.Position
            local x = math.clamp(pos.X - svBox.AbsolutePosition.X, 0, svBox.AbsoluteSize.X)
            local y = math.clamp(pos.Y - svBox.AbsolutePosition.Y, 0, svBox.AbsoluteSize.Y)
            local s = x / svBox.AbsoluteSize.X
            local v = 1 - (y / svBox.AbsoluteSize.Y)
            -- Получаем текущий оттенок из позиции пикера на hueBar
            local hPos = huePicker.Position.X.Offset / hueBar.AbsoluteSize.X
            local h = math.clamp(hPos, 0, 1)
            local color = HSVToColor3(h, s, v)
            setColorFromRGB(color.R*255, color.G*255, color.B*255)
        end

        svBox.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                svDragging = true
                updateSVFromInput(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                svDragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if svDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSVFromInput(input)
            end
        end)

        -- Обработка кликов на Hue баре
        local hueDragging = false
        local function updateHueFromInput(input)
            local x = math.clamp(input.Position.X - hueBar.AbsolutePosition.X, 0, hueBar.AbsoluteSize.X)
            local h = x / hueBar.AbsoluteSize.X
            huePicker.Position = UDim2.new(0, x - 3, 0, 0)
            -- Обновляем SV квадрат с новым оттенком
            svBox.BackgroundColor3 = HSVToColor3(h, 1, 1)
            -- Также обновляем цвет, сохраняя текущие s и v
            local currentS, currentV
            -- Получаем s и v из позиции пикера на SV
            local svX = svPicker.Position.X.Offset + 6
            local svY = svPicker.Position.Y.Offset + 6
            local s = math.clamp(svX / svBox.AbsoluteSize.X, 0, 1)
            local v = 1 - math.clamp(svY / svBox.AbsoluteSize.Y, 0, 1)
            local color = HSVToColor3(h, s, v)
            setColorFromRGB(color.R*255, color.G*255, color.B*255)
        end

        hueBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                hueDragging = true
                updateHueFromInput(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                hueDragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if hueDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateHueFromInput(input)
            end
        end)

        -- Кнопки OK / Cancel
        okBtn.MouseButton1Click:Connect(function()
            -- Цвет уже применён через setColor при каждом изменении, так что просто закрываем
            overlay:Destroy()
            popupOpen = false
        end)

        cancelBtn.MouseButton1Click:Connect(function()
            -- Восстанавливаем исходный цвет
            setColor(currentColor) -- но currentColor уже может быть изменён, нам нужно сохранить старый
            -- Мы сохраним исходный цвет при открытии
            overlay:Destroy()
            popupOpen = false
        end)

        -- Сохраняем исходный цвет для отмены
        local oldColor = currentColor
        cancelBtn.MouseButton1Click:Connect(function()
            setColor(oldColor)
            overlay:Destroy()
            popupOpen = false
        end)

        -- Закрытие по клику вне окна (на overlay)
        overlay.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                -- Проверяем, клик ли по оверлею (не по popup)
                if input.Target and input.Target:IsDescendantOf(overlay) and not input.Target:IsDescendantOf(popup) then
                    -- Отмена
                    setColor(oldColor)
                    overlay:Destroy()
                    popupOpen = false
                end
            end
        end)
    end

    -- Открытие по клику на preview
    colorPreview.MouseButton1Click:Connect(openPopup)

    -- Регистрация флага
    if flagName then
        local Lib = import("init.lua")
        Lib:RegisterFlag(flagName, currentColor, function(val)
            setColor(val)
        end)
    end

    return frame
end