-- [File: example.lua]
local Library = import("init.lua")
local Register = import("register.lua")

local AddDropdown = import("src/Elements/Dropdown.lua")

-- 1. Создаём объект UI
local UI = Library.new("XClientMenu")

-- 2. Создаём базовые колонки
UI:AddColumn("Combat")
UI:AddColumn("Movement")
UI:AddColumn("Visual")

-- 3. Создаём колонку Configs
local configCol = UI:AddColumn("Configs", 230)

local keyNames = {"K", "RightControl", "Insert", "RightShift"}
AddDropdown(configCol.Container, "Бинд меню", keyNames, function(selectedKey)
    if Enum.KeyCode[selectedKey] then
        UI.ToggleKey = Enum.KeyCode[selectedKey]
    end
end)

-- Отрисовываем конфиги
Library.ConfigManager.RenderUI(configCol.Container, UI)

-- 4. Регистрируем модули!
Register.newmodule("Combat/Killaura")
-- Можно добавить другие модули аналогично

-- После регистрации всех модулей вызываем рендер (отрисовка в колонках)
UI:RenderModules()