-- [File 9/10] src/Elements/TextInput.lua
local Theme = require(script.Parent.Parent.Theme)

return function(container, placeholder, callback)
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -8, 0, 24)
    textBox.BackgroundColor3 = Theme.ElementBackground
    textBox.PlaceholderText = placeholder or "Введите текст..."
    textBox.Text = ""
    textBox.TextColor3 = Theme.TextColor
    textBox.Font = Enum.Font.SourceSans
    textBox.TextSize = 12
    textBox.Parent = container

    textBox.FocusLost:Connect(function(enterPressed)
        if callback then callback(textBox.Text, enterPressed) end
    end)

    return textBox
end