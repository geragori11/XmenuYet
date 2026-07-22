-- [File: src/Elements/Slider.lua]
local UserInputService = game:GetService("UserInputService")
local Theme = import("src/Theme.lua")

return function(container, text, min, max, default, callback, flagName)
    local value = default or min

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundColor3 = Theme.ElementBackground
    frame.LayoutOrder = #container:GetChildren()
    frame.Parent = container

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = Theme.ElementCorner
    frameCorner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 18)
    label.Position = UDim2.new(0, 5, 0, 2)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(value)
    label.TextColor3 = Theme.TextColor
    label.Font = Enum.Font.SourceSans
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0.9, 0, 0, 6)
    track.Position = UDim2.new(0.05, 0, 0.68, 0)
    track.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    track.Parent = frame

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.AccentColor
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local function setValue(newVal)
        value = newVal
        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        label.Text = text .. ": " .. tostring(value)
        if callback then callback(value) end

        -- ОБНОВЛЕНИЕ ГЛОБАЛЬНОГО ФЛАГА
        if flagName then
            local Lib = import("init.lua")
            if Lib.Flags and Lib.Flags[flagName] then
                Lib.Flags[flagName].Value = value
            end
        end
    end

    local dragging = false
    local function update(input)
        local posX = math.clamp(input.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        local pct = posX / track.AbsoluteSize.X
        local newVal = math.floor(min + (max - min) * pct)
        setValue(newVal)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)

    -- Регистрация флага
    if flagName then
        local Lib = import("init.lua")
        Lib:RegisterFlag(flagName, value, function(val)
            setValue(val)
        end)
    end

    return frame
end