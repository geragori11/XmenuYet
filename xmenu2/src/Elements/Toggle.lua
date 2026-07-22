-- [File: src/Elements/Toggle.lua]
local Theme = import("src/Theme.lua")

return function(container, text, default, flagName, callback)
    local state = default or false

    local holder = Instance.new("Frame")
    holder.Name = text .. "_Holder"
    holder.Size = UDim2.new(1, 0, 0, 26)
    holder.BackgroundTransparency = 1
    holder.LayoutOrder = #container:GetChildren()
    holder.AutomaticSize = Enum.AutomaticSize.Y
    holder.Parent = container

    local holderLayout = Instance.new("UIListLayout")
    holderLayout.SortOrder = Enum.SortOrder.LayoutOrder
    holderLayout.Padding = UDim.new(0, 4)
    holderLayout.Parent = holder

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 26)
    button.BackgroundColor3 = Theme.ElementBackground
    button.Text = "  " .. text
    button.TextColor3 = state and Theme.AccentColor or Theme.TextColor
    button.Font = Enum.Font.SourceSans
    button.TextSize = 13
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.LayoutOrder = 1
    button.Parent = holder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = Theme.ElementCorner
    corner.Parent = button

    -- Контейнер настроек функции (появляется при ПКМ)
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Name = "OptionsFrame"
    optionsFrame.Size = UDim2.new(1, 0, 0, 0)
    optionsFrame.AutomaticSize = Enum.AutomaticSize.Y
    optionsFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    optionsFrame.Visible = false
    optionsFrame.LayoutOrder = 2
    optionsFrame.Parent = holder

    local optCorner = Instance.new("UICorner")
    optCorner.CornerRadius = Theme.ElementCorner
    optCorner.Parent = optionsFrame

    local optLayout = Instance.new("UIListLayout")
    optLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optLayout.Padding = UDim.new(0, 4)
    optLayout.Parent = optionsFrame

    local optPadding = Instance.new("UIPadding")
    optPadding.PaddingTop = UDim.new(0, 4)
    optPadding.PaddingBottom = UDim.new(0, 4)
    optPadding.PaddingLeft = UDim.new(0, 4)
    optPadding.PaddingRight = UDim.new(0, 4)
    optPadding.Parent = optionsFrame

    local function setState(newVal)
        state = newVal
        button.TextColor3 = state and Theme.AccentColor or Theme.TextColor
        if callback then callback(state) end

        -- ОБНОВЛЕНИЕ ГЛОБАЛЬНОГО ФЛАГА
        if flagName then
            local Lib = import("init.lua")
            if Lib.Flags and Lib.Flags[flagName] then
                Lib.Flags[flagName].Value = state
            end
        end
    end

    -- Включение/выключение по ЛКМ
    button.MouseButton1Click:Connect(function()
        setState(not state)
    end)

    -- Открытие/закрытие настроек по ПКМ
    button.MouseButton2Click:Connect(function()
        optionsFrame.Visible = not optionsFrame.Visible
    end)

    -- Регистрация флага в ядре
    if flagName then
        local Lib = import("init.lua")
        Lib:RegisterFlag(flagName, state, function(val)
            setState(val)
        end)
    end

    return holder, optionsFrame
end