-- [File: src/Elements/Button.lua]
local Theme = import("src/Theme.lua")

return function(container, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.BackgroundColor3 = Theme.ElementBackground
    btn.Text = text
    btn.TextColor3 = Theme.TextColor
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 13
    btn.LayoutOrder = #container:GetChildren()
    btn.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = Theme.ElementCorner
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return {
        main = btn,
        settings = nil
    }
end