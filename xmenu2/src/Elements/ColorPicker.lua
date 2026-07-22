-- [File 8/10] src/Elements/ColorPicker.lua
local Theme = require(script.Parent.Parent.Theme)

return function(container, text, defaultColor, callback)
    local currentColor = defaultColor or Color3.fromRGB(255, 255, 255)

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

    colorPreview.MouseButton1Click:Connect(function()
        -- Пример смены цвета (циклический сдвиг для демонстрации)
        currentColor = Color3.fromHSV(math.random(), 1, 1)
        colorPreview.BackgroundColor3 = currentColor
        if callback then callback(currentColor) end
    end)
end