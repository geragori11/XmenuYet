-- [File: modules/Combat/Killaura.lua]
local AddSlider = import("src/Elements/Slider.lua")
local AddColorPicker = import("src/Elements/ColorPicker.lua")  -- теперь это улучшенная версия

return {
    Page = "Combat",
    Section = "Misc",
    Name = "Killaura",
    Default = false,

    OnToggle = function(state)
        print("[Killaura] Состояние:", state)
    end,

    Settings = function(container)
        -- Слайдер радиуса (остаётся без изменений)
        AddSlider(
            container,
            "Радиус атаки",
            5,
            50,
            15,
            function(v)
                print("[Killaura] Радиус:", v)
            end,
            "Killaura_Radius"
        )

        -- Теперь используем улучшенный ColorPicker
        AddColorPicker(
            container,
            "Цвет таргета",
            Color3.fromRGB(255, 0, 0),   -- цвет по умолчанию (красный)
            function(color)
                print("[Killaura] Цвет установлен:", color)
                -- Здесь можно применить цвет к чему-то (например, к подсветке)
            end,
            "Killaura_TargetColor"        -- уникальный флаг для сохранения
        )

        -- Можно добавить ещё один ColorPicker, если нужно
        AddColorPicker(
            container,
            "Цвет круга атаки",
            Color3.fromRGB(0, 150, 255),
            function(color)
                print("[Killaura] Цвет круга:", color)
            end,
            "Killaura_CircleColor"
        )
    end
}