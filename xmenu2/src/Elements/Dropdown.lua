-- [File: src/Elements/Dropdown.lua]
local Theme = import("src/Theme.lua")

return function(container, text, options, callback)
    local expanded = false

    local mainBtn = Instance.new("TextButton")
    mainBtn.Size = UDim2.new(1, 0, 0, 26)
    mainBtn.BackgroundColor3 = Theme.ElementBackground
    mainBtn.Text = "  " .. text .. " ▼"
    mainBtn.TextColor3 = Theme.TextColor
    mainBtn.Font = Enum.Font.SourceSans
    mainBtn.TextSize = 13
    mainBtn.TextXAlignment = Enum.TextXAlignment.Left
    mainBtn.LayoutOrder = #container:GetChildren()
    mainBtn.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = Theme.ElementCorner
    corner.Parent = mainBtn

    local listHolder = Instance.new("Frame")
    listHolder.Size = UDim2.new(1, 0, 0, 0)
    listHolder.Visible = false
    listHolder.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    listHolder.LayoutOrder = #container:GetChildren()
    listHolder.Parent = container

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = Theme.ElementCorner
    listCorner.Parent = listHolder

    local layout = Instance.new("UIListLayout")
    layout.Parent = listHolder

    for _, opt in ipairs(options) do
        local itemBtn = Instance.new("TextButton")
        itemBtn.Size = UDim2.new(1, 0, 0, 20)
        itemBtn.BackgroundTransparency = 1
        itemBtn.Text = opt
        itemBtn.TextColor3 = Theme.SubTextColor
        itemBtn.Font = Enum.Font.SourceSans
        itemBtn.TextSize = 12
        itemBtn.Parent = listHolder

        itemBtn.MouseButton1Click:Connect(function()
            mainBtn.Text = "  " .. text .. " (" .. opt .. ")"
            expanded = false
            listHolder.Visible = false
            if callback then callback(opt) end
        end)
    end

    mainBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        listHolder.Visible = expanded
        listHolder.Size = UDim2.new(1, 0, 0, #options * 20)
    end)

    return mainBtn
end