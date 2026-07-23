-- [File: src/Elements/Dropdown.lua]
local Theme = import("src/Theme.lua")

return function(container, text, options, callback, flagName, defaultOption)
    -- Если опций нет – показываем заглушку
    if not options or #options == 0 then
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 26)
        lbl.BackgroundColor3 = Theme.ElementBackground
        lbl.Text = "  " .. text .. " (нет опций)"
        lbl.TextColor3 = Theme.SubTextColor
        lbl.Font = Enum.Font.SourceSans
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.LayoutOrder = #container:GetChildren()
        lbl.Parent = container
        return lbl
    end

    local selected = defaultOption or options[1] or ""
    local expanded = false

    local mainBtn = Instance.new("TextButton")
    mainBtn.Size = UDim2.new(1, 0, 0, 26)
    mainBtn.BackgroundColor3 = Theme.ElementBackground
    mainBtn.Text = "  " .. text .. " (" .. selected .. ")"
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

    local function setSelected(opt)
        selected = opt
        mainBtn.Text = "  " .. text .. " (" .. opt .. ")"
        if callback then callback(opt) end
        if flagName then
            local Lib = import("init.lua")
            if Lib.Flags[flagName] then
                Lib.Flags[flagName].Value = opt
            end
        end
    end

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
            setSelected(opt)
            expanded = false
            listHolder.Visible = false
        end)
    end

    mainBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        listHolder.Visible = expanded
        listHolder.Size = UDim2.new(1, 0, 0, #options * 20)
    end)

    if flagName then
        local Lib = import("init.lua")
        Lib:RegisterFlag(flagName, selected, function(val)
            setSelected(val)
        end)
    end

    return mainBtn
end