local Theme = import("src/Theme.lua")

return function(container, text, default, callback)
    local state = default or false

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -8, 0, 24)
    button.BackgroundColor3 = Theme.ElementBackground
    button.Text = text
    button.TextColor3 = state and Theme.AccentColor or Theme.TextColor
    button.Font = Enum.Font.SourceSans
    button.TextSize = 13
    button.Parent = container

    button.MouseButton1Click:Connect(function()
        state = not state
        button.TextColor3 = state and Theme.AccentColor or Theme.TextColor
        if callback then callback(state) end
    end)

    return button
end