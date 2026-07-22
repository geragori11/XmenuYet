-- [File: src/Elements/TextInput.lua]
local Theme = import("src/Theme.lua")

return function(container, placeholder, callback)
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, 0, 0, 26)
    textBox.BackgroundColor3 = Theme.ElementBackground
    textBox.PlaceholderText = placeholder or "Введите текст..."
    textBox.Text = ""
    textBox.TextColor3 = Theme.TextColor
    textBox.Font = Enum.Font.SourceSans
    textBox.TextSize = 12
    textBox.LayoutOrder = #container:GetChildren()
    textBox.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = Theme.ElementCorner
    corner.Parent = textBox

    textBox.FocusLost:Connect(function(enterPressed)
        if callback then callback(textBox.Text, enterPressed) end
    end)

    return textBox
end