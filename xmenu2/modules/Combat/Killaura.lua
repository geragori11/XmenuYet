-- [File: modules/Combat/Killaura.lua]
local AddSlider = import("src/Elements/Slider.lua")
local AddColorPicker = import("src/Elements/ColorPicker.lua")

return {
    Page = "Combat",
    Section = "Misc",
    Name = "Killaura",
    Default = false,

    -- Логика включения/выключения функции
    OnToggle = function(state)
        print("[Killaura] Состояние:", state)
    end,

    -- Настройки, открываемые при нажатии Правой Кнопкой Мыши (ПКМ) по функции
    Settings = function(container)
        AddSlider(container, "Радиус атаки", 5, 50, 15, function(v)
            print("[Killaura] Радиус:", v)
        end)

        AddColorPicker(container, "Цвет таргета", Color3.fromRGB(255, 0, 0), function(c)
            print("[Killaura] Цвет:", c)
        end)
    end
}