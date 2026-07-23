-- [File: example.lua]
-- Реализация функции import с автоматическим поиском в папке xmenu2/
local loadedModules = {}

function import(path)
    if loadedModules[path] then
        return loadedModules[path]
    end

    local content
    local success, err = pcall(function()
        content = readfile(path)
    end)

    -- Если не удалось прочитать по прямому пути, пробуем с префиксом xmenu2/
    if not success then
        local prefixed = "xmenu2/" .. path
        success, err = pcall(function()
            content = readfile(prefixed)
        end)
        if not success then
            error("File not found: " .. path .. " or " .. prefixed .. "\n" .. tostring(err))
        end
    end

    local func, err = loadstring(content, "@" .. path)
    if not func then
        error("Error loading " .. path .. ": " .. err)
    end

    local result = func()
    loadedModules[path] = result
    return result
end

-- Основной код меню
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