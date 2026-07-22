-- example.lua
local Library = import("init.lua")
local AddToggle = import("src/Elements/Toggle.lua")
local AddSlider = import("src/Elements/Slider.lua")
local AddDropdown = import("src/Elements/Dropdown.lua")
local AddColorPicker = import("src/Elements/ColorPicker.lua")
local AddTextInput = import("src/Elements/TextInput.lua")

local UI = Library.new("MyRobloxMenu")

local function AddSection(container, title)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundColor3 = Library.Theme.SectionHeader
    label.Text = "--- " .. title:upper() .. " ---"
    label.TextColor3 = Library.Theme.TextColor
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 12
    label.Parent = container
end

-- COMBAT
local combatCol = UI:AddColumn("Combat")
AddSection(combatCol.Container, "Misc")
AddToggle(combatCol.Container, "Auto Attack", false, function(v) print("Auto Attack:", v) end)

AddSection(combatCol.Container, "Sheriff")
AddToggle(combatCol.Container, "Sheriff Target", false, function(v) print("Sheriff Target:", v) end)

AddSection(combatCol.Container, "Murder")
AddToggle(combatCol.Container, "Murder Target", false, function(v) print("Murder Target:", v) end)

-- MOVEMENT
local moveCol = UI:AddColumn("Movement")
AddSlider(moveCol.Container, "Speed", 16, 100, 16, function(v) print("Speed:", v) end)

-- VISUAL
local visualCol = UI:AddColumn("Visual")
AddSection(visualCol.Container, "Misc")
AddColorPicker(visualCol.Container, "Accent Color", Color3.fromRGB(0, 120, 215), function(c) print("Color:", c) end)

AddSection(visualCol.Container, "Legit")
AddToggle(visualCol.Container, "Box ESP", false, function(v) print("Box ESP:", v) end)

-- CONFIGS
local configCol = UI:AddColumn("Configs")
local configName = "default"
AddTextInput(configCol.Container, "Имя конфига...", function(txt) configName = txt end)

AddToggle(configCol.Container, "Сохранить", false, function()
    Library.ConfigManager.Save(configName, { Speed = 16 })
end)

AddToggle(configCol.Container, "Загрузить", false, function()
    local cfg = Library.ConfigManager.Load(configName)
    print("Загружен конфиг:", cfg)
end)