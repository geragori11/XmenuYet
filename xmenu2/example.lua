-- [File: example.lua]
local Library = import("init.lua")
local AddSlider = import("src/Elements/Slider.lua")
local AddDropdown = import("src/Elements/Dropdown.lua")

local UI = Library.new("XClientMenu")

-- Создание стандартных вкладок
UI:AddColumn("Combat")
UI:AddColumn("Movement")
UI:AddColumn("Visual")

-- Создание расширенной колонки Configs (ширина 230px)
local configCol = UI:AddColumn("Configs", 230)

-- Настройки меню
local keyNames = {"K", "RightControl", "Insert", "RightShift"}
AddDropdown(configCol.Container, "Бинд меню", keyNames, function(selectedKey)
    if Enum.KeyCode[selectedKey] then
        UI.ToggleKey = Enum.KeyCode[selectedKey]
    end
end)

-- Рендер UI управления конфигами
Library.ConfigManager.RenderUI(configCol.Container, UI)

-- ==================== РЕГИСТРАЦИЯ МОДУЛЕЙ ====================
-- Теперь вызывается через созданный объект UI:
UI:RegisterModule("Combat/Killaura")