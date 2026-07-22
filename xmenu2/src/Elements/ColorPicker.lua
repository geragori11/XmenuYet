-- [File: src/Elements/ColorPicker.lua]
local Theme = import("src/Theme.lua")

return function(container, text, defaultColor, callback, flagName)
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

    colorPreview.MouseButton1Click:Connect(function()
        local newColor = Color3.fromHSV(math.random(), 1, 1)
        setColor(newColor)
    end)

    -- Регистрация флага
    if flagName then
        local Lib = import("init.lua")
        Lib:RegisterFlag(flagName, currentColor, function(val)
            setColor(val)
        end)
    end

    return frame
end