-- [File: src/Elements/NumberInput.lua]
local Theme = import("src/Theme.lua")

return function(container, text, min, max, default, callback, flagName)
    local value = default or min or 0

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, 0, 0, 26)
    textBox.BackgroundColor3 = Theme.ElementBackground
    textBox.PlaceholderText = text .. "..."
    textBox.Text = tostring(value)
    textBox.TextColor3 = Theme.TextColor
    textBox.Font = Enum.Font.SourceSans
    textBox.TextSize = 12
    textBox.LayoutOrder = #container:GetChildren()
    textBox.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = Theme.ElementCorner
    corner.Parent = textBox

    local function setValue(newVal)
        if type(newVal) == "string" then
            newVal = tonumber(newVal)
        end
        if newVal == nil then return end
        if min and newVal < min then newVal = min end
        if max and newVal > max then newVal = max end
        value = newVal
        textBox.Text = tostring(value)
        if callback then callback(value) end
        if flagName then
            local Lib = import("init.lua")
            if Lib.Flags and Lib.Flags[flagName] then
                Lib.Flags[flagName].Value = value
            end
        end
    end

    textBox.FocusLost:Connect(function(enterPressed)
        local num = tonumber(textBox.Text)
        if num ~= nil then
            setValue(num)
        else
            textBox.Text = tostring(value)
        end
    end)

    if flagName then
        local Lib = import("init.lua")
        Lib:RegisterFlag(flagName, value, function(val)
            setValue(val)
        end)
    end

    return {
        main = textBox,
        settings = nil
    }
end