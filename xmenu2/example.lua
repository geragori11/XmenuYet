-- [File: example.lua]
local Library = import("init.lua")
local AddToggle = import("src/Elements/Toggle.lua")
local AddSlider = import("src/Elements/Slider.lua")
local AddDropdown = import("src/Elements/Dropdown.lua")
local AddColorPicker = import("src/Elements/ColorPicker.lua")

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
    label.LayoutOrder = #container:GetChildren()
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

local keyNames = {"RightControl", "Insert", "RightShift"}
AddDropdown(configCol.Container, "Menu Keybind", keyNames, function(selectedKey)
    if Enum.KeyCode[selectedKey] then
        UI.ToggleKey = Enum.KeyCode[selectedKey]
        print("Новый бинд меню:", selectedKey)
    end
end)

AddSlider(configCol.Container, "Width", 160, 240, 180, function(w)
    UI:SetColumnSize(w, UI.ColumnHeight)
end)

AddSlider(configCol.Container, "Height", 300, 600, 400, function(h)
    UI:SetColumnSize(UI.ColumnWidth, h)
end)

AddSection(configCol.Container, "Config Management")

Library.ConfigManager.RenderUI(
    configCol.Container,
    function()
        return {
            Speed = 16,
            Key = tostring(UI.ToggleKey)
        }
    end,
    function(configName, data)
        print("Конфиг успешно загружен (" .. configName .. "):", data)
    end
)