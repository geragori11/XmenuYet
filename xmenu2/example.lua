-- [File: example.lua]
local Library = import("init.lua")
local AddToggle = import("src/Elements/Toggle.lua")
local AddSlider = import("src/Elements/Slider.lua")
local AddDropdown = import("src/Elements/Dropdown.lua")
local AddColorPicker = import("src/Elements/ColorPicker.lua")
local AddTextInput = import("src/Elements/TextInput.lua")

local UI = Library.new("XClientMenu")

local function AddSection(container, title)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 22)
    label.BackgroundColor3 = Library.Theme.SectionHeader
    label.Text = "  " .. title:upper()
    label.TextColor3 = Library.Theme.TextColor
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = Library.Theme.ElementCorner
    corner.Parent = label
end

-- ==================== COMBAT ====================
local combatCol = UI:AddColumn("Combat")

AddSection(combatCol.Container, "Misc")
AddToggle(combatCol.Container, "Auto Attack", false, function(v) print("Auto Attack:", v) end)

AddSection(combatCol.Container, "Sheriff")
AddToggle(combatCol.Container, "Sheriff Target", false, function(v) print("Sheriff Target:", v) end)

AddSection(combatCol.Container, "Murder")
AddToggle(combatCol.Container, "Murder Target", false, function(v) print("Murder Target:", v) end)

-- ==================== MOVEMENT ====================
local moveCol = UI:AddColumn("Movement")
AddSection(moveCol.Container, "Movement Options")
AddSlider(moveCol.Container, "Speed", 16, 100, 16, function(v) print("Speed:", v) end)

-- ==================== VISUAL ====================
local visualCol = UI:AddColumn("Visual")

AddSection(visualCol.Container, "Misc")
AddColorPicker(visualCol.Container, "Accent Color", Color3.fromRGB(0, 140, 255), function(c) print("Color:", c) end)

AddSection(visualCol.Container, "Legit")
AddToggle(visualCol.Container, "Box ESP", false, function(v) print("Box ESP:", v) end)

-- ==================== CONFIGS & MENU ====================
local configCol = UI:AddColumn("Configs")

AddSection(configCol.Container, "Menu Settings")

-- Изменение бинда меню
local keyNames = {"RightControl", "Insert", "RightShift", "Unknown"}
AddDropdown(configCol.Container, "Menu Keybind", keyNames, function(selectedKey)
    if Enum.KeyCode[selectedKey] then
        UI.ToggleKey = Enum.KeyCode[selectedKey]
        print("Новый бинд меню:", selectedKey)
    end
end)

-- Изменение размеров колонок
AddSlider(configCol.Container, "Width", 160, 240, 180, function(w)
    UI:SetColumnSize(w, UI.ColumnHeight)
end)

AddSlider(configCol.Container, "Height", 300, 600, 400, function(h)
    UI:SetColumnSize(UI.ColumnWidth, h)
end)

AddSection(configCol.Container, "Config Management")

local currentConfigInput = "default"
AddTextInput(configCol.Container, "Имя конфига...", function(txt)
    currentConfigInput = txt
end)

-- Контейнер для отображения сохраненных файлов конфигов
local configListFrame = Instance.new("Frame")
configListFrame.Size = UDim2.new(1, 0, 0, 0)
configListFrame.BackgroundTransparency = 1
configListFrame.Parent = configCol.Container

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = configListFrame

-- Функция обновления динамического списка конфигов в UI
local function RefreshConfigsUI()
    for _, child in ipairs(configListFrame:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end

    local files = Library.ConfigManager.ListConfigs()
    for _, filePath in ipairs(files) do
        local fileName = string.match(filePath, "([^/]+)%.json$") or filePath

        local cfgBtn = Instance.new("TextButton")
        cfgBtn.Size = UDim2.new(1, 0, 0, 24)
        cfgBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
        cfgBtn.Text = " 📄 " .. fileName
        cfgBtn.TextColor3 = Library.Theme.TextColor
        cfgBtn.Font = Enum.Font.SourceSans
        cfgBtn.TextSize = 12
        cfgBtn.TextXAlignment = Enum.TextXAlignment.Left
        cfgBtn.Parent = configListFrame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = Library.Theme.ElementCorner
        corner.Parent = cfgBtn

        cfgBtn.MouseButton1Click:Connect(function()
            local data = Library.ConfigManager.Load(fileName)
            print("Конфиг " .. fileName .. " загружен:", data)
        end)
    end
end

AddToggle(configCol.Container, "Сохранить конфиг", false, function()
    if currentConfigInput ~= "" then
        Library.ConfigManager.Save(currentConfigInput, { Speed = 16, Key = tostring(UI.ToggleKey) })
        RefreshConfigsUI()
    end
end)

-- Первоначальная загрузка списка конфигов
RefreshConfigsUI()