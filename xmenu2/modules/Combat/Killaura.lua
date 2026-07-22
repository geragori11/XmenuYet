-- [File: modules/Combat/Killaura.lua]
local AddSlider = import("src/Elements/Slider.lua")
local AddColorPicker = import("src/Elements/ColorPicker.lua")

return {
    Page = "Combat",
    Section = "Misc",
    Name = "Killaura",
    Default = false,

    OnToggle = function(state)
        print("[Killaura] Состояние:", state)
    end,

    Settings = function(container)
        -- Уникальный флаг для радиуса
        AddSlider(
            container,
            "Радиус атаки",          -- текст
            5,                       -- минимум
            50,                      -- максимум
            15,                      -- значение по умолчанию
            function(v)              -- callback при изменении (опционально)
                print("[Killaura] Радиус:", v)
            end,
            "Killaura_Radius"        -- <-- flagName (обязательно для сохранения!)
        )

        -- Уникальный флаг для цвета
        AddColorPicker(
            container,
            "Цвет таргета",                              -- текст
            Color3.fromRGB(255, 0, 0),                  -- цвет по умолчанию
            function(c)                                 -- callback (опционально)
                print("[Killaura] Цвет:", c)
            end,
            "Killaura_TargetColor"                      -- <-- flagName
        )
    end
}