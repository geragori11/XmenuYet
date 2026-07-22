-- [File: register.lua]
local Register = {}

local Library = import("init.lua")
local AddSection = function(container, title)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 22)
    label.BackgroundColor3 = Library.Theme.SectionHeader
    label.Text = "  " .. title:upper()
    label.TextColor3 = Library.Theme.TextColor
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = #container:GetChildren()
    label.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = Library.Theme.ElementCorner
    corner.Parent = label
end

local AddToggle = import("src/Elements/Toggle.lua")

function Register.newmodule(relativePath)
    local mod = import("modules/" .. relativePath .. ".lua")
    if not mod then return end

    -- Поиск или создание нужной колонки
    local col = Library:GetColumn(mod.Page)
    if not col then
        col = Library:AddColumn(mod.Page)
    end

    -- Создание подсекции (Misc, Sheriff, Murder и т.д.), если указана
    if mod.Section then
        local sectionExists = false
        for _, child in ipairs(col.Container:GetChildren()) do
            if child:IsA("TextLabel") and child.Text == "  " .. mod.Section:upper() then
                sectionExists = true
                break
            end
        end
        if not sectionExists then
            AddSection(col.Container, mod.Section)
        end
    end

    -- Создание кнопки функции с поддержкой ПКМ
    local flagName = mod.Flag or (mod.Page .. "_" .. mod.Name)
    local holder, settingsContainer = AddToggle(
        col.Container,
        mod.Name,
        mod.Default or false,
        flagName,
        mod.OnToggle
    )

    -- Заполнение настроек, вызываемых по ПКМ
    if mod.Settings then
        mod.Settings(settingsContainer)
    end
end

return Register